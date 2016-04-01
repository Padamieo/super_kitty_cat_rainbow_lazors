


rainbow = {}

function rainbow.create()

  rainbow.loop_sprite = love.graphics.newImage('img/rainbow_r.png')
  rainbow.start_sprite = love.graphics.newImage('img/rainbow.png')

  rainbow_grid = anim8.newGrid(200, 500, rainbow.loop_sprite:getWidth(), rainbow.loop_sprite:getHeight())

  rainbow_grid2 = anim8.newGrid(200, 500, rainbow.start_sprite:getWidth(), rainbow.start_sprite:getHeight())



  --   start = anim8.newAnimation(anim('1-10', 1, '1-10', 2, '1-4', 3), 0.05, boop),
  --   loop = anim8.newAnimation(anim('1-10', 1, '1-10', 2, '1-4', 3), 0.05)

  rainbow.loop = anim8.newAnimation(rainbow_grid('1-10', 1, '1-10', 2, '1-4', 3), 0.05)

  rainbow.start = anim8.newAnimation(rainbow_grid2('9-10', 2, '1-10', 1, '1-8', 2), 0.05, rainbow.destroy)
  --anim8.newAnimation(enemy_grid("1-6", 2), 0.2, rainbow.destroy)

  rainbow.sprite = rainbow.start_sprite
  -- Set moving as default animation
  rainbow.anim = rainbow.start
  rainbow.store = 0
end

rainbow.destroy = function ()
  if cat.active == 1 then

    print('noticeme')
    print(rainbow.store)
    rainbow.store = rainbow.store+1
    if rainbow.store > 1 then
      rainbow.sprite = rainbow.loop_sprite
      rainbow.anim = rainbow.loop
    end

  end
end

function rainbow.draw()

  --rainbow.anm:draw(enemy_sprite, 0, 0, rainbow.body:getAngle())
  rainbow.anim:draw(rainbow.sprite, cat.body:getX(), cat.body:getY()+(250*scale), cat.body:getAngle(),  1*factor, 1*factor, 100, 100)

end

function rainbow.update(dt)

  -- Play animation
  rainbow.anim:update(dt)

end
