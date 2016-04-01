rainbow = {}

function rainbow.create()

  rainbow.loop_sprite = love.graphics.newImage('img/rainbow_r.png')
  rainbow.start_sprite = love.graphics.newImage('img/rainbow.png')
  rainbow_grid = anim8.newGrid(200, 500, rainbow.loop_sprite:getWidth(), rainbow.loop_sprite:getHeight())
  rainbow_grid_two = anim8.newGrid(200, 500, rainbow.start_sprite:getWidth(), rainbow.start_sprite:getHeight())

  factor = ww/200

  rainbow.loop = anim8.newAnimation(rainbow_grid('1-10', 1, '1-10', 2, '1-4', 3), 0.05)
  rainbow.start = anim8.newAnimation(rainbow_grid_two('1-10', 1, '1-8', 2), 0.05, rainbow.destroy)

  rainbow.sprite = rainbow.start_sprite
  rainbow.anim = rainbow.start
  rainbow.store = 0
end

rainbow.destroy = function ()
  rainbow.store = rainbow.store+1
  if rainbow.store == 1 then
    rainbow.sprite = rainbow.loop_sprite
    rainbow.anim = rainbow.loop
    rainbow.anim:gotoFrame(1)
  end
end

function rainbow.draw()

  rainbow.anim:draw(rainbow.sprite, cat.body:getX(), cat.body:getY()+(250*scale), cat.body:getAngle(),  1*factor, 1*factor, 100, 100)

end

function rainbow.update(dt)
  if cat.dir == 'fire' then
    if rainbow.store == 0 then
      rainbow.sprite = rainbow.start_sprite
      rainbow.anim = rainbow.start
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
