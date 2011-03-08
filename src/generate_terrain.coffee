# Generate realistic looking terrain using the [diamond square algorithm](http://en.wikipedia.org/wiki/Diamond-square_algorithm).

{print} = require('sys')

#### Generating a height map

# The height map is an array of numbers that describes the terrain. 
# The height_map object contains a 'populate' method that uses the diamond
# square algorithm to fill the 'map' property, an array of values.
height_map =
	get_cell: (x, y) ->
		@map[y][x]

	set_cell: (x, y, v) ->
		@map[y][x] ||= v
	
	# The populate method fills the height map with values. It takes a size
	# parameter which must be 2<sup>n</sup> + 1 in order to work.
	populate: (@size, @low_value=0, @high_value=255) ->
		@mid_value = Math.floor ((@low_value + @high_value) / 2) * 1.5
		
		centre_cell = Math.floor(@size/2)
		
		# Create an empty 2D array, @size × @size.
		@map = for x in [1..@size]
			0 for y in [1..@size]
		
		# The diamond square algorithm needs the four corner values to be set, so 
		# set them to a reasonable value.
		@map[0][0] = @map[0][@size - 1] = @map[@size - 1][0] = @map[@size - 1][@size - 1] = @mid_value
		
		# Start the diamond square algorithm, passing in the area that should 
		# be processed. Since we're just starting, the region is the whole array.
		@diamond_square 0, 0, @size-1, @size-1, (@mid_value / 2)
	
	# The diamond square algorithm works on a particular region in 2 steps:
	diamond_square: (left, top, right, bottom, base_height) ->
		x_centre = Math.floor (left + right) / 2
		y_centre = Math.floor (top + bottom) / 2
		
		# * The **diamond** step populates the centre point by averaging the 
		# values at the four corners and adding or subtracting a random amount.
		
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
		
		# * The **square** step populates the North, South, East and West points 
		# by averaging the North West and North East values, the South East and 
		# South East values, etc.
		
		@set_cell(x_centre, top,      Math.floor (@get_cell(left,  top)    + @get_cell(right, top)   ) / 2)
		@set_cell(x_centre, bottom,   Math.floor (@get_cell(left,  bottom) + @get_cell(right, bottom)) / 2)
		@set_cell(left,     y_centre, Math.floor (@get_cell(left,  top)    + @get_cell(left,  bottom)) / 2)
		@set_cell(right,    y_centre, Math.floor (@get_cell(right, top)    + @get_cell(right, bottom)) / 2)
		
		# Once the centre point and the four side points are populated then, 
		# provided there are no smaller regions left, split the current region
		# into four smaller regions and perform the diamond square algorithm
		# on them. 
		if (right - left) > 2
			base_height = Math.floor base_height * Math.pow 2.0, -0.75
			
			@diamond_square left,     top,      x_centre, y_centre, base_height
			@diamond_square x_centre, top,      right,    y_centre, base_height
			@diamond_square left,     y_centre, x_centre, bottom,   base_height
			@diamond_square x_centre, y_centre, right,    bottom,   base_height

# Generate the height map with an array size of 33. The height map size needs to be 2<sup>n</sup> + 1.

height_map.populate(33)

print "  var terrain = " + 
	JSON.stringify(height_map.map).
	replace("[[","[\n    [").
	replace(/\],\[/g,"],\n    [").
	replace("]]","]\n  ]") + ";"