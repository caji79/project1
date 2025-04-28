require "vector"

GrabberClass = {}

function GrabberClass:new(cardList)
    local grabber = {}
    local metadata = {__index = GrabberClass}
    setmetatable(grabber, metadata)

    grabber.cards = cardList
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
        self:grab()
    end
    -- Release
    if not love.mouse.isDown(1) and self.grabPos ~= nil then
        self:release()
    end  
end

function GrabberClass:grab()
    self.grabPos = self.currentMousePos

    -- the topmost card under the cursor
    for i = #self.cards, 1, -1 do
        local card = self.cards[i]
        if card.state == CARD_STATE.MOUSE_OVER then
            self.heldObject = card
            card.state = CARD_STATE.GRABBED
            self.mouseOffset = {
                x = self.currentMousePos.x - card.position.x,
                y = self.currentMousePos.y - card.position.y
            }
            break
        end
    end
end

function GrabberClass:release()
    self.grabPos = nil

    if self.heldObject == nil then -- we have nothing to release
        return
    end

    local isValidRealse = true
    if not isValidRealse then
        self.heldObject.position = self.grabPos
    end

    self.heldObject.state = 0 -- it's no longer grabbed
    self.heldObject = nil
end