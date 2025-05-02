require "vector"

GrabberClass = {}

function GrabberClass:new(cardTable)
    local grabber = {}
    local metadata = {__index = GrabberClass}
    setmetatable(grabber, metadata)

    grabber.cards = cardTable
    grabber.currentMousePos = nil
    grabber.grabPos = nil
    grabber.mouseOffset = nil
    grabber.heldObject = nil

    return grabber
end

function GrabberClass:update()
    self.currentMousePos = Vector(love.mouse.getX(), love.mouse.getY())
    
    -- Click
    if love.mouse.isDown(1) and self.grabPos == nil then
        local mx,my = self.currentMousePos.x, self.currentMousePos.y
        local deckX, deckY = 25, 25
        local deckW = CARD_WIDTH * CARD_SCALE_X
        local deckH = CARD_HEIGHT * CARD_SCALE_Y
        -- don't grab any cards inside the deck pile area
        if mx >= deckX and mx <= deckX + deckW and my >= deckY and my <= deckY + deckH then
            return
        end
        self:grab()
    end
    -- Release
    if not love.mouse.isDown(1) and self.grabPos ~= nil then
        self:release()
    end  
end

function GrabberClass:grab()
    -- grab the topmost card under the cursor
    local grabbedCard = nil
    for i = #self.cards, 1, -1 do
        local card = self.cards[i]
        if card.state == CARD_STATE.MOUSE_OVER and card.draggable then
            grabbedCard = card
            break
        end
    end
    if not grabbedCard then return end

    -- determine origin
    local origin = {}

    -- tableau check
    for col = 1, 7 do
        for idx = 1, #tableauPiles[col] do
            if tableauPiles[col][idx] == grabbedCard then
                origin = { type = "tableau", col = col, idx = idx }
                break
            end
        end
        if origin.type then break end
    end

    -- draw check
    if not origin.type then
        for i = #drawPile, 1, -1 do
            if drawPile[i] == grabbedCard then
                origin = { type = "draw" }
            end
        end
    end

    -- suit foundations check
    if not origin.type then
        for _, suit in ipairs(SUITS) do
            local pile = stackPiles[suit]
            if pile[#pile] == grabbedCard then
                origin = { type = "foundation", suit = suit }
                break
            end
        end
    end

    -- deck check
    if not origin.type then
        for i = #deckPile, 1, -1 do
            if deckPile[i] == grabbedCard then
                origin = { type = "deck" }
                break
            end
        end
    end

    self.origin = origin
    self.heldObject = grabbedCard
    grabbedCard.state = CARD_STATE.GRABBED
    self.mouseOffset = {
        x = self.currentMousePos.x - grabbedCard.position.x,
        y = self.currentMousePos.y - grabbedCard.position.y
    }
    grabbedCard.originalPos = Vector(grabbedCard.position.x, grabbedCard.position.y)
    self.grabPos = self.currentMousePos

    -- move the card to the top 
    for i, c in ipairs(cardTable) do
        if c == grabbedCard then
            table.remove(cardTable, i)
            table.insert(cardTable, grabbedCard)
            break
        end
    end
            
end

function GrabberClass:release()

    if self.heldObject == nil then -- we have nothing to release
        return
    end

    local card = self.heldObject
    local cw, ch = CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y
    local moved = false

    for i, pos in ipairs(stackPilesPos) do
        if checkOverlaps(card.position.x, card.position.y, cw, ch, pos.x, pos.y, cw, ch) 
            and validStackPileAdding(card, i) 
        then
            card.position = Vector(pos.x, pos.y)
            removeCardFromOrigin(card, self.origin)
        
            -- add it to the stackPile table
            table.insert(stackPiles[ SUITS[i] ], card)
            moved = true
            break
        end
    end

    -- tableau
    if not moved then
        for i, pos in ipairs(tableauPos) do
            local dropX, dropY
            local pile = tableauPiles[i]
            if #pile > 0 then
                local top = pile[#pile]
                dropX =  top.position.x
                dropY = top.position.y + cardOverlap

                if checkOverlaps(card.position.x, card.position.y, cw, ch, dropX, dropY, cw, ch)
                    and GrabberClass:tableauMove(card, top)
                then
                    card.position = Vector(dropX, dropY)
                    card.draggable = true
                    removeCardFromOrigin(card, self.origin)
                    table.insert(pile, card)
                    moved = true
                    break
                end
            else
                dropX = pos.x
                dropY = pos.y

                if checkOverlaps(card.position.x, card.position.y, cw, ch, dropX, dropY, cw, ch)
                    and rankValueMap[card.rank] == 13
                then
                    card.position = Vector(dropX, dropY)
                    removeCardFromOrigin(card, self.origin)
                    table.insert(pile, card)
                    moved = true
                    break
                end
            end
        end
    end

    -- flip the last card in tableau column pile
    if self.origin.type == "tableau" then
        local pile = tableauPiles[self.origin.col]
        if #pile > 0 then
            local top = pile[#pile]
            if not top.faceUp then
                top.faceUp    = true
                top.draggable = true
            end
        end
    end

    if not moved then
        card.position = card.originalPos
    end

    -- local isValidRealse = true
    -- if not isValidRealse then
    --     self.heldObject.position = self.grabPos
    -- end

    self.heldObject.state = 0 -- it's no longer grabbed
    self.heldObject = nil
    self.grabPos    = nil
end

function GrabberClass:tableauMove(movingCard, targetCard)
    if suitColor[movingCard.suit] == suitColor[targetCard.suit] then
        return false
    end

    local moveValue = rankValueMap[movingCard.rank]
    local targeValue = rankValueMap[targetCard.rank]

    return moveValue == targeValue - 1
end