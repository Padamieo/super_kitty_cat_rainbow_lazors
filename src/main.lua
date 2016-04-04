
--https://www.youtube.com/watch?v=Ueya18MrtaA
-- look at scale  https://love2d.org/forums/viewtopic.php?f=11&t=80262
-- http://www.osmstudios.com/tutorials/your-first-love2d-game-in-200-lines-part-3-of-3
debug = true

gamestate = require "resources.gamestate"
suit = require "resources.SUIT"

--load in lick for better development
lick = require "resources.lick"
lick.reset = true

--define game states and functions to be included
menu = require "menu"
--game = require "game" -- currently bellow

anim8 = require 'resources.anim8'

require 'rainbow' -- brings the fire animation object
require 'general' -- not sure this helps with speed and performance
require 'enemy'
require 'cat'

HC = require 'resources.HC'
local text = {}

global = {state = ''}

function love.load()
  --shader = love.graphics.newShader("v.glsl")
  --love.window.setMode(0,0,{resizable = true,vsync = false}) -- apprently will fullscreen android

  scale = love.window.getPixelScale( )
  total_score = 0
  lives = 9

  gamestate.registerEvents()
  gamestate.switch(menu)

  circle = {size = 0, max = 80, duration = 0.8}

  data = {}

  if not love.filesystem.exists("scores.lua") then
    scores = love.filesystem.newFile("score.lua")
    love.filesystem.write("scores.lua", total_score .. "\n" .. lives)
  end

  for lines in love.filesystem.lines("scores.lua") do
    table.insert(data, lines)
  end

  total_score = tonumber(data[1])
  lives = tonumber(data[2])
  death_timestap = tonumber(data[3])

  more_lives()

end

function more_lives()
  local os_time = os.time()

  if lives <= 8 then

    nice_seconds = os_time - (death_timestap + 30)
    print(nice_seconds)

    local ts = death_timestap + 30
    if os_time >= ts then
      death_timestap = death_timestap + 30
      lives = lives + 1
      love.filesystem.write("scores.lua", total_score .. "\n" .. lives .. "\n" .. death_timestap)
    end
  end
end

player = {touch = 0, lazers = false, x = 0, y = 0, start = 0, endtime = 0, starttime}

--following to go in game.lua but bellow for development
game = {}

-- Load some default values for our rectangle.
function game:enter()

  global.state = 'game'

  -- love.window.setMode(400,700,{vsync = false})
  score = 0
  gravity = 100

  h = love.graphics.getHeight()
  w = love.graphics.getWidth()

  --create our cat character
  cat.create()

  -- create the rainbow fire object
  rainbow.create()

  --enemies
  all_enemies.create()

  --bullets
  canShoot = true
  canShootTimerMax = 0.1
  canShootTimer = canShootTimerMax

  bullets = {}
  bullets.image = love.graphics.newImage('img/b.png')

  -- need multipl of this particle system for on demand explotions
  local imgg = love.graphics.newImage('img/b.png')
  psystem = love.graphics.newParticleSystem(imgg, 32)
  psystem:setParticleLifetime(1, 3) -- Particles live at least 2s and at most 5s.
  --psystem:setEmissionRate(20)
  psystem:setSizeVariation(0.5)
  psystem:setLinearAcceleration(-400, -700, 400, 700) -- Random movement in all directions.
  psystem:setSpin(10)
  psystem:setSpinVariation(2, 6)
  psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.

  font = love.graphics.newFont(30) -- the number denotes the font size
  love.graphics.setFont(font)

  bg1 = {}
  bg1.img = love.graphics.newImage("img/background_wall_temp.png")
  bg1.y = 0
  bg1.height = bg1.img:getHeight()

  bg2 = {}
  bg2.img = love.graphics.newImage("img/background_wall_temp.png")
  bg2.y = -love.graphics.getWidth()-bg2.img:getHeight()
  bg2.height = bg2.img:getHeight()

  background_speed = 200

  --sound setup
  s1 = love.audio.newSource("sound/hh.wav", "static")
  s2 = love.audio.newSource("sound/hl.wav", "static")

  firesound = {s1,s2}
  fireset = 1
  --src1:setPitch(0.5) -- one octave lower

end
-- game enter end


