-- Configuration
function love.conf(t)
	t.title = "SKCRL" -- The title of the window the game is in (string)
	t.version = "0.10.0"         -- The LÖVE version this game was made for (string)
	t.window.width = 400        -- we want our game to be long and thin.
	t.window.height = 700
	t.window.fullscreen = false        -- Enable fullscreen (boolean)
	t.window.resizable = true
	-- For Windows debugging
	t.console = true
end
