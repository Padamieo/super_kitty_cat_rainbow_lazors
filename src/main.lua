
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

camera = require "resources.camera"
cam = 0
anim8 = require 'resources.anim8'
flux = require 'resources.flux'

require 'general' -- not sure this helps with speed and performance

function love.load()
  --shader = love.graphics.newShader("v.glsl")
  --love.window.setMode(0,0,{resizable = true,vsync = false}) -- apprently will fullscreen android
  cam = camera(0,0,1, 0)
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

  --obb = love.graphics.circle( "fill", player.x, player.y, 1, 100 )


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
end




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

  -- if below edge end game return to menu for now
  if (player.body:getY() > h-(h/10)) then
    return gamestate.switch(menu)
  end

  if player.touch == 1 then
    player.x = love.mouse.getX( )
    player.y = love.mouse.getY( )

    --do not like this timer seems off
    flux.to(circle, 0.3, {size = 50 }):ease("linear")

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

      newEnemy = { x = randomNumber, y = love.graphics.getHeight(), start_x = randomNumber, img = enemyImg }

      table.insert(enemies, newEnemy)
    end
  end

  for i, enemy in ipairs(enemies) do
    enemy.y = enemy.y - (10 * dt)
    halfpost = love.graphics.getWidth()/2

    if enemy.x < love.graphics.getWidth() then
      enemy.x = 100 * math.tan(dt*math.pi) + enemy.start_x
      if i == 1 then
        print(enemy.x)
      end

    end
 -- enemy.x < 0+love.graphics.getWidth()/10 then
    -- flux.to(enemy, 0.3, {size = 50 }):ease("linear")



    if enemy.y < -love.graphics.getHeight()/10 then -- remove enemies when they pass off the screen
      table.remove(enemies, i)
    end
  end


  --bullet elements
  canShootTimer = canShootTimer - (0.5 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end

  if love.keyboard.isDown('z') and canShoot then

    --newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
    --player.body:getY()
    newBullet = { x = player.body:getX(), y = player.body:getY(), img = bulletImg }
    --newBullet = { x = (love.graphics.getWidth()/2), y = (love.graphics.getHeight()/2), img = bulletImg }

    table.insert(bullets, newBullet)
    canShoot = false
    canShootTimer = canShootTimerMax
  end

  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (250 * dt)

    if bullet.y < 0 then -- remove bullets when they pass off the screen
    	table.remove(bullets, i)
    end
  end

  --camera:scale(g) -- zoom by 3
  cam:move(player.x, player.y)
  flux.update(dt)

end




function love.touchpressed( id, x, y, pressure )
  print("touchpressed")

end


function love.mousepressed(x, y, button, istouch)

  if player.active == 0 then
    player.active = 1
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
    --cam:attach()

    -- if player.lazers == true then
    --   love.graphics.setShader(shader)
    -- else
    --   love.graphics.setShader()
    -- end

    if player.touch == 1 then
      --needs handling outside of lazers
      myColor = {255, 255, 255, 100}
      love.graphics.setColor(myColor)
      love.graphics.circle( "fill", player.x, player.y, 50, 100 )

      -- tween fluc maybe : https://love2d.org/forums/viewtopic.php?t=77904&p=168300
      love.graphics.circle( "fill", player.x, player.y, circle.size, 100 )

      if player.fire == true then
        love.graphics.line( player.x, player.y, player.body:getX(), player.body:getY() )
      end

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

    -- draw enemies
    for i, enemy in ipairs(enemies) do
      love.graphics.draw(enemy.img, enemy.x, enemy.y)
    end

    -- draw bullets
    for i, bullet in ipairs(bullets) do
      love.graphics.draw(bullet.img, bullet.x, bullet.y)
    end

    --cam:detach()
end



return game
