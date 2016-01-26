local menu = {}

local input = {text = ""}

function menu:enter()
  print("menu")
  love.graphics.setBackgroundColor( 0, 10, 25 )
  start = 0
end

function menu:update()

  suit.enterFrame() -- https://love2d.org/forums/viewtopic.php?f=5&t=81522&start=20 -- SHOULD NOT BE NEEDED BUT SUIT IS A LITTLE BROKEN

  suit.layout:reset(100,100)
  suit.Input(input, suit.layout:row(200,40))
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
    --love.graphics.print("Press g to continue", 10, 10)
    suit.draw()
end

function menu:keyreleased(key, code)

    if key == 'g' then
        gamestate.switch(game)
    end
end

return menu
