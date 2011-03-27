# Terrain Generation using the Diamond Square algorithm

This is a demonstration of terrain generation using the [diamond square algorithm](http://en.wikipedia.org/wiki/Diamond-square_algorithm).

You can see it in operation [on my blog](http://paulboxley.com/blog/2011/03/terrain-generation-mark-one). There's also some [nice documentation available](http://static.paulboxley.com/terrain-1/generate_terrain.html).

## Installation

You'll need [CoffeeScript](http://jashkenas.github.com/coffee-script/) installed, but then it should be as simple as:

    cake build
    
This should create a directory 'lib/' with the compiled .js in it. Then you can open index.html and it should draw a starting grid on the canvas.

Let me know if it isn't that simple.

I've tested it in Safari, Chrome and Firefox.