# Generate realistic looking terrain using the [diamond square algorithm](http://en.wikipedia.org/wiki/Diamond-square_algorithm).

#### Generating a height map

# The height map is basically an array of numbers, each element represents
# a point on a map and each number represents the height of that grid.
class @HeightMap

	# Create a 2D array of size × size filled with zeroes. Initialise the 
	# centre and corner points to reasonable starting values. Push an object
	# to the queue containing the parameters needed for the first call to
	# the diamond_square method.
	constructor: (@size, @low_value=0, @high_value=255) ->
		@mid_value = Math.floor ((@low_value + @high_value) / 2)
		@reset()
	
	reset: () ->
		while @remaining()
			@pop()
				
		@map = for x in [1..@size]
			null for y in [1..@size]
		
		centre_cell = Math.floor(@size/2)

		@map[0][0] = @map[0][@size - 1] = @map[@size - 1][0] = @map[@size - 1][@size - 1] = @mid_value

		@push {
			start_x:     0,
			start_y:     0,
			end_x:       @size - 1,
			end_y:       @size - 1,
			base_height: @mid_value
		}
	
	# Get the value of the cell at [x, y].
	get_cell: (x, y) ->
		@map[y][x]
	
	# Set the value of the cell at [x, y] to be v.
	set_cell: (x, y, v) ->
		@map[y][x] ||= v
	
	# Push a set of parameters to the end of the queue.
	# If the queue is empty then create it as a single element array.
	push: (value) ->
		if @queue
			@queue.push(value)
		else
			@queue = [value]
		@queue
	
	# Pop a set of parameters from the start of the queue.
	pop: () ->
		if @queue?
			@queue.shift()
	
	# Return `true` if there are any parameters still in the queue, otherwise
	# return `false`.
	remaining: () ->
		if @queue? && @queue.length > 0
			true
		else
			false
	
	# Perform a single step by popping the first value from the queue
	# and running the diamon_dquare algorithm with those values as
	# parameters.
	#
	# I wanted to say something like `@diamond_square( @pop() )` but that
	# didn't work...
	step: () ->
		s = @pop()
		@diamond_square(
			s.start_x,
			s.start_y,
			s.end_x,
			s.end_y,
			s.base_height
		)
	
	# Keep calling step() until there's nothing left in the queue.
	run: () ->
		@step() while @remaining()
		null
	
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
	
	# Return an object representing four points.
	tile: (x, y) ->
		{
			nw: @get_cell(x,   y  )
			ne: @get_cell(x+1, y  )
			sw: @get_cell(x,   y+1)
			se: @get_cell(x+1, y+1)
		}