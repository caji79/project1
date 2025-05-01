GameBoardClass = {}

function GameBoardClass:new()
    local gameBoard = {}
    local metadata = {__index = GameBoardClass}
    setmetatable(gameBoard, metadata)

    return gameBoard
end

function GameBoardClass:tableauLayout()

end

function GameBoardClass:draw()
    self:drawGrid()

    
end

function GameBoardClass:drawGrid()
    -- stack placeholders
    love.graphics.rectangle('line', 495, 25, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 610, 25, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 725, 25, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 840, 25, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)

    -- stock & draw
    love.graphics.rectangle('line', 25, 25, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 25, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)

    -- tableaus
    love.graphics.rectangle('line', 150, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 265, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 380, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 495, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 610, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 725, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
    love.graphics.rectangle('line', 840, 150, CARD_WIDTH * CARD_SCALE_X, CARD_HEIGHT * CARD_SCALE_Y, 5)
end