
--https://www.youtube.com/watch?v=Ueya18MrtaA

debug = true

gamestate = require "resources.gamestate"
suit = require "resources.SUIT"

--load in lick for better development
lick = require "resources.lick"
lick.reset = true

--define game states and functions to be included
menu = require "menu"

--game = require "game"

camera = require "camera"
anim8 = require 'resources.anim8'

require 'general' -- not sure this helps with speed and performance

function love.load()
  gamestate.registerEvents()
  gamestate.switch(menu)
end


-- local menu = {}
--
-- function menu:enter()
--     love.graphics.setBackgroundColor( 0, 10, 25 )
-- end
--
-- function menu:draw()
--     love.graphics.print("Press g to continue", 10, 10)
-- end
--
-- function menu:keyreleased(key, code)
--
--     if key == 'g' then
--         gamestate.switch(game)
--     end
-- end
--
-- return menu



--following to go in game.lua but bellow for development
game = {}

-- Load some default values for our rectangle.
function game:enter()

  world = {}
  love.physics.setMeter(10)
  world = love.physics.newWorld(0, 80, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

  love.graphics.setBackgroundColor( 111, 10, 25 )
  x, y, w, h = 20, 20, 60, 20
  g = 1

  characters = {
    default = { height = 200, width = 200, image = 'img/placeholder_kitty.png' }
  }

  h = love.graphics.getHeight()
  w = love.graphics.getWidth()
  x_value = (w/2)
  y_value = ((h/4)*3)

  player = { x = x_value, y = y_value, image = nil }
  player.image = love.graphics.newImage(characters["default"].image)
  --anii = anim8.newGrid(350, 350, player.image:getWidth(), player.image:getHeight())
  aa = anim8.newGrid(200, 200, player.image:getWidth(), player.image:getHeight())
  player.anim = {
    s = anim8.newAnimation(aa('1-1', 1), 0.1),
    se = anim8.newAnimation(aa('1-1', 1), 0.1)
  }

  player.body = love.physics.newBody(world, player.x, player.y, "dynamic") -- static or kinematic
  player.shape = love.physics.newRectangleShape(characters["default"].height, characters["default"].width)
  player.fixture = love.physics.newFixture(player.body, player.shape)
  player.fixture:setRestitution(0.9) -- bounce
  --player.body:setLinearDamping( 0.9 )
  player.body:setMass(100)
end


-- Increase the size of the rectangle every frame.
function game:update(dt)
  world:update(dt) -- physics

  if love.keyboard.isDown('escape') then
    love.event.push("quit")
  end

  w = w + 0.1

  --zoom is broken
  if love.keyboard.isDown('-') then
    g = g - 0.01
  elseif love.keyboard.isDown('=') then
    g = g + 0.01
  else
    g = g
  end

  if (player.body:getY() > h) then
    menu = require "menu"
    gamestate.switch(menu)
  end

  if love.keyboard.isDown('up','w') then
    --player.body:applyForce( -10000, 0 )
    --player.body:setLinearVelocity( -player.speed, 0 )
    --print(player.body:getY())

    offset = player.body:getY()-80
    player.body:setY(player.body:getY() - (offset*1*dt))
    player.body:setLinearVelocity(0, 1)
    player.dir = 'w'

  else
    player.dir = 'n'
  end

  if player.dir == 'w' then

  else
    player.anim.s:update(dt)
  end

  camera:scale(g) -- zoom by 3
end

-- Draw a coloured rectangle.
function game:draw()
    camera:set()
    love.graphics.setColor(0, 88, 200)
    -- love.graphics.rectangle('fill', x, y, w, h)
    -- love.graphics.rectangle('fill', 80, 80, w, h)
    -- love.graphics.rectangle('fill', 250, 250, w, h)

    love.graphics.setColor(250, 250, 250)

    if player.dir == 'w' then
      player.anim.s:draw(player.image, player.body:getX(), player.body:getY(), player.body:getAngle(),  1, 1, 100, 100)
    else
      player.anim.s:draw(player.image, player.body:getX(), player.body:getY(), player.body:getAngle(),  1, 1, 100, 100)
    end

    camera:unset()
end

return game