function game:update(dt)

  -- dt_time = dt
  -- shader:send("dt_time", dt_time)

  if love.keyboard.isDown('escape') then
    love.event.push("quit")
  end

  -- for playing around with screen shake
  if love.keyboard.isDown('m') then
    startShake(1, 1)
  end

  cat.update(dt)

  if cat.dead == true then
    return gamestate.switch(menu)
  end

  -- animation for rainbow fire
  rainbow.update(dt)

  if player.touch == 1 then
    player.x = love.mouse.getX( )
    player.y = love.mouse.getY( )

    -- controls cirlce size animation
    if player.endtime ~= nil then
      if player.start ~= nil then
        change_in_time = love.timer.getTime( ) - player.start
        if circle.size <= circle.max then
          circle.size = change_in_time * (circle.max / circle.duration)
        end
      end
    end

    -- checks if end time has passed
    if player.endtime ~= nil then
      time = love.timer.getTime( )
      if time > player.endtime then
        player.lazers = true
        canShoot = false
      end
    end

  else
    --canShoot = true
    --added to turn of circle size animation
    circle.size = 0

  end

  --enemey elements
  all_enemies.update(dt)

  --bullet elements
  canShootTimer = canShootTimer - (0.3 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end

  for i, bullet in ipairs(bullets) do

      bullet.x = bullet.x + (bullet.dx * dt)
      bullet.y = bullet.y + (bullet.dy * dt)

    if (bullet.x < -10) or (bullet.x > love.graphics.getWidth() + 10) or (bullet.y < -10) or (bullet.y > love.graphics.getHeight() + 10) then
    	table.remove(bullets, i)
    end
  end

  -- for i, enemy in ipairs(enemies) do
  -- 	for j, bullet in ipairs(bullets) do
  -- 		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth()*scale, enemy.img:getHeight()*scale, bullet.x, bullet.y, bullets.image:getWidth()*scale, bullets.image:getHeight()*scale) then
  --       psystem:moveTo( enemy.x, enemy.y )
  --       psystem:emit(32)
  -- 			table.remove(bullets, j)
  -- 			table.remove(enemies, i)
  -- 			score = score + 1
  -- 		end
  -- 	end
  -- end

  psystem:update(dt)

  if t < shakeDuration then
    t = t + dt
  end

  bg1.y = bg1.y + background_speed * dt
  bg2.y = bg2.y + background_speed * dt

  if bg1.y > love.graphics.getHeight() then
    bg1.y = bg2.y - bg1.height
  end

  if bg2.y > love.graphics.getHeight() then
    bg2.y = bg1.y - bg2.height
  end

end
-- update end

function love.touchpressed( id, x, y, pressure )
  print("touchpressed")
end

function love.mousepressed(x, y, button, istouch)
  if global.state == 'game' then
    circle.size = 0

    if cat.active == 0 then
      cat.active = 1
      player.touch = 1
      player.start = love.timer.getTime( )
      player.endtime = love.timer.getTime( ) + 0.8
    else

      player.touch = 1
      player.start = love.timer.getTime( )
      player.endtime = love.timer.getTime( ) + 0.8

      if istouch then
        print("istouch")
      else
        print("notouch")
      end
    end
  end
end
-- end of mousepressed


function love.mousereleased( x, y, button, istouch )
  if global.state == 'game' then
    player.touch = 0
    player.lazers = false
    circle.size = 0

    --if player.endtime ~= nil then
    time = love.timer.getTime( )
    if time < player.endtime and canShoot then

      local mouseX = player.x
      local mouseY = player.y
      local angle = math.atan2((mouseY - cat.y), (mouseX - cat.x))

      if h > 800 then
        fire_speed = h
      else
        fire_speed = 800
      end

      local bulletDx = fire_speed * math.cos(angle)
      local bulletDy = fire_speed * math.sin(angle)

      newBullet = { x = cat.x, y = cat.y, dx = bulletDx, dy = bulletDy, a = angle }

      table.insert(bullets, newBullet)
      canShoot = false
      canShootTimer = canShootTimerMax

      if fireset == 2 then
        fireset = 1
      else
        fireset = fireset + 1
      end
      firesound[fireset]:play()
    end
    --end
  end
end
-- end of mousereleased



-- game draw.
function game:draw()

  -- if player.lazers == true then
  --love.graphics.setShader(shader)
  -- else
  --   love.graphics.setShader()
  -- end

  love.graphics.setColor(255,255,255,255)
  love.graphics.draw(bg1.img, 0, bg1.y)
  love.graphics.draw(bg2.img, 0, bg2.y)

  if player.touch == 1 then
    --needs handling outside of lazers
    myColor = {255, 255, 255, 100}
    love.graphics.setColor(myColor)
    love.graphics.circle( "line", player.x, player.y, circle.max*scale, 25 )
    love.graphics.circle( "fill", player.x, player.y, circle.size*scale, circle.max*scale, 25 )
    --love.graphics.line( player.x, player.y, cat.body:getX(), cat.body:getY() )
  end

  --draw the cat character
  cat.draw()

  --draw the rainbow
  rainbow.draw()

  --draw enemies
  all_enemies.draw()

  -- draw bullets
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullets.image, bullet.x, bullet.y, bullet.a, 1*scale, 1*scale)
  end

  love.graphics.setColor(255,200,200)
  love.graphics.draw(psystem)

  love.graphics.setColor(255,255,255, 100)
  love.graphics.print(score, 10, hh-30)

  -- screen shake bit
  if t < shakeDuration then
    local dx = love.math.random(-shakeMagnitude, shakeMagnitude)
    local dy = love.math.random(-shakeMagnitude, shakeMagnitude)
    love.graphics.translate(dx, dy)
  else
    -- need way to reset the traslate that happend, screen shake mess
  end

  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
  --love.graphics.setShader()

end
-- end of game draw

return game
