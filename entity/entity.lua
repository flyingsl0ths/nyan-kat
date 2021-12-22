require "maths.bounds"
require "maths.vector"
require "utils.scope_functions"

Entity = {}

function Entity:new()
  local instance = {
    bounds = Bounds:new(0, 0, 0, 0),
    velocity = also(Vector:new(), function(velocity)
      velocity.x = 250
      velocity.y = 250
    end)
  }

  self.__index = self

  return setmetatable(instance, self)
end

function Entity:getX() return self.bounds.x end

function Entity:getY() return self.bounds.y end

function Entity:getVelocity() return self.velocity end

function Entity:getBounds() return self.bounds end

function Entity:setX(x) self.bounds.x = x end

function Entity:setY(y) self.bounds.y = y end

function Entity:setXY(x, y)
  self.bounds.x = x
  self.bounds.y = y
end

function Entity:setVelocity(velocity_x, velocity_y)
  self.velocity.x = velocity_x
  self.velocity.y = velocity_y
end

function Entity:setBounds(width, height)
  self.bounds.width = width
  self.bounds.height = height
end
