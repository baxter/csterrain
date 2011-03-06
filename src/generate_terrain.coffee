# Generate realistic looking terrain using the 'diamond square' algorithm
# and then draw the output using canvas.

{print} = require('sys')

#### Generating a height map

height_map = 	
	populate: (@size, @low_value=0, @high_value=255) ->
		@mid_value = Math.floor ((@low_value + @high_value) / 2) * 1.5

		centre_cell = Math.floor (@size / 2)

		@map = for x in [1..@size]
			0 for y in [1..@size]

		@map[0][0] = @map[0][@size - 1] = @map[@size - 1][0] = @map[@size - 1][@size - 1] = @mid_value

		@diamond_square 0, 0, @size-1, @size-1, (@mid_value / 2)
			
	get_cell: (x, y) ->
		@map[y][x]
	
	set_cell: (x, y, v) ->
		@map[y][x] ||= v
	
	diamond_square: (left, top, right, bottom, base_height) ->
		x_centre = Math.floor (left + right) / 2
		y_centre = Math.floor (top + bottom) / 2

		height = Math.floor (Math.random() - 0.5) * base_height * 2
		
		centre_point_value = Math.floor (
			(
				@get_cell(left, top) +
				@get_cell(right, top) +
				@get_cell(left, bottom) +
				@get_cell(right, bottom)
			) / 4
		) - height
		
		@set_cell(x_centre, y_centre, centre_point_value)
		
		@set_cell(x_centre, top,      Math.floor (@get_cell(left, top)    + @get_cell(right, top)   ) / 2)
		@set_cell(x_centre, bottom,   Math.floor (@get_cell(left, bottom) + @get_cell(right, bottom)) / 2)
		@set_cell(left,     y_centre, Math.floor (@get_cell(left, top)    + @get_cell(left, bottom) ) / 2)
		@set_cell(right,    y_centre, Math.floor (@get_cell(right, top)   + @get_cell(right, bottom)) / 2)
		
		if (right - left) > 2
			base_height = Math.floor base_height * Math.pow 2.0, -0.75

			@diamond_square left,     top,      x_centre, y_centre, base_height
			@diamond_square x_centre, top,      right,    y_centre, base_height
			@diamond_square left,     y_centre, x_centre, bottom,   base_height
			@diamond_square x_centre, y_centre, right,    bottom,   base_height

height_map.populate(33)

print "  var terrain = " + 
	JSON.stringify(height_map.map).
	replace("[[","[\n    [").
	replace(/\],\[/g,"],\n    [").
	replace("]]","]\n  ]") + ";"