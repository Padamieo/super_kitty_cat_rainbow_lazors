
cat = {}

function cat.create()

  local characters = {
    default = { height = 200, width = 200, image = 'img/placeholder_kitty.png' } -- placeholder_kitty
  }

  local x_value = (w/2)
  local y_value = ((h/4)*3)

  cat.active = 0
  cat.x = x_value
  cat.y = y_value
  cat.a = 0
  cat.y_velocity = 0
  cat.dead = false

  cat.image = love.graphics.newImage(characters["default"].image)
  cat.height = characters["default"].height
  cat.width = characters["default"].width
  anim = anim8.newGrid(cat.height, cat.width, cat.image:getWidth(), cat.image:getHeight())
  cat.anim = {
    wait = anim8.newAnimation(anim('2-2', 1), 0.1),
    rainbow = anim8.newAnimation(anim('1-1', 1), 0.1)
  }
  local body = ((cat.height*scale)/3.5)
  cat.body = HC.circle(0,0,body)

end

function cat.draw()
  love.graphics.setColor(255, 255, 255)
  if cat.dir == 'fire' then
    cat.anim.rainbow:draw(cat.image, cat.x, cat.y, cat.a,  1*scale, 1*scale, cat.height/2, cat.width/2)
  else
    cat.anim.wait:draw(cat.image, cat.x, cat.y, cat.a,  1*scale, 1*scale, cat.height/2, cat.width/2)
  end
  love.graphics.setColor(255, 0, 0, 90)
  cat.body:draw('fill')
  love.graphics.setColor(255, 255, 255)
end

function cat.update(dt)

  if player.lazers == true then
    offset = cat.y-(h/8)
    --print(offset)
    cat.y = cat.y - (offset*1*dt)
    cat.y_velocity = 0
    cat.dir = 'fire'

    -- player.x
  else
    if cat.active == 1 then
      cat.dir = 'n'
      cat.y = cat.y - cat.y_velocity * dt
      cat.y_velocity = cat.y_velocity - gravity * dt
    else
      cat.dir = 'n'
    end
  end
  cat.body:moveTo(cat.x, cat.y)

  --animation set
  if cat.dir == 'fire' then
    --startShake(1, 1)
    cat.anim.rainbow:update(dt)
  else
    cat.anim.wait:update(dt)
  end

  -- if below edge end game return to menu for now
  if (cat.y > h-(h/10)) then
    lives = lives - 1
    if score > total_score then
      total_score = score
    end
    if lives == 8 then
      death_timestap = os.time()
      love.filesystem.write("scores.lua", total_score .. "\n" .. lives .. "\n" .. death_timestap)
    else
      love.filesystem.write("scores.lua", total_score .. "\n" .. lives .. "\n" .. death_timestap)
    end
    cat.dead = true
  end

end
