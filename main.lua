-- Eli Chen
-- cmpm 121
-- 4/18/25

require "card"
require "grabber"
require "gameBoard"

function love.load()
    love.window.setMode(960, 640)
    love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)
    love.window.setTitle('Solitaire')

    cardTable = {}
    -- table.insert(cardTable, CardClass:new(52, 100, 100))
    -- table.insert(cardTable, CardClass:new(1, 0, 0))
    grabber = GrabberClass:new(cardTable)

    deckPile = {}
    tableauPiles = {}

    drawPile = {}
    drawPilePos = Vector(25, 150)

    stackPiles = {}
    stackPilesPos = {
        Vector(495, 25),
        Vector(610, 25),
        Vector(725, 25),
        Vector(840, 25)
    }

    local suitStack = { "spades", "clubs", "hearts", "diamonds" }
    for i, suit in ipairs(suitStack) do
        stackPiles[suit] = {}
    end

    shuffledDeck = CardClass:deckBuilder()
    for _, card in ipairs(shuffledDeck) do
        card.position = Vector(25, 25)
        card.draggable = false
        card.faceUp = false
        table.insert(deckPile, card)
        table.insert(cardTable, card)
    end

    local tblPosX, tblPosY = 150, 150
    local pileSpacing = (CARD_WIDTH * CARD_SCALE_X) + 40
    local cardOverlap = 30
    for i = 1, 7 do
        tableauPiles[i] = {}  -- seven tableau piles total, {1}, {2}, {3}, {4}, {5}, {6}, {7}
        for j = 1, i do
            local card = table.remove(deckPile)
            card.position = Vector(tblPosX + (i - 1) * pileSpacing, tblPosY + (j - 1) * cardOverlap)
            card.faceUp = (j == i)      -- only the last card is flipped
            card.draggable =  (j == i)  -- only the last card is draggable
            table.insert(tableauPiles[i], card)
            table.insert(cardTable, card)
        end
    end

end

function love.update()
    grabber:update()

    for _, card in ipairs(cardTable) do
        card:checkForMouseOver(grabber)
        card:update()   -- moves it if grabbed
        -- let the card follow while grabbed:
        if card.state == CARD_STATE.GRABBED and grabber.heldObject == card then
            card.position.x = grabber.currentMousePos.x - grabber.mouseOffset.x
            card.position.y = grabber.currentMousePos.y - grabber.mouseOffset.y
        end
    end

end

function love.mousepressed(x, y, button)
    if button == 1 then drawCard(x, y) end
end

function drawCard(clickX, clickY)
    local deckX, deckY = 25, 25
    local deckW = CARD_WIDTH * CARD_SCALE_X
    local deckH = CARD_HEIGHT * CARD_SCALE_Y
    if clickX > deckX and clickX < deckX + deckW and clickY > deckY and clickY < deckY + deckH then
        if #deckPile > 0 then
            -- remove top card from stock
            local card = table.remove(deckPile)
            card.faceUp = true
            card.draggable = true

            -- move it to your draw‐pile position
            card.position = Vector(drawPilePos.x, drawPilePos.y)
            table.insert(drawPile, card)
            table.insert(cardTable, card)
        else
            for i = #drawPile, 1, -1 do
                local card = table.remove(drawPile)
                card.faceUp = false
                card.draggable = false
                card.position = Vector(25, 25)
                table.insert(deckPile, card)
                table.insert(cardTable, card)
            end
        end
    end
end

function love.draw()
    GameBoardClass:draw()

    for _, card in ipairs(cardTable) do
        card:draw()
    end

    -- -- tableau (7 piles)
    -- local x, y = 150, 150
    -- local pileSpacing = (CARD_WIDTH * CARD_SCALE_X) + 40
    -- local cardOverlap = 30
    -- local heldCard = grabber.heldObject

    -- for pile = 1, 7 do
    --     local pileX = x + pileSpacing * (pile - 1)
    --     for cardIdx, card in ipairs(Tableau[pile]) do
    --         if card ~= heldCard then
    --             local pileY = y + cardOverlap * (cardIdx - 1)
    --             card.position.x = pileX
    --             card.position.y = pileY
    --             card:draw()
    --         end
    --     end
    -- end

    -- if heldCard then heldCard:draw() end

    -- card state debug
    love.graphics.setColor(1,1,1)
    local debugState = CARD_STATE.IDLE
    if grabber.heldObject then
        debugState = CARD_STATE.GRABBED
    else
        -- if any card is in MOUSE_OVER state, show 1
        for _,c in ipairs(cardTable) do
            if c.state == CARD_STATE.MOUSE_OVER then
                debugState = CARD_STATE.MOUSE_OVER
                break
            end
        end
    end
    love.graphics.print("State: "..debugState, 10, 10)
    love.graphics.setColor(1,1,1)

end

function checkOverlaps(ax,ay,aw,ah, bx,by,bw,bh)
    return ax < bx + bw and 
           ax + aw > bx and 
           ay < by + bh and 
           ay + ah > by
end

function validStackPileAdding(card, suitIdx)
    local targetSuit = SUITS[suitIdx]
    if card.suit ~= targetSuit then return false end

    local suitPile = stackPiles[targetSuit]
    local rankVal = rankValueMap[card.rank]

    if #suitPile == 0 then
        return rankVal == 1   -- only A goes on an empty foundation
    else
        local topCard = suitPile[#suitPile]
        return rankVal == rankValueMap[topCard.rank] + 1
    end
end