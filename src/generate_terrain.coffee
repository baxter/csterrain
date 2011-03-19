# Generate realistic looking terrain using the [diamond square algorithm](http://en.wikipedia.org/wiki/Diamond-square_algorithm).

{print} = require('sys')

#### Generating a height map

# The height map is an array of numbers that describes the terrain. 
# The height_map object contains a 'populate' method that uses the diamond
# square algorithm to fill the 'map' property, an array of values.
class HeightMap
	get_cell: (x, y) ->
		@map[y][x]

	set_cell: (x, y, v) ->
		@map[y][x] ||= v
		
	# The populate method fills the height map with values. It takes a size
	# parameter which must be 2<sup>n</sup> + 1 in order to work.
	constructor: (@size, @low_value=0, @high_value=255) ->
		@mid_value = Math.floor ((@low_value + @high_value) / 2)
		
		centre_cell = Math.floor(@size/2)
		
		# Create a 2D array, @size × @size, full of zeros
		@map = for x in [1..@size]
			0 for y in [1..@size]
		
		# The diamond square algorithm needs the four corner values to be set, so 
		# set them to a reasonable value.
		@map[0][0] = @map[0][@size - 1] = @map[@size - 1][0] = @map[@size - 1][@size - 1] = @mid_value
		
		# Add the parameters for the first step to the queue
		@push {
			start_x:     0,
			start_y:     0,
			end_x:       @size - 1,
			end_y:       @size - 1,
			base_height: @mid_value / 2
		}
	
	# Add a value to the queue.
	push: (value) ->
		if @queue
			@queue.push(value)
		else
			@queue = [value]
		@queue
	
	pop: () ->
		@queue.shift()
	
	left: () ->
		@queue.length		
	
	step: () ->
		s = @pop()
		@diamond_square(
			s.start_x,
			s.start_y,
			s.end_x,
			s.end_y,
			s.base_height
		)
	
	run: () ->
		@step() while @left()
	
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
		
		@set_cell(x_centre, top,      Math.floor (@get_cell(left,  top)    + @get_cell(right, top)   ) / 2 + ((Math.random() - 0.5) * base_height))
		@set_cell(x_centre, bottom,   Math.floor (@get_cell(left,  bottom) + @get_cell(right, bottom)) / 2 + ((Math.random() - 0.5) * base_height))
		@set_cell(left,     y_centre, Math.floor (@get_cell(left,  top)    + @get_cell(left,  bottom)) / 2 + ((Math.random() - 0.5) * base_height))
		@set_cell(right,    y_centre, Math.floor (@get_cell(right, top)    + @get_cell(right, bottom)) / 2 + ((Math.random() - 0.5) * base_height))
		
		# Once the centre point and the four side points are populated then, 
		# provided there are no smaller regions left, split the current region
		# into four smaller regions and perform the diamond square algorithm
		# on them. 
		if (right - left) > 2
			base_height = Math.floor base_height * Math.pow 2.0, -0.75
			
			@push { start_x: left,     start_y: top,      end_x: x_centre, end_y: y_centre, base_height: base_height }
			@push { start_x: x_centre, start_y: top,      end_x: right,    end_y: y_centre, base_height: base_height }
			@push { start_x: left,     start_y: y_centre, end_x: x_centre, end_y: bottom,   base_height: base_height }
			@push { start_x: x_centre, start_y: y_centre, end_x: right,    end_y: bottom,   base_height: base_height }

h = new HeightMap(33)

h.run()

print "  var terrain = " + 
	JSON.stringify(h.map).
	replace("[[","[\n    [").
	replace(/\],\[/g,"],\n    [").
	replace("]]","]\n  ]") + ";"