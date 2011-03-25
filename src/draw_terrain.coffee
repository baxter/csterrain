#### Drawing a height map as a grid of tiles

# Set variables for the canvas width and height, tile width and height
# and the size of the grid, i.e. 32×32, and also set the `multiplier` 
# which determines what a height value (0 to 255) should be translated
# into in pixels.
#
# Size should be a power of 2.

canvas_width  = 530
canvas_height = 530
# tile_width    = 16
# tile_height   = 12
# size          = 32 
tile_width    = 64
tile_height   = 48
size          = 8
multiplier    = 0.35
start_x       = canvas_width / 2
start_y       = 48

# Get the canvas and initialise its context, create the height map with
# a size of `size + 1`. Go through some of the context's methods and 
# make them chainable.

@initialise = () ->
	canvas = document.getElementById "terrain"
	if canvas.getContext
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
		
# Clear the canvas and then go through each tile and draw it.

@draw = () ->
	@context.clearRect(0,0,canvas_width,canvas_height)
	for y in [0..size-1]
		for x in  [0..size-1]
			@draw_tile(x,y)
	# for y in [0..size]
	# 	for x in [0..size]
	# 		@draw_point(x,y)
	null

# Draw an individual point

@draw_point = (x,y) ->
	point_height = @scale_height(@height_map.get_cell(x,y))
	console.log(point_height)
	if point_height?
		x_position = start_x + (x * tile_width  / 2) - (y * tile_width  / 2)
		y_position = start_y + (x * tile_height / 2) + (y * tile_height / 2)
		@context
			.beginPath()
			.set("fillStyle","#000000")
			.arc(x_position - 1, y_position - 1 - point_height, 2, 0, Math.PI*2, true)
			.fill()
			.closePath()

# Draw an individual tile.

@draw_tile = (x,y) ->
	tile = @height_map.tile(x,y)
	# Modify the values for display
	for point, height of tile
		tile[point] = @scale_height(height)
	x_position = start_x + (x * tile_width  / 2) - (y * tile_width  / 2)
	y_position = start_y + (x * tile_height / 2) + (y * tile_height / 2)
	# Draw a starting position
	@context
		.beginPath()
		.set("strokeStyle", "rgba(0,0,0,0.1)")
		.moveTo(x_position, y_position)
		.lineTo(x_position + tile_width / 2, y_position + tile_height / 2)
		.lineTo(x_position, y_position + tile_height)
		.lineTo(x_position - tile_width / 2, y_position + tile_height / 2)
		.lineTo(x_position, y_position)
		.stroke()
		.closePath()
	# TODO if there are enough points set, draw polygons
	# otherwise just draw points
	#   @draw_polygons tile
	@context
		.beginPath()
		.set("fillStyle", @color(tile.nw, (tile.ne + tile.sw) / 2))
		.moveTo(x_position                 , y_position - tile.nw)
		.lineTo(x_position + tile_width / 2, y_position - tile.ne + tile_height / 2)
		.lineTo(x_position - tile_width / 2, y_position - tile.sw + tile_height / 2)
		.fill()
		.closePath()
	@context
		.beginPath()
		.set("fillStyle", @color((tile.ne + tile.sw) / 2, tile.se))
		.moveTo(x_position                 , y_position - tile.se + tile_height)
		.lineTo(x_position + tile_width / 2, y_position - tile.ne + tile_height / 2)
		.lineTo(x_position - tile_width / 2, y_position - tile.sw + tile_height / 2)
		.fill()
	  .closePath()
	tile

#@draw_polygon = (tile) ->

@scale_height = (h) ->
	if h?
		Math.floor h * multiplier	
	else
		null

@color = (top, bottom) ->
	r = Math.floor(((top - bottom) * 2.5) + 150)
	g = 191
	b = 64
	"rgb(#{r},#{g},#{b})"