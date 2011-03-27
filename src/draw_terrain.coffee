#### Drawing a height map as a grid of tiles

# Set variables for the canvas width and height, tile width and height
# and the size of the grid, i.e. 32×32, and also set the `multiplier` 
# which determines what a height value (0 to 255) should be translated
# into in pixels.
#
# Size should be a power of 2.

canvas_width  = 530
canvas_height = 430

tile_width    = 32
tile_height   = 24
size          = 16
multiplier    = 0.35

start_x       = canvas_width / 2
start_y       = 48

# Get the canvas and initialise its context, create the height map with
# a size of `size + 1`. Go through some of the context's functions and 
# make them chainable.

@initialise = () ->
	canvas = document.getElementById "terrain"
	@context       = canvas.getContext "2d"
	@height_map    = new HeightMap(size + 1)
	@context.__proto__["set"] = (k,v) ->
		this[k] = v
		this
	for f in [
		"arc"
		"beginPath"
		"closePath"
		"fill"
		"lineTo"
		"moveTo"
		"set"
		"stroke"
	]
		@context.__proto__[f] = chain(@context.__proto__[f])
	null	

# Given a function `f`, chain will return a new function that
# is identical except that, if no value is returned, `this` will be 
# returned instead.

@chain = (f) ->
	() ->
		f.apply(this, arguments)||this

# If there are any operations left in `height_map`'s queue then
# use `setInterval` to call the `draw_step` function once every 100 milliseconds
@draw_run = () ->
	if @height_map.remaining()
		@interval_id = setInterval(@draw_step,100)

# Call `height_map.step()`, which progresses terrain generation by a single
# diamond and square step, and then draw the results on the canvas with the 
# `draw()` function. If there are no operations left in `height_map`'s queue then
# use clearInterval to stop calling `draw_step`.
@draw_step = () ->
	@height_map.step()
	@draw()
	if !@height_map.remaining()
		clearInterval(@interval_id)

# Reset `height_map` and draw the results.
@draw_reset = () ->
	@height_map.reset()
	@draw()
		
# Clear the canvas and then go through each tile and draw it.

@draw = () ->
	@context.clearRect(0,0,canvas_width,canvas_height)
	for y in [0..size-1]
		for x in  [0..size-1]
			@draw_tile(x,y)
	null

# Draw an individual tile on an isometric grid.

@draw_tile = (x,y) ->
	# The `tile` function returns a hash containing four keys, nw, ne, sw, se, each 
	# with an associated height value.
	tile = @height_map.tile(x,y)
	# For each of these height values, scale it so that it looks good when displayed.
	for point, height of tile
		tile[point] = @scale_height(height)
	# The location of each tile is based on an isometric grid.
	#
	# As `x` increases the tile moves along the row, diagonally down and to the right, increasing x and increasing y.
	# As `y` increases the tile moves along the column, diagonally down and to the left, decreasing x and increasing y.
	# If `x` and `y` increase at the same rate then the tile moves straight downward, leaving x as it is and increasing y.
	x_position = start_x + (x * tile_width  / 2) - (y * tile_width  / 2)
	y_position = start_y + (x * tile_height / 2) + (y * tile_height / 2)
	# Draw the tile as two polygons, a polygon for the back triangle, NW -> NE -> SW -> NW
	@context
		.beginPath()
		.set("fillStyle", @colour(tile.nw, (tile.ne + tile.sw) / 2))
		.moveTo(x_position                 , y_position - tile.nw)
		.lineTo(x_position + tile_width / 2, y_position - tile.ne + tile_height / 2)
		.lineTo(x_position - tile_width / 2, y_position - tile.sw + tile_height / 2)
		.fill()
		.closePath()
	# and a polygon for the front triangle, SE -> NE -> SW -> SE
	@context
		.beginPath()
		.set("fillStyle", @colour((tile.ne + tile.sw) / 2, tile.se))
		.moveTo(x_position                 , y_position - tile.se + tile_height)
		.lineTo(x_position + tile_width / 2, y_position - tile.ne + tile_height / 2)
		.lineTo(x_position - tile_width / 2, y_position - tile.sw + tile_height / 2)
		.fill()
	  .closePath()
	tile

# Given a height value, multiply it by the `multiplier` to get a bigger or smaller value.
# This is just to make the visualisation look better.

@scale_height = (h) ->
	if h?
		Math.floor h * multiplier	
	else
		null

# Based on the ratio between `top` and `bottom`, return a color.

@colour = (top, bottom) ->
	r = Math.floor(((top - bottom) * 2.5) + 150)
	g = 191
	b = 64
	"rgb(#{r},#{g},#{b})"