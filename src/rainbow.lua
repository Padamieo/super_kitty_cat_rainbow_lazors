rainbow = {}

function rainbow.create()

  rainbow.loop_sprite = love.graphics.newImage('img/rainbow_r.png')
  rainbow.start_sprite = love.graphics.newImage('img/rainbow.png')
  rainbow.finish_sprite = love.graphics.newImage('img/rainbow_e.png')

  rainbow_grid_one = anim8.newGrid(200, 500, rainbow.loop_sprite:getWidth(), rainbow.loop_sprite:getHeight())
  rainbow_grid_two = anim8.newGrid(200, 500, rainbow.start_sprite:getWidth(), rainbow.start_sprite:getHeight())
  rainbow_grid_thr = anim8.newGrid(200, 500, rainbow.finish_sprite:getWidth(), rainbow.finish_sprite:getHeight())

  factor = ww/200

  rainbow.loop = anim8.newAnimation(rainbow_grid_one('1-10', 1, '1-10', 2, '1-4', 3), 0.05)
  rainbow.start = anim8.newAnimation(rainbow_grid_two('1-10', 1, '1-8', 2), 0.05, rainbow.répéter)
  rainbow.finish = anim8.newAnimation(rainbow_grid_thr('1-10', 1), 0.05, rainbow.complete)

  rainbow.sprite = rainbow.start_sprite
  rainbow.anim = rainbow.start
  rainbow.store = 0
end

rainbow.répéter = function ()
  rainbow.store = rainbow.store+1
  if rainbow.store == 1 then
    rainbow.sprite = rainbow.loop_sprite
    rainbow.anim = rainbow.loop
    rainbow.anim:gotoFrame(1)
  end
end

rainbow.complete = function ()
  rainbow.store = rainbow.store+1
  if rainbow.store == 2 then
    rainbow.sprite = rainbow.start_sprite
    rainbow.anim = rainbow.start
    rainbow.anim:gotoFrame(1)
    rainbow.store = 0
  end

end

function rainbow.draw()
  love.graphics.setColor(0,255,0,90)
  if cat.dir == 'fire' then
    rainbow.anim:draw(rainbow.sprite, cat.body:getX(), cat.body:getY()+(250*scale), cat.body:getAngle(),  1*factor, 1*factor, 100, 100)
  else
    if rainbow.store >= 1 then
      rainbow.anim:draw(rainbow.sprite, cat.body:getX(), cat.body:getY()+(250*scale), cat.body:getAngle(),  1*factor, 1*factor, 100, 100)
    end
  end
  love.graphics.setColor(255,255,255)
end

function rainbow.update(dt)
  if cat.dir == 'fire' then
    if rainbow.store == 0 then
      --startShake(1, 1) -- currently screen shake is an issue
      rainbow.sprite = rainbow.start_sprite
      rainbow.anim = rainbow.start
    end
    rainbow.anim:resume()
    rainbow.anim:update(dt)
  else
    if rainbow.store >= 1 then
      if rainbow.store == 1 then
        rainbow.sprite = rainbow.finish_sprite
        rainbow.anim = rainbow.finish
      end
      rainbow.anim:resume()
      rainbow.anim:update(dt)
    else
      rainbow.sprite = rainbow.start_sprite
      rainbow.anim = rainbow.start
      rainbow.anim:pauseAtStart()
      rainbow.store = 0
    end
  end
end
