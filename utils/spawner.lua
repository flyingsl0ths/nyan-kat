require "maths.vector"
require "entity.enemy_pack"
require "utils.scope_functions"

local collisions = require "maths.collisions"

Spawner = {
  spawn_timer = 30,
  enemies = nil,
  spawn_point = nil,
  enemy_bounds = nil,
  surface_bounds = nil
}

function Spawner:new(enemies_spawn_point, enemy_bounds, surface_bounds)
  local instance = {
    enemies = {},
    spawn_point = enemies_spawn_point,
    enemy_bounds = enemy_bounds,
    surface_bounds = surface_bounds
  }

  self.__index = self

  return setmetatable(instance, self)
end

function Spawner:addEnemyPack(direction, velocity, count, offset)
  self.spawn_point.x = math.random(self.surface_bounds.x)
  self.spawn_point.y = math.random(self.surface_bounds.y)

  table.insert(self.enemies,
               EnemyPack:new(direction, velocity, count, self, offset))
end

local function get_enemy_pack(spawner, index)
  local available_enemy_packs = #(spawner.enemies)

  if index < 0 or index > available_enemy_packs then return nil end

  for i, pack in ipairs(spawner.enemies) do if i == index then return pack end end
end

function Spawner:setEnemyPackSpeed(pack_index, velocity)
  local pack = get_enemy_pack(pack_index)
  if pack ~= nil then pack.velocity = velocity end
end

local function enemy_out_of_bounds(enemy) return enemy.x < 0 end

local function reset_enemy_position(enemy, spawner)
  if enemy_out_of_bounds(enemy) then
    enemy.x = spawner.surface_bounds.x + spawner.enemy_bounds.x
  end
end

function Spawner:moveEnemyPacks(dt)
  function move_enemy(enemy, velocity) enemy.x = enemy.x - velocity * dt end

  function move_enemy_pack(enemy_pack, spawner)
    local pack = enemy_pack.pack
    local enemy_pack_velocity = enemy_pack.velocity
    for _, enemy in ipairs(pack) do
      move_enemy(enemy, enemy_pack_velocity)
      reset_enemy_position(enemy, spawner)
    end

  end

  local enemy_packs = self.enemies
  for _, enemy_pack in ipairs(enemy_packs) do move_enemy_pack(enemy_pack, self) end

end

function Spawner:collidesWith(object_bounds)
  local collided = false

  function collided_with_player(enemy_pack)
    for _, enemy in ipairs(enemy_pack) do
      if collisions.collided(object_bounds, enemy) then
        collided = true
        break
      end
    end
  end

  local enemy_packs = self.enemies
  for _, enemy_pack in ipairs(enemy_packs) do
    collided_with_player(enemy_pack.pack)
  end

  return collided
end

function Spawner:drawEnemies(draw_function)
  local enemy_packs = self.enemies
  for i, enemy_pack in ipairs(enemy_packs) do
    local enemies = enemy_pack.pack
    for _, enemy in ipairs(enemies) do draw_function(enemy) end
  end
end
