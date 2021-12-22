Bounds = {x = 0, y = 0, width = 0, height = 0}

function Bounds:new(x, y, width, height)
    local instance = {x = x, y = y, width = width, height = height}
    self.__index = self
    return setmetatable(instance, self)
end
