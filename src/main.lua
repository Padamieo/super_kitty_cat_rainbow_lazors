
--https://www.youtube.com/watch?v=Ueya18MrtaA
-- look at scale  https://love2d.org/forums/viewtopic.php?f=11&t=80262

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
  shader = love.graphics.newShader("v.glsl")
  --love.window.setMode(0,0,{resizable = true,vsync = false}) -- apprently will fullscreen android

  gamestate.registerEvents()
  gamestate.switch(menu)
end

player = {touch = 0, lazers = false, x = 0, y = 0, start = 0, endtime = 0}

--following to go in game.lua but bellow for development
game = {}

-- Load some default values for our rectangle.
function game:enter()
  --love.window.setMode(0,0,{resizable = true,vsync = false})
  first_move = 0

  world = {}
  love.physics.setMeter(10)
  world = love.physics.newWorld(0, 80, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

  characters = {
    default = { height = 200, width = 200, image = 'img/placeholder_kitty.png' }
  }

  h = love.graphics.getHeight()
  w = love.graphics.getWidth()
  x_value = (w/2)
  y_value = ((h/4)*3)

  player = {active = 0, x = x_value, y = y_value, image = nil }
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
  hv = 0
  lv = 0
end


-- Increase the size of the rectangle every frame.
function game:update(dt)

  -- print(iSystem.iGlobalTime)
  -- dt_time = dt
  -- shader:send("dt_time", dt_time)

  if player.active == 1 then
    world:update(dt) -- physics
  end

  if love.keyboard.isDown('escape') then
    love.event.push("quit")
  end

  if player.lazers == true then
    --player.body:applyForce( -10000, 0 )
    --player.body:setLinearVelocity( -player.speed, 0 )
    --print(player.body:getY())

    offset = player.body:getY()-(h/8)
    player.body:setY(player.body:getY() - (offset*1*dt))
    --player.body:setLinearVelocity(0, offset*-2)
    player.body:setLinearVelocity(0, 1)
    player.dir = 'w'

  else
    player.dir = 'n'
  end

  --animation set
  if player.dir == 'w' then

  else
    player.anim.s:update(dt)
  end

  -- if bellow edge end game return to menu for now
  if (player.body:getY() > h-(h/10)) then
    return gamestate.switch(menu)
  end

  if player.touch == 1 then
    player.x = love.mouse.getX( )
    player.y = love.mouse.getY( )
  end

  camera:scale(g) -- zoom by 3
end


function love.touchpressed( id, x, y, pressure )
  print("touchpressed")

end


function love.mousepressed(x, y, button, istouch)

  if player.active == 0 then
    player.active = 1
  else

    player.touch = 1
    player.lazers = true

    if player.endtime == 0 then

      player.start = love.timer.getTime( )
      player.endtime = love.timer.getTime( ) + 500
    else
      time = love.timer.getTime( )
      print(player.endtime)
      -- print(player.endtime)
      -- if time >= player.endtime then
      --  player.lazers = true
      -- end
    end

    if istouch then
      print("istouch")
    else
      print("notouch")
    end
  end

end

function love.mousereleased( x, y, button, istouch )
  player.touch = 0
  player.lazers = false
  -- print(player.start)
  -- print(player.endtime)
end


-- Draw a coloured rectangle.
function game:draw()
    camera:set()

    if player.lazers == true then
      love.graphics.setShader(shader)
    else
      love.graphics.setShader()
    end

    if player.touch == 1 then
      --needs handling outside of lazers
      myColor = {255, 255, 255, 100}
      love.graphics.setColor(myColor)
      love.graphics.circle( "fill", player.x, player.y, 50, 100 )
    end

    love.graphics.setColor(250, 250, 250)

    --love.graphics.setColor(0, 88, 200)
    -- love.graphics.rectangle('fill', x, y, w, h)
    -- love.graphics.rectangle('fill', 80, 80, w, h)
    -- love.graphics.rectangle('fill', 250, 250, w, h)

    --love.graphics.setColor(250, 250, 250)

    if player.dir == 'w' then
      player.anim.s:draw(player.image, player.body:getX(), player.body:getY(), player.body:getAngle(),  1, 1, 100, 100)
    else
      player.anim.s:draw(player.image, player.body:getX(), player.body:getY(), player.body:getAngle(),  1, 1, 100, 100)
    end

    camera:unset()
end



return game
