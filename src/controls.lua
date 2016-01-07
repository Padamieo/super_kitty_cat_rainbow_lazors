
function love.load(arg)
  p1joystick = nil
end

function love.joystickadded(joystick)
    p1joystick = joystick
end

function love.update(dt)
  -- Check if joystick connected
  if p1joystick ~= nil then
      -- getGamepadAxis returns a value between -1 and 1.
      -- It returns 0 when it is at rest
    x = p1joystick:getGamepadAxis("leftx")
    if x > 0.2 then
      player.x = player.x + ((player.speed*x)*dt)
      print(x)
    elseif x < -0.2 then
      newx = x*-1
      player.x = player.x - ((player.speed*newx)*dt)
      print(x)
    end

    y = p1joystick:getGamepadAxis("lefty")
    if y > 0.2 then
      player.y = player.y + ((player.speed*y)*dt)
      print(y)
    elseif y < -0.2 then
      newy = y*-1
      player.y = player.y - ((player.speed*newy)*dt)
      print(y)
    end
      --y = y + p1joystick:getGamepadAxis("lefty")
      --print(y)
  end

end
