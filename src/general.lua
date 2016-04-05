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

function math.round(n, deci)
  deci = 10^(deci or 0)
  return math.floor(n*deci+.5)/deci
end

t, shakeDuration, shakeMagnitude = 0, -1, 0
function startShake(duration, magnitude)
    t, shakeDuration, shakeMagnitude = 0, duration or 1, magnitude or 5
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1
end




-- vectors are just lists
-- segments are tables: {start = vect, end = vect, dir = vect}
-- polygons includes {vertices = {vectors}, edge = {vectors}}

function vec(x, y)
	return {x, y}
end

-- v = vec -- shortcut

function dot(v1, v2)
	return v1[1]*v2[1] + v1[2]*v2[2]
end

function normalize(v)
	local mag = math.sqrt(v[1]^2 + v[2]^2)
	return vec(v[1]/mag, v[2]/mag)
end

function perp(v)
	return {v[2],-v[1]}
end

function segment(a, b)
	local obj = {a=a, b=b, dir={b[1] - a[1], b[2] - a[2]}}
	obj[1] = obj.dir[1]; obj[2] = obj.dir[2]
	return obj
end

function polygon(vertices)
	local obj = {}
	obj.vertices = vertices
	obj.edges = {}
	for i=1,#vertices do
		table.insert(obj.edges, segment(vertices[i], vertices[1+i%(#vertices)]))
	end
	return obj
end

function project(a, axis)
	axis = normalize(axis)
	local min = dot(a.vertices[1],axis)
	local max = min
	for i,v in ipairs(a.vertices) do
		local proj =  dot(v, axis) -- projection
		if proj < min then min = proj end
		if proj > max then max = proj end
	end

	return {min, max}
end

function contains(n, range)
	local a, b = range[1], range[2]
	if b < a then a = b; b = range[1] end
	return n >= a and n <= b
end

function overlap(a_, b_)
	if contains(a_[1], b_) then return true
	elseif contains(a_[2], b_) then return true
	elseif contains(b_[1], a_) then return true
	elseif contains(b_[2], a_) then return true
	end
	return false
end


function sat(a, b)
	for i,v in ipairs(a.edges) do
		local axis = perp(v)
		local a_, b_ = project(a, axis), project(b, axis)
		if not overlap(a_, b_) then return false end
	end
	for i,v in ipairs(b.edges) do
		local axis = perp(v)
		local a_, b_ = project(a, axis), project(b, axis)
		if not overlap(a_, b_) then return false end
	end

	return true
end
