
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

  scale = love.window.getPixelScale( )
  total_score = 0
  lives = 9

  gamestate.registerEvents()
  gamestate.switch(menu)

  circle = {size = 0}


  data = {}

  --tt = os.time()

  if not love.filesystem.exists("scores.lua") then
    scores = love.filesystem.newFile("score.lua")
    love.filesystem.write("scores.lua", total_score .. "\n" .. lives)
  end
  for lines in love.filesystem.lines("scores.lua") do
    table.insert(data, lines)
  end

  total_score = tonumber(data[1])
  lives = tonumber(data[2])

end

player = {touch = 0, lazers = false, x = 0, y = 0, start = 0, endtime = 0}
cat = {active = 0}

--following to go in game.lua but bellow for development
game = {}

-- Load some default values for our rectangle.
function game:enter()



  --love.window.setMode(0,0,{resizable = true,vsync = false})
  first_move = 0
  score = 0

  world = {}
  love.physics.setMeter(10)
  world = love.physics.newWorld(0, 80, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

  characters = {
    default = { height = 50, width = 50, image = 'img/placeholder_kitty.png' } -- placeholder_kitty
  }

  h = love.graphics.getHeight()
  w = love.graphics.getWidth()
  x_value = (w/2)
  y_value = ((h/4)*3)

  cat = {active = 0, x = x_value, y = y_value, image = nil }
  cat.image = love.graphics.newImage(characters["default"].image)
  anim = anim8.newGrid(200, 200, cat.image:getWidth(), cat.image:getHeight())
  cat.anim = {
    wait = anim8.newAnimation(anim('2-2', 1), 0.1),
    rainbow = anim8.newAnimation(anim('1-1', 1), 0.1)
  }

  cat.body = love.physics.newBody(world, cat.x, cat.y, "dynamic") -- static or kinematic
  cat.shape = love.physics.newRectangleShape(characters["default"].height*scale, characters["default"].width*scale)
  cat.fixture = love.physics.newFixture(cat.body, cat.shape)
  cat.fixture:setRestitution(0.9) -- bounce
  cat.body:setMass(100)
  cat.b = HC.circle(600,600,70)

  rainbow = {}
  rainbow_image = 'img/rainbow_r.png'
  rainbow.image = love.graphics.newImage(rainbow_image)

  factor = ww/200
  anim = anim8.newGrid(200, 500, rainbow.image:getWidth(), rainbow.image:getHeight())
  rainbow.anim = {
    start = anim8.newAnimation(anim('1-10', 1, '1-10', 2, '1-4', 3), 0.05),
    loop = anim8.newAnimation(anim('1-10', 1, '1-10', 2, '1-4', 3), 0.05)
  }

  --enemies
  createEnemyTimerMax = 1
  createEnemyTimer = createEnemyTimerMax
  enemyImg = love.graphics.newImage('img/nme.png')
  enemy_limit = 10
  enemies = {}

  --bullets
  canShoot = true
  canShootTimerMax = 0.1
  canShootTimer = canShootTimerMax

  bullets = {}
  bullets.image = love.graphics.newImage('img/b.png')

  -- bulletImg = 'img/b2.png'
  -- bullets.image = love.graphics.newImage(bulletImg)
  -- anim = anim8.newGrid(40, 20, bullets.image:getWidth(), bullets.image:getHeight())
  -- bullets.anim = {
  --   a = anim8.newAnimation(anim('1-3', 1), 0.1)
  -- }

  --test hc
  mouse = HC.circle(400,300,20)
  mouse:moveTo(love.mouse.getPosition())

  function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
  end

  -- need multipl of this particle system for on demand explotions
  local imgg = love.graphics.newImage('img/b.png')
  psystem = love.graphics.newParticleSystem(imgg, 32)
  psystem:setParticleLifetime(2, 5) -- Particles live at least 2s and at most 5s.
  --psystem:setEmissionRate(20)
  psystem:setSizeVariation(0.5)
  psystem:setLinearAcceleration(-600, -600, 600, 600) -- Random movement in all directions.
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

  s3 = love.audio.newSource("sound/hm.wav", "static")
  s4 = love.audio.newSource("sound/lh.wav", "static")

  s5 = love.audio.newSource("sound/ll.wav", "static")
  s6 = love.audio.newSource("sound/lm.wav", "static")

  s7 = love.audio.newSource("sound/mh.wav", "static")
  s8 = love.audio.newSource("sound/ml.wav", "static")

  firesound = {s1,s2,s3,s4,s5,s6,s7,s8}
  fireset = 1
  --src1:setPitch(0.5) -- one octave lower

  --game enter end
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

  -- for playing around with screen shake
  if love.keyboard.isDown('m') then
    startShake(1, 1)
  end

  if player.lazers == true then

    offset = cat.body:getY()-(h/8)
    cat.body:setY(cat.body:getY() - (offset*1*dt))
    --cat.body:setLinearVelocity(0, offset*-2)
    cat.body:setLinearVelocity(0, 1)
    cat.dir = 'fire'

  else
    cat.dir = 'n'
  end

  --animation set
  if cat.dir == 'fire' then
    --startShake(1, 1)
    cat.anim.rainbow:update(dt)
  else
    cat.anim.wait:update(dt)
  end

  -- animation for fire
  rainbow.anim.loop:update(dt)

  --will need this for enemy animation decided to drop for bullets as did not look right
  --bullets.anim.a:update(dt)

  -- if below edge end game return to menu for now
  if (cat.body:getY() > h-(h/10)) then
    lives = lives - 1
    if score > total_score then
      total_score = score
      love.filesystem.write("scores.lua", total_score .. "\n" .. lives)
    else
      love.filesystem.write("scores.lua", total_score .. "\n" .. lives)
    end

    return gamestate.switch(menu)
  end

  if player.touch == 1 then
    player.x = love.mouse.getX( )
    player.y = love.mouse.getY( )

    --do not like this timer seems off
    flux.to(circle, 0.3, {size = 80*scale }):ease("linear")

    if player.endtime ~= nil then
      time = love.timer.getTime( )
      if time > player.endtime then
        player.lazers = true
        canShoot = false
      end
      --print(player.endtime)
    end

  else
    --canShoot = true
    --added to turn of circle size animation
    circle.size = 0

  end

  --enemey elements
  if cat.active == 1 then
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
        background_speed = 200
      else
        speed = 70
        background_speed = 0
      end

      vv = true
      if vv == true then
        enemy.y = enemy.y -( speed * dt )
      else
        enemy.y = enemy.y -( speed * dt )
      end

      if enemy.y < -love.graphics.getHeight()/10 then -- remove enemies when they pass off the screen
        table.remove(enemies, i)
      end
    end
  end

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

  flux.update(dt)

  cat.b:moveTo(cat.body:getX(), cat.body:getY())
  --test hc
  mouse:moveTo(love.mouse.getPosition())

  -- for shape, delta in pairs(HC.collisions(mouse)) do
  --   text[#text+1] = string.format("Colliding. Separating vector = (%s,%s)", delta.x, delta.y)
  -- end
  -- while #text > 40 do
  --   table.remove(text, 1)
  -- end

  for i, enemy in ipairs(enemies) do
  	for j, bullet in ipairs(bullets) do
  		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth()*scale, enemy.img:getHeight()*scale, bullet.x, bullet.y, bullets.image:getWidth()*scale, bullets.image:getHeight()*scale) then
        psystem:moveTo( enemy.x, enemy.y )
        psystem:emit(32)
  			table.remove(bullets, j)
  			table.remove(enemies, i)
  			score = score + 1
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

  --update end
end


function love.touchpressed( id, x, y, pressure )
  print("touchpressed")
end


function love.mousepressed(x, y, button, istouch)
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


function love.mousereleased( x, y, button, istouch )
  player.touch = 0
  player.lazers = false
  circle.size = 0

  -- if player.endtime ~= nil then
  --   time = love.timer.getTime( )
  --   if time < player.endtime then
  --     -- spawn a fireball example
  --   end
  -- end

  --if player.endtime ~= nil then
    time = love.timer.getTime( )
    if time < player.endtime and canShoot then

      local mouseX = player.x
      local mouseY = player.y
      local angle = math.atan2((mouseY - cat.body:getY()), (mouseX - cat.body:getX()))

      local bulletDx = 800 * math.cos(angle)
      local bulletDy = 800 * math.sin(angle)

      newBullet = { x = cat.body:getX(), y = cat.body:getY(), dx = bulletDx, dy = bulletDy, a = angle }

      table.insert(bullets, newBullet)
      canShoot = false
      canShootTimer = canShootTimerMax

      if fireset == 8 then
        fireset = 1
      else
        fireset = fireset + 1
      end
      firesound[fireset]:play()
    end
  --end

end


-- Draw a coloured rectangle.
function game:draw()

  -- if player.lazers == true then
  --   love.graphics.setShader(shader)
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

    love.graphics.circle( "line", player.x, player.y, 80*scale, 25 )

    -- tween fluc maybe : https://love2d.org/forums/viewtopic.php?t=77904&p=168300
    love.graphics.circle( "fill", player.x, player.y, circle.size, 80*scale, 25 )

    --love.graphics.line( player.x, player.y, cat.body:getX(), cat.body:getY() )

  end

  love.graphics.setColor(250, 250, 250)

  --love.graphics.setColor(0, 88, 200)
  -- love.graphics.rectangle('fill', x, y, w, h)
  -- love.graphics.rectangle('fill', 80, 80, w, h)
  -- love.graphics.rectangle('fill', 250, 250, w, h)

  --love.graphics.setColor(250, 250, 250)

  if cat.dir == 'fire' then
    cat.anim.rainbow:draw(cat.image, cat.body:getX(), cat.body:getY(), cat.body:getAngle(),  1*scale, 1*scale, 100, 100)
    love.graphics.setColor(100,100,255,90)
    rainbow.anim.loop:draw(rainbow.image, cat.body:getX(), cat.body:getY()+(250*scale), cat.body:getAngle(),  1*factor, 1*factor, 100, 100)
    love.graphics.setColor(255,255,255)
  else
    cat.anim.wait:draw(cat.image, cat.body:getX(), cat.body:getY(), cat.body:getAngle(),  1*scale, 1*scale, 100, 100)
  end

  -- draw enemies
  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y, 0, 1*scale, 1*scale)
  end

  -- draw bullets
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullets.image, bullet.x, bullet.y, bullet.a, 1*scale, 1*scale)
    --bullets.anim.a:draw(bullet.img, bullet.x, bullet.y, bullet.a, 1*scale, 1*scale)
  end

-- HC test
-- for i = 1,#text do
--   love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
--   love.graphics.print(text[#text - (i-1)], 10, i * 15)
-- end

  love.graphics.setColor(255,255,255)
  mouse:draw('fill')
  love.graphics.setColor(100,100,255,100)
  cat.b:draw('fill')

  love.graphics.setColor(255,255,255)
  love.graphics.draw(psystem)

  love.graphics.setColor(255,255,255, 100)
  love.graphics.print(score, 10, hh-30)

  if t < shakeDuration then
    local dx = love.math.random(-shakeMagnitude, shakeMagnitude)
    local dy = love.math.random(-shakeMagnitude, shakeMagnitude)
    love.graphics.translate(dx, dy)
  end

  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

  --end of game draw
end

return game
