Animation = {duration = 1, elapsed_time = 0}

function Animation:new(image, width, height, duration)
  local instance = {
    sprite_sheet = image,
    width = width,
    height = height,
    duration = duration,
    quads = {}
  }

  self.__index = self

  return setmetatable(instance, self)
end

function Animation:addFrame(x, y)
  table.insert(self.quads, love.graphics.newQuad(x, y, self.width, self.height,
                                                 self.sprite_sheet:getDimensions()))
end

function Animation:update(dt)
  self.elapsed_time = self.elapsed_time + dt

  if self.elapsed_time >= self.duration then
    self.elapsed_time = self.elapsed_time - self.duration
  end
end

function Animation:draw(x, y)
  local frame_index =
      math.floor(self.elapsed_time / self.duration * #self.quads) + 1

  love.graphics.draw(self.sprite_sheet, self.quads[frame_index], x, y, 0, 2)
end
