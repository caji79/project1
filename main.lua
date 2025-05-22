-- Eli Chen
-- cmpm 121
-- 4/18/25

require "card"
require "grabber"
require "gameBoard"

gameWon = false

function checkForWin()
    for _, suit in ipairs(SUITS) do
        if #stackPiles[suit] < 13 then
            return false
        end
    end
    return true
end

function love.load()
    love.window.setMode(960, 720)
    love.graphics.setBackgroundColor(0, 0.6, 0.2, 1)
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

    defaultFont = love.graphics.getFont()

    -- create a larger font for the win screen
    winFont = love.graphics.newFont(64)

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

    tblPosX, tblPosY = 150, 150
    pileSpacing = (CARD_WIDTH * CARD_SCALE_X) + 40
    cardOverlap = 30

    tableauPos = {}
    for i = 1, 7 do
        tableauPos[i] = Vector(tblPosX + (i - 1) * pileSpacing, tblPosY)
    end

    for i = 1, 7 do
        tableauPiles[i] = {}  -- seven tableau piles total, {1}, {2}, {3}, {4}, {5}, {6}, {7}
        for j = 1, i do
            local card = table.remove(deckPile)
            card.position = Vector(tableauPos[i].x, tableauPos[i].y + (j - 1) * cardOverlap)
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

-- win screen debugging function
function love.keypressed(key)
    if key == "w" then    -- press “W” to flip win on/off
        gameWon = not gameWon
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

    if gameWon then
        local w,h = love.graphics.getDimensions()
        -- dim the background
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", 0,0, w,h)
        -- draw the text
        -- switch to the big win font:
        love.graphics.setFont(winFont)
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf("You Win!", 0, h*0.5, w, "center")
        -- restore your normal font if you draw other text later:
        love.graphics.setFont(defaultFont)
    end

end

-- collision detection
-- https://love2d.org/forums/viewtopic.php?t=81957
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

function removeCardFromOrigin(card, origin)
    if origin.type == "tableau" then
        table.remove(tableauPiles[origin.col], origin.idx)

    elseif origin.type == "draw" then
        for i = #drawPile, 1, -1 do
            if drawPile[i] == card then
                table.remove(drawPile, i)
                break
            end
        end

    elseif origin.type == "deck" then
        for i = #deckPile, 1, -1 do
            if deckPile[i] == card then
                table.remove(deckPile, i)
                break
            end
        end

    elseif origin.type == "foundation" then
        local pile = stackPiles[ origin.suit ]
        for i = #pile, 1, -1 do
            if pile[i] == card then
                table.remove(pile, i)
                break
            end
        end
    end
end