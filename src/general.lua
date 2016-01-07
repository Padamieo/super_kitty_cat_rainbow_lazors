-- orders y depth
function orderY(a,b)
  return a.body:getY() < b.body:getY()
end

--determines distance from figures
function distance(value,value2)
  d = value - value2
  d = math.abs(d)
  return d
end

--determine n is number
function is_int(n)
  return (type(n) == "number") and (math.floor(n) == n)
end

--returns only positive number
function positive_num(value)
  if value > 0 then
    value = value*-1
  end
  return value
end

function set_zoom()
  --h = love.graphics.getHeight()
  local w = love.graphics.getWidth()
  return 1920 / w
end
