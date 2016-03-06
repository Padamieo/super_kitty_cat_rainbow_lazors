local menu = {}

local input = {text = ""}

function menu:enter()
  print("menu")
  love.graphics.setBackgroundColor( 0, 10, 25 )
  start = 0

  hh = love.graphics.getHeight()
  ww = love.graphics.getWidth()

  font = love.graphics.newFont(30) -- the number denotes the font size
  love.graphics.setFont(font)
  --love.graphics.setNewFont(size)

end

function menu:update(dt)

  suit.enterFrame() -- https://love2d.org/forums/viewtopic.php?f=5&t=81522&start=20 -- SHOULD NOT BE NEEDED BUT SUIT IS A LITTLE BROKEN

  if(love.graphics.getWidth() == ww)then
  else
    ww = love.graphics.getWidth()
  end

  suit.layout:reset(ww/4,100*scale)
  suit.Input(input, suit.layout:row(ww/2,60*scale))
  suit.Label("Hello, "..input.text, {align = "left"}, suit.layout:row())
  suit.layout:row()

  if suit.Button("Start", suit.layout:row()).hit then
    start = 1
  end

  suit.layout:row()

  if suit.Button("Close", suit.layout:row()).hit then
    love.event.quit()
  end

  if start == 1 then
    gamestate.switch(game)
  end

end

function menu:draw()
  --cam:attach()
    --love.graphics.print("Press g to continue", 10, 10)
    suit.draw()
  --cam:detach()

love.graphics.print(total_score, ww-100, hh-150)
end

function menu:keyreleased(key, code)

    if key == 'g' then
        gamestate.switch(game)
    end
end

return menu
