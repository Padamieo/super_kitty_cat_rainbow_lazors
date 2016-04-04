local menu = {}

local input = {text = ""}

function menu:enter()

  global.state = 'menu'

  suit.theme.color = {
    normal  = {bg = { 66, 66, 66, 90}, fg = {188,188,188}},
    hovered = {bg = { 50,153,187}, fg = {255,255,255}},
    active  = {bg = {255,153,0}, fg = {225,225,225}}
  }

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

  --suit.Input(input, suit.layout:row(ww/2,60*scale))
  --suit.Label("Hello, "..input.text, {align = "left"}, suit.layout:row())

  suit.layout:row(ww/2,60*scale)

  if suit.Button("Start", suit.layout:row()).hit then
    start = 1
  end

  suit.layout:row()

  if suit.Button("Options", suit.layout:row()).hit then
    --start = 1
  end

  suit.layout:row()

  if suit.Button("Close", suit.layout:row()).hit then
    love.event.quit()
  end

  suit.layout:row()

  if lives >= 1 then
    if start == 1 then
      gamestate.switch(game)
    end
  else
    if start == 1 then
      --pop up to say out of lives
    end
  end

  -- need to only call this once every 20 minutes or something
  more_lives()

end

function menu:draw()
  suit.draw()

  love.graphics.print(total_score, ww-(ww/3), hh-150)
  love.graphics.print(lives, ww-((ww/3)*2), hh-150)

end

return menu
