Vector = {x = 0, y = 0, velocity = 250}

function Vector.__sub(left, right)
  local diff = Vector:new()
  diff.x = math.max(left.x, right.x) - math.min(left.x, right.x)
  diff.y = math.max(left.y, right.y) - math.min(left.y, right.y)
  return diff
end

function Vector:new()
  local instance = {}

  self.__index = self

  self.__tostring = function(v)
    return string.format("(x: %d, y: %d)", v.x, v.y)
  end

  return setmetatable(instance, self)
end
