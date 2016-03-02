
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

--game = require "game"

anim8 = require 'resources.anim8'
flux = require 'resources.flux'

require 'general' -- not sure this helps with speed and performance

HC = require 'resources.HC'
local text = {}

function love.load()
  --shader = love.graphics.newShader("v.glsl")
  --love.window.setMode(0,0,{resizable = true,vsync = false}) -- apprently will fullscreen android
  gamestate.registerEvents()
  gamestate.switch(menu)

  circle = {size = 0}
  -- local count = 10
  -- function sequence()
  -- -- Abort if we hit our repeat limit
  -- count = count - 1               -- Omit this to repeat forever
  -- if count == 0 then return end   -- and this
  --   -- Do tween
  --   flux.to(circle, 2, { size = 100 }):ease("elasticout")
  --     :after(circle, 1, { size = 0 }):ease("quadin")
  --     :oncomplete(sequence) -- Intialise the next iteration of the sequence
  -- end
  -- -- Intialise the first iteration of the sequence
  -- sequence()

end

player = {touch = 0, lazers = false, fire = false, x = 0, y = 0, start = 0, endtime = 0}
cat = {active = 0}
--following to go in game.lua but bellow for development
game = {}

-- Load some default values for our rectangle.
function game:enter()
  --love.window.setMode(0,0,{resizable = true,vsync = false})
  first_move = 0
  scale = love.window.getPixelScale( )

  world = {}
  love.physics.setMeter(10)
  world = love.physics.newWorld(0, 80, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

  characters = {
    default = { height = 50, width = 50, image = 'img/placeholder_kitty.png' }
  }

  h = love.graphics.getHeight()
  w = love.graphics.getWidth()
  x_value = (w/2)
  y_value = ((h/4)*3)

  cat = {active = 0, x = x_value, y = y_value, image = nil }
  cat.image = love.graphics.newImage(characters["default"].image)
  anim = anim8.newGrid(200, 200, cat.image:getWidth(), cat.image:getHeight())
  cat.anim = {
    s = anim8.newAnimation(anim('1-1', 1), 0.1),
    se = anim8.newAnimation(anim('1-1', 1), 0.1)
  }

  cat.body = love.physics.newBody(world, cat.x, cat.y, "dynamic") -- static or kinematic
  cat.shape = love.physics.newRectangleShape(characters["default"].height, characters["default"].width)
  cat.fixture = love.physics.newFixture(cat.body, cat.shape)
  cat.fixture:setRestitution(0.9) -- bounce
  cat.body:setMass(100)
  cat.b = HC.circle(600,600,70)

  --enemies
  createEnemyTimerMax = 1
  createEnemyTimer = createEnemyTimerMax
  enemyImg = love.graphics.newImage('img/nme.png')
  enemy_limit = 10
  enemies = {}

  --bullets
  canShoot = true
  canShootTimerMax = 0.2
  canShootTimer = canShootTimerMax
  bulletImg = love.graphics.newImage('img/b.png')
  bullets = {}

  --test hc
  rect = HC.rectangle(200,400,400,20)
  mouse = HC.circle(400,300,20)
  mouse:moveTo(love.mouse.getPosition())

    function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
      return x1 < x2+w2 and
              x2 < x1+w1 and
              y1 < y2+h2 and
              y2 < y1+h1
    end

local imgg = love.graphics.newImage('img/b.png')
psystem = love.graphics.newParticleSystem(imgg, 32)
psystem:setParticleLifetime(2, 5) -- Particles live at least 2s and at most 5s.
--psystem:setEmissionRate(20)
psystem:setSizeVariation(0.5)
psystem:setLinearAcceleration(-600, -600, 600, 600) -- Random movement in all directions.
psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.

end



function game:update(dt)

  -- dt_time = dt
  -- shader:send("dt_time", dt_time)

  if cat.active == 1 then
    world:update(dt) -- physics
  end

  if love.keyboard.isDown('escape') then
    love.event.push("quit")
  end

  if player.lazers == true then

    offset = cat.body:getY()-(h/8)
    cat.body:setY(cat.body:getY() - (offset*1*dt))
    --cat.body:setLinearVelocity(0, offset*-2)
    cat.body:setLinearVelocity(0, 1)
    cat.dir = 'w'

  else
    cat.dir = 'n'
  end

  --animation set
  if cat.dir == 'w' then

  else
    cat.anim.s:update(dt)
  end

  -- if below edge end game return to menu for now
  if (cat.body:getY() > h-(h/10)) then
    return gamestate.switch(menu)
  end

  if player.touch == 1 then
    player.x = love.mouse.getX( )
    player.y = love.mouse.getY( )

    --do not like this timer seems off
    flux.to(circle, 0.3, {size = 100*scale }):ease("linear")

    if player.endtime ~= nil then
      time = love.timer.getTime( )
      if time > player.endtime then
        player.fire = false
        player.lazers = true
      end
      --print(player.endtime)
    end

  else

    --if released before fire lazer momentum
    if player.endtime ~= nil then
      time = love.timer.getTime( )
      if time < player.endtime then
        --need to probably spawn a fireball
        print('fire')
        player.fire = true
      end

    end
    --added to turn of circle size animation
    circle.size = 0

  end

  --enemey elements
  createEnemyTimer = createEnemyTimer - (1 * dt)
  if createEnemyTimer < 0 then
    if table.getn(enemies) < enemy_limit then
      createEnemyTimer = createEnemyTimerMax
      randomNumber = math.random(10, love.graphics.getWidth() - 10)

      newEnemy = { x = randomNumber, y = h, start_x = randomNumber, alive = true, img = enemyImg }

      table.insert(enemies, newEnemy)
    end
  end


  for i, enemy in ipairs(enemies) do
    -- enemy.y = enemy.y - (10 * dt)
    -- halfpost = love.graphics.getWidth()/2
    --
    -- vv = enemy.x + dt
    -- enemy.x = math.sin(vv) * enemy.start_x
    --
    -- if i == 1 then
    --   print(enemy.x)
    -- end
    --
    -- if enemy.x < love.graphics.getWidth() then
    --   --enemy.x = 100 * math.sin(dt*math.pi)
    --   if i == 1 then
    --     -- print(enemy.x)
    --   end
    --
    -- end
 -- enemy.x < 0+love.graphics.getWidth()/10 then
    -- flux.to(enemy, 0.3, {size = 50 }):ease("linear")

    if player.lazers == true then
      speed = 15
    else
      speed = 70
    end

    vv = ture
    if vv == true then
      enemy.y = enemy.y -( speed * dt )
    else
      enemy.y = enemy.y -( speed * dt )
    end


    if enemy.y < -love.graphics.getHeight()/10 then -- remove enemies when they pass off the screen
      table.remove(enemies, i)
    end
  end

  --bullet elements
  canShootTimer = canShootTimer - (0.3 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end

  -- either love.keyboard.isDown('z') or player.fire for now.
  if player.fire and canShoot then

    local mouseX = player.x
    local mouseY = player.y
    local angle = math.atan2((mouseY - cat.body:getY()), (mouseX - cat.body:getX()))

    local bulletDx = 800 * math.cos(angle)
    local bulletDy = 800 * math.sin(angle)

    newBullet = { x = cat.body:getX(), y = cat.body:getY(), dx = bulletDx, dy = bulletDy, a = angle, img = bulletImg }

    table.insert(bullets, newBullet)
    canShoot = false
    canShootTimer = canShootTimerMax
  end

  for i, bullet in ipairs(bullets) do

      bullet.x = bullet.x + (bullet.dx * dt)
      bullet.y = bullet.y + (bullet.dy * dt)

    if (bullet.x < -10) or (bullet.x > love.graphics.getWidth() + 10) or (bullet.y < -10) or (bullet.y > love.graphics.getHeight() + 10) then
    	table.remove(bullets, i)
    end
  end

  flux.update(dt)

  cat.b:moveTo(cat.body:getX(), cat.body:getY())
  --test hc
  mouse:moveTo(love.mouse.getPosition())
  rect:rotate(dt)
  for shape, delta in pairs(HC.collisions(mouse)) do
    text[#text+1] = string.format("Colliding. Separating vector = (%s,%s)", delta.x, delta.y)
  end
  while #text > 40 do
    table.remove(text, 1)
  end


  for i, enemy in ipairs(enemies) do
  	for j, bullet in ipairs(bullets) do
  		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
        psystem:emit(32)
  			table.remove(bullets, j)
  			table.remove(enemies, i)
  			--score = score + 1
  		end
  	end
    --
  	-- if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
  	-- and isAlive then
  	-- 	table.remove(enemies, i)
  	-- 	isAlive = false
  	-- end
  end

  psystem:update(dt)

  --update end
end


function love.touchpressed( id, x, y, pressure )
  print("touchpressed")
end


function love.mousepressed(x, y, button, istouch)

  if cat.active == 0 then
    cat.active = 1
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


function love.mousereleased( x, y, button, istouch )
  player.touch = 0
  player.lazers = false
  -- print(player.start)
  -- print(player.endtime)
  if player.fire == true then

  end
end


-- Draw a coloured rectangle.
function game:draw()

    -- if player.lazers == true then
    --   love.graphics.setShader(shader)
    -- else
    --   love.graphics.setShader()
    -- end

    if player.touch == 1 then
      --needs handling outside of lazers
      myColor = {255, 255, 255, 100}
      love.graphics.setColor(myColor)

      love.graphics.circle( "line", player.x, player.y, 100*scale, 100 )

      -- tween fluc maybe : https://love2d.org/forums/viewtopic.php?t=77904&p=168300
      love.graphics.circle( "fill", player.x, player.y, circle.size, 100*scale )

      if player.fire == true then
        love.graphics.line( player.x, player.y, cat.body:getX(), cat.body:getY() )
      end

    end

    love.graphics.setColor(250, 250, 250)

    --love.graphics.setColor(0, 88, 200)
    -- love.graphics.rectangle('fill', x, y, w, h)
    -- love.graphics.rectangle('fill', 80, 80, w, h)
    -- love.graphics.rectangle('fill', 250, 250, w, h)

    --love.graphics.setColor(250, 250, 250)

    if cat.dir == 'w' then
      cat.anim.s:draw(cat.image, cat.body:getX(), cat.body:getY(), cat.body:getAngle(),  1, 1, 100, 100)
    else
      cat.anim.s:draw(cat.image, cat.body:getX(), cat.body:getY(), cat.body:getAngle(),  1, 1, 100, 100)
    end

    -- draw enemies
    for i, enemy in ipairs(enemies) do
      love.graphics.draw(enemy.img, enemy.x, enemy.y)
    end

    -- draw bullets
    for i, bullet in ipairs(bullets) do
      love.graphics.draw(bullet.img, bullet.x, bullet.y, bullet.a)
    end

  -- HC test
  for i = 1,#text do
    love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
    love.graphics.print(text[#text - (i-1)], 10, i * 15)
  end
  love.graphics.setColor(255,255,255)
  rect:draw('fill')
  mouse:draw('fill')
  love.graphics.setColor(100,100,255,100)
  cat.b:draw('fill')

  love.graphics.draw(psystem, enemy.x, enemy.y)

end

return game
