# Generate the height map with an array size of 33. The height map size needs to be 2<sup>n</sup> + 1.		

@initialise = () ->
	canvas = document.getElementById "terrain"
	if canvas.getContext
		@context       = canvas.getContext "2d"
		@canvas_width  = 530
		@canvas_height = 400
		@tile_width    = 16
		@tile_height   = 12
		@size          = 32
		@height_map    = new HeightMap(@size + 1)
		@context.__proto__["set"] = (k,v) ->
			this[k] = v
			this
		for f in [
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

@chain = (f) ->
	() ->
		f.apply(this, arguments)||this

@draw = () ->
	@context.clearRect(0,0,@canvas_width,@canvas_height)
	for y in [0..@size-1]
		for x in  [0..@size-1]
			# console.log("#{x}, #{y}\n")
			@draw_tile(x,y)
	null

@draw_tile = (x,y) ->
	tile = @height_map.tile(x,y)
	color = @color((tile.nw + tile.ne + tile.sw + tile.se) / 4)
	for corner, height of tile
		tile[corner] = Math.floor(height * 0.75)
	start_x    = @canvas_width  / 2
	start_y    = 96
	x_position = start_x + (x * @tile_width  / 2) - (y * @tile_width  / 2)
	y_position = start_y + (x * @tile_height / 2) + (y * @tile_height / 2)
	@context
		.beginPath()
	  .set("fillStyle",color)
		#.set("strokeStyle","#000000")
		.moveTo(x_position                  , y_position - tile.nw)
		.lineTo(x_position + @tile_width / 2, y_position - tile.ne + @tile_height / 2)
		.lineTo(x_position                  , y_position - tile.se + @tile_height)
		.lineTo(x_position - @tile_width / 2, y_position - tile.sw + @tile_height / 2)
	  # .moveTo(x * 12 + 5, y * 12 + 5)
	  # .lineTo(x * 12    , y * 12    )
	  # .moveTo(x * 12    , y * 12 + 5)
	  # .lineTo(x * 12 + 5, y * 12    )
	  #.stroke()
		.fill()
	  .closePath()
	tile

@color = (h) ->
	"rgb(#{Math.floor((h * 2.5) + 150)},191,64)"