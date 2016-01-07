local menu = {}

function menu:enter()
    love.graphics.setBackgroundColor( 0, 10, 25 )
end

function menu:draw()
    love.graphics.print("Press g to continue", 10, 10)
end

function menu:keyreleased(key, code)

    if key == 'g' then
        gamestate.switch(game)
    end
end

return menu
