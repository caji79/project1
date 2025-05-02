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
    for i = #self.cards, 1, -1 do
        local card = self.cards[i]
        if card.state == CARD_STATE.MOUSE_OVER and card.draggable then
            self.heldObject = card
            card.state = CARD_STATE.GRABBED
            self.mouseOffset = {
                x = self.currentMousePos.x - card.position.x,
                y = self.currentMousePos.y - card.position.y
            }
            card.originalPos = Vector(card.position.x, card.position.y)
            self.grabPos = self.currentMousePos
            -- move the card to the top 
            for i, c in ipairs(cardTable) do
                if c == card then
                table.remove(cardTable, i)
                table.insert(cardTable, card)
                break
                end
            end
            return
        end
    end
end

function GrabberClass:release()

    if self.heldObject == nil then -- we have nothing to release
        return
    end

    local card = self.heldObject
    local cw, ch = CARD_WIDTH*CARD_SCALE_X, CARD_HEIGHT*CARD_SCALE_Y

    local suitHit = nil
    for i, pos in ipairs(stackPilesPos) do
        if checkOverlaps(card.position.x, card.position.y, cw, ch, pos.x, pos.y, cw, ch) then
            suitHit = i
            break
        end
    end

    if suitHit and validStackPileAdding(card, suitHit) then
        local suitPos = stackPilesPos[suitHit]
        card.position = Vector(suitPos.x, suitPos.y)
        -- card.draggable = false
        for _, pile in pairs({deckPile, drawPile}) do
            for j=#pile,1,-1 do
                if pile[j] == card then table.remove(pile, j); break end
            end
        end
        for _, col in ipairs(tableauPiles) do
            for j=#col,1,-1 do
                if col[j] == card then table.remove(col, j); break end
            end
        end
      
        -- finally add it to the foundation data
        table.insert(stackPiles[ SUITS[suitHit] ], card)
      
    else
        -- 3) invalid drop → bounce back
        card.position = card.originalPos
    end

    local isValidRealse = true
    if not isValidRealse then
        self.heldObject.position = self.grabPos
    end

    self.heldObject.state = 0 -- it's no longer grabbed
    self.heldObject = nil
    self.grabPos    = nil
end