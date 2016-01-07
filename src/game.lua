local game = {}

-- Load some default values for our rectangle.
function game:enter()
  love.graphics.setBackgroundColor( 111, 10, 25 )
  x, y, w, h = 20, 20, 60, 20;
  g = 1
end

-- Increase the size of the rectangle every frame.
function game:update(dt)

  if love.keyboard.isDown('escape') then
    love.event.push("quit")
  end

  w = w + 0.1

  --zoom is broken
  if love.keyboard.isDown('-') then
    g = g - 0.01
  elseif love.keyboard.isDown('=') then
    g = g + 0.01
  else
    g = g
  end

  camera:scale(g) -- zoom by 3
end

-- Draw a coloured rectangle.
function game:draw()
    camera:set()
    love.graphics.setColor(0, 88, 200);
    love.graphics.rectangle('fill', x, y, w, h);
    love.graphics.rectangle('fill', 80, 80, w, h);
    love.graphics.rectangle('fill', 250, 250, w, h);
    camera:unset()
end

return game
