local menu = {}

local input = {text = ""}

function menu:enter()
    love.graphics.setBackgroundColor( 0, 10, 25 )
end

function menu:update()

  suit.layout:reset(100,100)
  suit.Input(input, suit.layout:row(200,40))
  suit.Label("Hello, "..input.text, {align = "left"}, suit.layout:row())
  suit.layout:row()

  if suit.Button("Start", suit.layout:row()).hit then
    gamestate.switch(game)
  end

  suit.layout:row()

  if suit.Button("Close", suit.layout:row()).hit then
    love.event.quit()
  end

end

function menu:draw()
    love.graphics.print("Press g to continue", 10, 10)
    suit.draw()
end

function menu:keyreleased(key, code)

    if key == 'g' then
        gamestate.switch(game)
    end
end

return menu
