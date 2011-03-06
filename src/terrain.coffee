# THE X AND Y AXIS ARE INVERTED!

# Generate realistic looking terrain using the 'diamond square' algorithm
# and then draw the output using canvas.

{print} = require('sys')

# The dimensions of the height map array should be `2^n+1` square.
# The terrain size is 1 less than the height_map

height_map_size = 33
terrain_size    = height_map_size - 1

# The lowest and highest points that the height map may contain

low_point  = 0
high_point = 255

# Initialise an empty 2D array.

height_map = for x in [1..height_map_size]
	0 for y in [1..height_map_size]

#### Populate the height map

# The 'diamond square' algorithm requires the four corner points of the 
# region that it is currently processing to be set first.

height_map[0][0] = height_map[32][0] = height_map[0][32] = height_map[32][32] = 127

height_map[16][16] = 64

# Given a height map and a region within that map populate the height map with values

populate_height_map = (map, left, top, right, bottom, base_height=64) ->

# Find the value for the centre point of the current region by averaging 
# the value of the four corner points and adding or subtracting a random amount.
# The size of this random amount should be proportional to the depth of the recursion.

	x_centre = Math.floor (left + right) / 2
	y_centre = Math.floor (top + bottom) / 2
	
	height = Math.floor(
		Math.random() * base_height
	)
	
	map[x_centre][y_centre] ||= Math.floor(
		(
			map[left][top]     +
			map[right][top]    +
			map[left][bottom]  +
			map[right][bottom]
		) / 4 - height
	)

# Find the value of the North, South, West and East points by averaging the 
# appropriate corner values.

	map[x_centre][top]    ||= Math.floor (map[left][top]    + map[right][top]   ) / 2
	map[x_centre][bottom] ||= Math.floor (map[left][bottom] + map[right][bottom]) / 2
	map[left][y_centre]   ||= Math.floor (map[left][top]    + map[left][bottom] ) / 2
	map[right][y_centre]  ||= Math.floor (map[right][top]   + map[right][bottom]) / 2
	
	if (right - left) > 2
		base_height = Math.floor base_height * Math.pow 2.0, -0.75
		
		populate_height_map map, left,     top,      x_centre, y_centre, base_height
		populate_height_map map, x_centre, top,      right,    y_centre, base_height
		populate_height_map map, left,     y_centre, x_centre, bottom,   base_height
		populate_height_map map, x_centre, y_centre, right,    bottom,   base_height

populate_height_map(height_map, 0, 0, 32, 32)

print 'var terrain = ' + JSON.stringify(height_map) + ';'