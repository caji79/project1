require "util"
require "vector"

CardClass = {}

CARD_STATE = {
    IDLE = 0,
    MOUSE_OVER = 1,
    GRABBED = 2
  }

CardClass.cardFront = love.graphics.newImage('assets/cards.png')
CardClass.cardFront:setFilter('nearest', 'nearest')
CardClass.cardBack = love.graphics.newImage('assets/cardBack.png')
CardClass.cardBack:setFilter('nearest', 'nearest')
CardClass.width = 25
CardClass.height = 38
CardClass.quads = generateQuads(CardClass.cardFront, CardClass.width, CardClass.height)

function CardClass:new(quadIndex, xPos, yPos)
    local card = {}
    local metadata = {__index = CardClass}
    setmetatable(card, metadata)

    card.position = Vector(xPos, yPos)
    card.scaleX = 3
    card.scaleY = 3
    card.state = CARD_STATE.IDLE
    card.quad = CardClass.quads[quadIndex]
    card.hidden = false

    return card
end

function CardClass:update()
    if self.state == CARD_STATE.GRABBED and grabber.heldObject == self then
        self.position.x = grabber.currentMousePos.x
        self.position.y = grabber.currentMousePos.y
    end
end

function CardClass:draw()
    if self.hidden then
        love.graphics.draw(CardClass.cardBack, self.position.x, self.position.y, 0, self.scaleX, self.scaleY)
    else
        love.graphics.draw(CardClass.cardFront, self.quad, self.position.x, self.position.y, 0, self.scaleX, self.scaleY)
    end
end

function CardClass:checkForMouseOver(grabber)
    if self.state == CARD_STATE.GRABBED then
        return
    end
      
    local mousePos = grabber.currentMousePos
    local isMouseOver = 
      mousePos.x > self.position.x and
      mousePos.x < self.position.x + (CardClass.width * self.scaleX) and
      mousePos.y > self.position.y and
      mousePos.y < self.position.y + (CardClass.height * self.scaleY)
    
    self.state = isMouseOver and CARD_STATE.MOUSE_OVER or CARD_STATE.IDLE
  end