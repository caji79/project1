-- Eli Chen
-- cmpm 121
-- 4/18/25

require "card"
require "grabber"

function love.load()
    love.window.setMode(960, 640)
    love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)
    love.window.setTitle('Solitaire')

    cardTable = {}
    table.insert(cardTable, CardClass:new(52, 100, 100))
    table.insert(cardTable, CardClass:new(1, 0, 0))

    grabber = GrabberClass:new(cardTable)

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

function love.draw()
    for _, card in ipairs(cardTable) do
        card:draw()
    end
end