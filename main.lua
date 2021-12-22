require "entity.player"
require "utils.spawner"
require "maths.vector"
require "utils.scope_functions"

local collisions = require "maths.collisions"

local game_state = {
  pause_game = false,
  game_over = false,
  window_width = 1280,
  window_height = 720,
  player_hp_fmt = "HP: %d",
  player_points_fmt = "SCORE: %d",
  player_points = 0
}

local player_hp_text_coords = also(Vector:new(), function(hp_coords)
  hp_coords.x = 5
  hp_coords.y = 5
end)

local player_point_text_coords = also(Vector:new(), function(point_coords)
  point_coords.x = game_state.window_width - 125
  point_coords.y = 5
end)

local player_status_text_colors = {r = 10, b = 10, g = 10}

local game_over_text_colors = {r = 255, b = 0, g = 0}

local pause_text_colors = {r = 10, b = 10, g = 0}

local window_center = also(Vector:new(), function(window_center_coords)
  window_center_coords.x = (game_state.window_width / 2)
  window_center_coords.y = (game_state.window_height / 2)
end)

local enemies_bounds = 20

local spawner = Spawner:new(also(Vector:new(), function(spawn_point)
  spawn_point.x = game_state.window_width + enemies_bounds
  spawn_point.y = 50
end), also(Vector:new(), function(enemy_bounds)
  enemy_bounds.x = enemies_bounds
  enemy_bounds.y = enemies_bounds
end), also(Vector:new(), function(surface_bounds)
  surface_bounds.x = game_state.window_width
  surface_bounds.y = game_state.window_height
end))

local player = also(Player:new(), function(player)
  player:setVelocity(150, 150)
  player:setHp(200)
  player:setXY(0, game_state.window_height / 2)
end)

local function calculate_window_center(size)
  local offset_vector = also(Vector:new(), function(offset)
    offset.x = size * 2
    offset.y = size * 2
  end)

  return window_center - offset_vector
end

local function on_player_out_of_bounds()
  if collisions.out_of_bounds_x(player:getX(), game_state.window_width) then
    player:setX(0)
  end

  if collisions.out_of_bounds_y(player:getY(), game_state.window_height) then
    player:setY(0)
  end
end

local function on_player_pressed_key(dt)
  if love.keyboard.isDown("up") then player:moveUp(dt) end
  if love.keyboard.isDown("down") then player:moveDown(dt) end
  if love.keyboard.isDown("left") then player:moveLeft(dt) end
  if love.keyboard.isDown("right") then player:moveRight(dt) end

  if love.keyboard.isDown("space") and player:canDodge() then
    player.is_invisible = true
    player:setAnimation(PlayerAnimation.INVINCIBLE)
  end

  on_player_out_of_bounds()
end

local function on_key_pressed(dt) on_player_pressed_key(dt) end

local function add_enemies()

  local enemy_velocity = 250
  local total_enemies = 4
  local enemy_offset = 40

  for _ = 1, 4 do
    spawner:addEnemyPack(Direction.VERTICAL_LINE, enemy_velocity, total_enemies,
                         enemy_offset)

    spawner:addEnemyPack(Direction.HORIZONTAL_LINE, enemy_velocity,
                         total_enemies, enemy_offset)

    spawner:addEnemyPack(Direction.LEFT_DIAGONAL_LINE, enemy_velocity,
                         total_enemies, enemy_offset)

    spawner:addEnemyPack(Direction.RIGHT_DIAGONAL_LINE, enemy_velocity,
                         total_enemies, enemy_offset)

    spawner:addEnemyPack(Direction.UPWARDS_LEFT_DIAGONAL_LINE, enemy_velocity,
                         total_enemies, enemy_offset)

    spawner:addEnemyPack(Direction.UPWARDS_RIGHT_DIAGONAL_LINE, enemy_velocity,
                         total_enemies, enemy_offset)
  end
end

local function draw_enemies()
  love.graphics.setColor(10, 10, 10)

  spawner:drawEnemies(function(enemy)
    love.graphics.circle("fill", enemy.x, enemy.y, enemy.width)
  end)
end

local function drawText(color, font_size, text, coords)
  love.graphics.setColor(color.r, color.g, color.b)
  love.graphics.setNewFont(font_size)
  love.graphics.print(text, coords.x, coords.y)
end

local function handle_collisions()
  if not player.is_invisible then
    if spawner:collidesWith(player:getBounds()) then player:damage() end
  end
end

local function game_over() if player.hp <= 0 then game_state.game_over = true end end

function love.load()
  love.window.setMode(game_state.window_width, game_state.window_height, {})

  add_enemies()
end

function love.focus(focused) game_state.pause_game = not focused end

local function update_game(dt)
  game_state.player_points = game_state.player_points + 1

  on_key_pressed(dt)

  player:update(dt)

  spawner:moveEnemyPacks(dt)

  handle_collisions()

  game_over()
end

function love.update(dt)
  if not game_state.pause_game and (not game_state.game_over) then
    update_game(dt)
  end
end

local function draw_game()
  drawText(player_status_text_colors, 15,
           string.format(game_state.player_hp_fmt, player.hp),
           player_hp_text_coords)

  drawText(player_status_text_colors, 15, string.format(
               game_state.player_points_fmt, game_state.player_points),
           player_point_text_coords)

  player:draw()

  draw_enemies()
end

local function draw_game_over_screen()
  drawText(game_over_text_colors, 50, "GAME OVER!!", calculate_window_center(90))

  drawText(player_status_text_colors, 50, string.format(
               game_state.player_points_fmt, game_state.player_points),
           also(calculate_window_center(78),
                function(score_coords) score_coords.y = score_coords.y + 90 end))
end

function love.draw()
  if not game_state.pause_game and (not game_state.game_over) then
    draw_game()
  elseif game_state.pause_game then
    drawText(pause_text_colors, 50, "PAUSED", calculate_window_center(50))
  else
    draw_game_over_screen()
  end
end
