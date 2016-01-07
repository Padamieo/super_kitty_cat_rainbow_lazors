
--https://www.youtube.com/watch?v=Ueya18MrtaA

debug = true

gamestate = require "resources.gamestate"

--load in lick for better development
lick = require "resources.lick"
lick.reset = true

--define game states and functions to be included
menu = require "menu"

--game = require "game"

camera = require "camera"
anim8 = require 'resources.anim8'

require 'general' -- not sure this helps with speed and performance


function love.load()
    dt = 0
    p1joystick = nil
    gamestate.registerEvents()

    gamestate.switch(menu)
end



-- menu_team = {}
--
-- function menu_team:enter()
--     love.graphics.setBackgroundColor( 105, 133, 150 )
-- end
--
-- function menu_team:draw()
--     love.graphics.print("Press g to continue", 10, 10)
--
-- end
--
-- function menu_team:keyreleased(key, code)
--
--     if key == 'g' then
--         gamestate.switch(game)
--     end
-- end



--following to go in game.lua but bellow for development
game = {}

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
