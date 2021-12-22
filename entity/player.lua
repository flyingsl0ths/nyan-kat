require "entity.entity"
require "utils.animator"
require "utils.scope_functions"

PlayerAnimation = {NORMAL = 1, DAMAGED = 2, INVINCIBLE = 3}

Player = {
  hp = 100,
  damage_offset = 1,
  is_invisible = false,
  invincible_time = 0,
  max_invincible_time = 40,
  cool_down_time = 0,
  max_cool_down_time = 35
}

local function set_normal_animation(player_sprite_sheet)
  local animator = Animation:new(player_sprite_sheet, 66, 41, 1)

  animator:addFrame(0, 0)
  animator:addFrame(66, 0)
  animator:addFrame(137, 0)
  animator:addFrame(210, 0)
  animator:addFrame(283, 0)
  animator:addFrame(354, 0)

  return animator
end

local function set_damaged_animation(player_sprite_sheet)
  local animator = Animation:new(player_sprite_sheet, 63, 50, 1)

  animator:addFrame(0, 41)
  animator:addFrame(67, 41)
  animator:addFrame(129, 41)

  return animator
end

local function set_invincible_animation(player_sprite_sheet)
  local animator = Animation:new(player_sprite_sheet, 78, 41, 1)

  animator:addFrame(0, 92)
  animator:addFrame(79, 92)
  animator:addFrame(157, 92)
  animator:addFrame(235, 92)

  return animator
end

function Player:new()
  local player_sprite_sheet = love.graphics.newImage("data/textures/player.png")
  local instance = {
    sprite_sheet = player_sprite_sheet,
    entity = Entity:new(),
    animator = set_normal_animation(player_sprite_sheet)
  }

  self.__index = self

  instance.entity:setBounds(instance.animator.width, instance.animator.height)

  return setmetatable(instance, self)
end

function Player:setAnimation(animation_type)
  if animation_type == PlayerAnimation.NORMAL then
    self.animator = set_normal_animation(self.sprite_sheet)
    self.entity:setBounds(self.animator.width, self.animator.height)
  elseif animation_type == PlayerAnimation.DAMAGED then
    self.animator = set_damaged_animation(self.sprite_sheet)
    self.entity:setBounds(self.animator.width, self.animator.height)
  elseif animation_type == PlayerAnimation.INVINCIBLE then
    self.animator = set_invincible_animation(self.sprite_sheet)
    self.entity:setBounds(self.animator.width, self.animator.height)
  end
end

function Player:setHp(hp) if (hp > 0) then self.hp = hp end end

function Player:setVelocity(velocity_x, velocity_y)
  self.entity:setVelocity(velocity_x, velocity_y)
end

function Player:setX(x) self.entity:setX(x) end

function Player:setY(y) self.entity:setY(y) end

function Player:setXY(x, y)
  self.entity:setX(x)
  self.entity:setY(y)
end

function Player:getX() return self.entity:getX() end

function Player:getY() return self.entity:getY() end

function Player:getBounds() return self.entity:getBounds() end

function Player:moveDown(dt)
  self.entity:setY(self:getY() + self.entity:getVelocity().y * dt)
end

function Player:moveUp(dt)
  self.entity:setY(self.entity:getY() - self.entity:getVelocity().y * dt)
end

function Player:moveRight(dt)
  self.entity:setX(self.entity:getX() + self.entity:getVelocity().x * dt)
end

function Player:moveLeft(dt)
  self.entity:setX(self.entity:getX() - self.entity:getVelocity().x * dt)
end

function Player:canDodge()
  return (not self.is_invisible and self.invincible_time == 0 and
             self.cool_down_time == 0)
end

function Player:damage() self.hp = self.hp - self.damage_offset end

function Player:dodge()
  self.animator:draw(self.entity:getX(), self.entity:getY())
end

local function draw_player_dodging(player) player:dodge() end

function Player:update(dt)
  self.animator:update(dt)

  if self.is_invisible then
    self.invincible_time = self.invincible_time + 1
    if self.invincible_time == self.max_invincible_time then
      self.is_invisible = false
      self.animator = set_normal_animation(self.sprite_sheet)
    end
  elseif self.invincible_time == self.max_invincible_time then
    self.cool_down_time = (self.cool_down_time + 1) % self.max_cool_down_time
    if self.cool_down_time == 0 then self.invincible_time = 0 end
  end

end

function Player:draw()
  if self.is_invisible then
    draw_player_dodging(self)
  else
    self.animator:draw(self.entity:getX(), self.entity:getY())
  end
end
