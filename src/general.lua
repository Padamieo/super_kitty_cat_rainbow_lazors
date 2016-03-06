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

t, shakeDuration, shakeMagnitude = 0, -1, 0
function startShake(duration, magnitude)
    t, shakeDuration, shakeMagnitude = 0, duration or 1, magnitude or 5
end
