
-- enemy_sprite = love.graphics.newImage("zombie-animation.png")
-- enemy_grid = anim8.newGrid(123, 80, enemy_sprite:getWidth(), enemy_sprite:getHeight())


all_enemies = { something = 1}

function all_enemies.create()
  createEnemyTimerMax = 1
  createEnemyTimer = createEnemyTimerMax
  enemyImg = love.graphics.newImage('img/nme.png')
  enemy_limit = 10
  enemies = {}
end

-- Enemy class
EnemyClass = {}
function EnemyClass:new()
  local new_obj = {}
  self.__index = self
  return setmetatable(new_obj, self)
end

function EnemyClass:create()

  --self:setUserData("enemy")

  -- self.destroy = function ()
  --   for i = 1, #enemies, 1 do
  --     if self == enemies[i] then
  --       enemies[i] = nil
  --     end
  --   end
  -- end
  --
  --
  -- self.anm_walk = anim8.newAnimation(enemy_grid("1-6", 1), 0.2)
  -- self.anm_death = anim8.newAnimation(enemy_grid("1-6", 2), 0.2, self.destroy)
  -- self.anm = self.anm_walk

  local random_number = math.random(10, love.graphics.getWidth() - 10)
  self.x = random_number
  self.y = h
  self.a = 0
  self.alive = true
  self.img = enemyImg

  self.x_velocity = 0
  -- self.body = HC.rectangle(self.x, self.y, enemyImg:getWidth()*scale, enemyImg:getHeight()*scale)

end

function all_enemies.draw()
  for i, enemy in ipairs(enemies) do

    -- temp for testing
    if i == 1 then
      love.graphics.setColor(0, 50, 255, 90)
    end

    enemy:draw()

    -- temp for testing
    if i == 1 then
      love.graphics.setColor(255, 255, 255)
    end

  end
end

function EnemyClass:draw()
  love.graphics.draw(self.img, self.x, self.y, self.a, 1*scale, 1*scale)
  -- love.graphics.setColor(0, 255, 0, 90)
  -- self.body:draw('fill')
  -- love.graphics.setColor(255, 255, 255)
end

function all_enemies.update(dt)
  if cat.active == 1 then

    createEnemyTimer = createEnemyTimer - (1 * dt)
    if createEnemyTimer < 0 then
      if table.getn(enemies) < enemy_limit then
        createEnemyTimer = createEnemyTimerMax
        enemies[#enemies + 1] = EnemyClass:new()
        enemies[#enemies]:create()
      end
    end

    for i, enemy in ipairs(enemies) do
      enemy:update(dt, i)
    end

  end

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

    for i, enemy in ipairs(enemies) do

      if i == 1 then
        -- enemy.x, enemy.y, enemy.img:getWidth()*scale, enemy.img:getHeight()*scale, enemy.a
        -- a = polygon{v(enemy.x, enemy.y),v(0,1),v(1,1),v(1,0)}
        -- b = polygon{v(cat.x, cat.y),v(0,1),v(1,1),v(1,0)}

      end

      if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth()*scale, enemy.img:getHeight()*scale, cat.x-((cat.height*scale)/2), cat.y-((cat.width*scale)/2), (cat.height*scale), (cat.width*scale)) then
        -- print("hit")
        enemy.alive = false
      end

    end

    -- for i, enemy in ipairs(enemies) do
    --   if sat(enemy, cat) then
    --     print("hello")
    --   end
    -- end

  end
end

function EnemyClass:update(dt, i)

    if player.lazers == true then
      speed = 15
      background_speed = 200
    else
      speed = 70
      background_speed = 0
    end

    if self.alive == true then
      self.y = self.y -( speed * dt )

      --the following is for special missile
      self.x = self.x - self.x_velocity * dt
      if self.x > cat.x then
        self.x_velocity = self.x_velocity + speed * dt
      else
        self.x_velocity = self.x_velocity - speed * dt
      end
      local kitty_x = cat.x
      local kitty_y = cat.y
      local angle = math.atan2((kitty_y - self.y), (kitty_x - self.x))
      self.a = angle

    end

    if self.y < -love.graphics.getHeight()/10 then -- remove enemies when they pass off the screen
      table.remove(enemies, i)
    end

    -- self.body:moveTo(self.x+(enemyImg:getWidth()/2), self.y+(enemyImg:getHeight()/2))

end
