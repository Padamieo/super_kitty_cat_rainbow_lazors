-- Import anim8
local anim8 = require("anim8")

-- Load zombie sprite
enemy_sprite = love.graphics.newImage("zombie-animation.png")
-- Create animation grid with frame's width 123, frame's height 80 and
-- grid's width/height as sprite's width/height
enemy_grid = anim8.newGrid(123, 80, enemy_sprite:getWidth(), enemy_sprite:getHeight())

enemies = {}

-- Enemy class
EnemyClass = {}
function EnemyClass:new()
 local new_obj = {}
 self.__index = self
 return setmetatable(new_obj, self)
end

function EnemyClass:create()
 -- Position
 local x, y

 -- We need to check distance between zomie and player becase
 -- zombie must be created not too close to player
 local near_player = true
 while near_player do
  -- Random coordinates
  x = love.math.random(0, love.graphics.getWidth())
  y = love.math.random(0, love.graphics.getHeight())

  -- Distance between player and zombie by X
  local dist_x = math.abs(player.body:getX() - x)

  -- Distance between player and zombie by Y
  local dist_y = math.abs(player.body:getY() - y)

  -- If distance > 100 by X and Y then quit loop
  if dist_x > 100 and dist_y > 100 then
   near_player = false
  end
 end

 -- Body, shape, fixture
 self.body = love.physics.newBody(world, x, y, "dynamic")
 self.shape = love.physics.newCircleShape(25)
 self.fix = love.physics.newFixture(self.body, self.shape, 5)
 self.fix:setUserData("enemy")

 -- Self-destroy function. Declared as table element (not as method).
 -- When you create animation you can set which function will be executed
 -- on animation playing end. With method (self:method()) you will get
 -- an error, but with function as table element it work fine.
 self.destroy = function ()
  for i = 1, #enemies, 1 do
   if self == enemies[i] then
    enemies[i] = nil
   end
  end
 end

 -- Enemy animation
 -- Moving - set grid and frames from 1 to 6 in 1st row with
 -- playing speed 0.2
 self.anm_walk = anim8.newAnimation(enemy_grid("1-6", 1), 0.2)

 -- Enemy death - set grid and frames from 1 to 6 in 2nd row with playing
 -- speed 0.2. On animation playing end will be executed self.destroy()
 self.anm_death = anim8.newAnimation(enemy_grid("1-6", 2), 0.2, self.destroy)

 -- Set moving as default animation
 self.anm = self.anm_walk
end

function EnemyClass:draw()
 -- Because we need frame's with body's center in one point
 -- get coordinates moved above and left  to half of frame width or
 -- height
 local draw_x, draw_y = self.body:getWorldPoint(-40, -40)
 -- Draw animation
 self.anm:draw(enemy_sprite, draw_x, draw_y, self.body:getAngle())
end

function EnemyClass:update(dt)
 -- Position
 local x, y = self.body:getPosition()

 -- Play animation
 self.anm:update(dt)

 -- If fixture's userData is false,
 -- enemy was killed, show death animation.
 if not self.fix:getUserData() then
  self.anm = self.anm_death
 -- Else move enemy to player
 else
  -- X coordinate
  -- Coordinates are float (not integer), we need to floor (round)
  -- it, else enemy can do "convulsice tweeches" because to the
  -- difference in tenths
  if math.floor(player.body:getX() - x) ~= 0 then
   -- If difference < 0 than player to the left of enemy
   -- Move enemy to left
   if (player.body:getX() - x) < 0 then
    x = x - 20*dt
   -- Else move enemy to right
   else
    x = x + 20*dt
   end
  end

  -- Y coordinate
  if math.floor(player.body:getY() - y) ~= 0 then
   -- If difference < 0 than, move enemy to top
   if (player.body:getY() - y) < 0 then
    y = y - 20*dt
   -- Else move enemy to bottom
   else
    y = y + 20*dt
   end
  end

  -- Angle enemy to player
  local direction = math.atan2(player.body:getY() - y,
          player.body:getX() - x)
  self.body:setAngle(direction)
  -- Update enemy position
  self.body:setPosition(x, y)
 end
end
