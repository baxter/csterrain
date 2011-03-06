(function() {
  var height_map, height_map_size, high_point, low_point, populate_height_map, print, terrain_size, x, y;
  print = require('sys').print;
  height_map_size = 33;
  terrain_size = height_map_size - 1;
  low_point = 0;
  high_point = 255;
  height_map = (function() {
    var _results;
    _results = [];
    for (x = 1; (1 <= height_map_size ? x <= height_map_size : x >= height_map_size); (1 <= height_map_size ? x += 1 : x -= 1)) {
      _results.push((function() {
        var _results;
        _results = [];
        for (y = 1; (1 <= height_map_size ? y <= height_map_size : y >= height_map_size); (1 <= height_map_size ? y += 1 : y -= 1)) {
          _results.push(0);
        }
        return _results;
      })());
    }
    return _results;
  })();
  height_map[0][0] = height_map[32][0] = height_map[0][32] = height_map[32][32] = 127;
  height_map[16][16] = 64;
  populate_height_map = function(map, left, top, right, bottom, base_height) {
    var height, x_centre, y_centre, _base, _base2, _base3, _base4, _base5;
    if (base_height == null) {
      base_height = 64;
    }
    x_centre = Math.floor((left + right) / 2);
    y_centre = Math.floor((top + bottom) / 2);
    height = Math.floor(Math.random() * base_height);
    (_base = map[x_centre])[y_centre] || (_base[y_centre] = Math.floor((map[left][top] + map[right][top] + map[left][bottom] + map[right][bottom]) / 4 - height));
    (_base2 = map[x_centre])[top] || (_base2[top] = Math.floor((map[left][top] + map[right][top]) / 2));
    (_base3 = map[x_centre])[bottom] || (_base3[bottom] = Math.floor((map[left][bottom] + map[right][bottom]) / 2));
    (_base4 = map[left])[y_centre] || (_base4[y_centre] = Math.floor((map[left][top] + map[left][bottom]) / 2));
    (_base5 = map[right])[y_centre] || (_base5[y_centre] = Math.floor((map[right][top] + map[right][bottom]) / 2));
    if ((right - left) > 2) {
      base_height = Math.floor(base_height * Math.pow(2.0, -0.75));
      populate_height_map(map, left, top, x_centre, y_centre, base_height);
      populate_height_map(map, x_centre, top, right, y_centre, base_height);
      populate_height_map(map, left, y_centre, x_centre, bottom, base_height);
      return populate_height_map(map, x_centre, y_centre, right, bottom, base_height);
    }
  };
  populate_height_map(height_map, 0, 0, 32, 32);
  print('var terrain = ' + JSON.stringify(height_map) + ';');
}).call(this);
