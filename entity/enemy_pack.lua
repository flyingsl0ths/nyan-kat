require "maths.bounds"
require "utils.scope_functions"

Direction = {
  HORIZONTAL_LINE = 0,
  VERTICAL_LINE = 1,
  LEFT_DIAGONAL_LINE = 2,
  RIGHT_DIAGONAL_LINE = 3,
  UPWARDS_LEFT_DIAGONAL_LINE = 4,
  UPWARDS_RIGHT_DIAGONAL_LINE = 5
}

EnemyPack = {direction_function = nil, velocity = 250, pack = nil}

local function horizontal_line(spawner, last_enemy, offset)
  spawner.spawn_point.x = spawner.spawn_point.x + spawner.enemy_bounds.x +
                              offset

  last_enemy.x = spawner.spawn_point.x
end

local function vertical_line(spawner, last_enemy, offset)
  spawner.spawn_point.y = spawner.spawn_point.y + spawner.enemy_bounds.y +
                              offset

  last_enemy.y = spawner.spawn_point.y
end

local function right_diagonal_line(spawner, last_enemy, offset)
  spawner.spawn_point.x = spawner.spawn_point.x + spawner.enemy_bounds.x +
                              offset

  spawner.spawn_point.y = spawner.spawn_point.y + spawner.enemy_bounds.y +
                              offset

  last_enemy.x = spawner.spawn_point.x

  last_enemy.y = spawner.spawn_point.y
end

local function left_diagonal_line(spawner, last_enemy, offset)
  spawner.spawn_point.x = spawner.spawn_point.x - spawner.enemy_bounds.x +
                              offset

  spawner.spawn_point.y = spawner.spawn_point.y + spawner.enemy_bounds.y +
                              offset

  last_enemy.x = spawner.spawn_point.x

  last_enemy.y = spawner.spawn_point.y
end

local function upwards_left_diagonal_line(spawner, last_enemy, offset)
  spawner.spawn_point.x = spawner.spawn_point.x - spawner.enemy_bounds.x +
                              offset

  spawner.spawn_point.y = spawner.spawn_point.y - spawner.enemy_bounds.y +
                              offset

  last_enemy.x = spawner.spawn_point.x

  last_enemy.y = spawner.spawn_point.y
end

local function upwards_right_diagonal_line(spawner, last_enemy, offset)
  spawner.spawn_point.x = spawner.spawn_point.x + spawner.enemy_bounds.x -
                              offset

  spawner.spawn_point.y = spawner.spawn_point.y - spawner.enemy_bounds.y +
                              offset

  last_enemy.x = spawner.spawn_point.x

  last_enemy.y = spawner.spawn_point.y
end

local function get_direction_function(direction)
  local direction_function = horizontal_line

  if direction == Direction.HORIZONTAL_LINE then return direction_function end

  if direction == Direction.VERTICAL_LINE then
    direction_function = vertical_line
  elseif direction == Direction.LEFT_DIAGONAL_LINE then
    direction_function = left_diagonal_line
  elseif direction == Direction.RIGHT_DIAGONAL_LINE then
    direction_function = right_diagonal_line
  elseif direction == Direction.UPWARDS_LEFT_DIAGONAL_LINE then
    direction_function = upwards_left_diagonal_line
  elseif direction == Direction.UPWARDS_RIGHT_DIAGONAL_LINE then
    direction_function = upwards_right_diagonal_line
  end

  return direction_function
end

local function create_enemy(spawner)
  local enemy = Bounds:new(spawner.spawn_point.x, spawner.spawn_point.y,
                           spawner.enemy_bounds.x, spawner.enemy_bounds.y)
  return enemy
end

local function insert_enemies(enemy_count, pack, spawner, direction_function,
                              offset)
  if enemy_count < 1 then return end

  table.insert(pack, create_enemy(spawner))

  function insert_enemy()
    local last = create_enemy(spawner)

    direction_function(spawner, last, offset)

    table.insert(pack, last)
  end

  for _ = 1, enemy_count do insert_enemy() end

  return pack
end

function EnemyPack:new(direction, enemy_velocity, enemy_count, spawner, offset)
  local direction_func = get_direction_function(direction)

  local instance = {
    direction_function = direction_func,
    enemy_velocity = enemy_velocity,
    pack = insert_enemies(enemy_count, {}, spawner, direction_func, offset)
  }

  self.__index = self

  return setmetatable(instance, self)
end
