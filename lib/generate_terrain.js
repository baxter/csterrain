(function() {
  var height_map, print;
  print = require('sys').print;
  height_map = {
    populate: function(size, low_value, high_value) {
      var centre_cell, x, y;
      this.size = size;
      this.low_value = low_value != null ? low_value : 0;
      this.high_value = high_value != null ? high_value : 255;
      this.mid_value = Math.floor(((this.low_value + this.high_value) / 2) * 1.5);
      centre_cell = Math.floor(this.size / 2);
      this.map = (function() {
        var _ref, _results;
        _results = [];
        for (x = 1, _ref = this.size; (1 <= _ref ? x <= _ref : x >= _ref); (1 <= _ref ? x += 1 : x -= 1)) {
          _results.push((function() {
            var _ref, _results;
            _results = [];
            for (y = 1, _ref = this.size; (1 <= _ref ? y <= _ref : y >= _ref); (1 <= _ref ? y += 1 : y -= 1)) {
              _results.push(0);
            }
            return _results;
          }).call(this));
        }
        return _results;
      }).call(this);
      this.map[0][0] = this.map[0][this.size - 1] = this.map[this.size - 1][0] = this.map[this.size - 1][this.size - 1] = this.mid_value;
      return this.diamond_square(0, 0, this.size - 1, this.size - 1, this.mid_value / 2);
    },
    get_cell: function(x, y) {
      return this.map[y][x];
    },
    set_cell: function(x, y, v) {
      var _base;
      return (_base = this.map[y])[x] || (_base[x] = v);
    },
    diamond_square: function(left, top, right, bottom, base_height) {
      var centre_point_value, height, x_centre, y_centre;
      x_centre = Math.floor((left + right) / 2);
      y_centre = Math.floor((top + bottom) / 2);
      height = Math.floor((Math.random() - 0.5) * base_height * 2);
      centre_point_value = Math.floor(((this.get_cell(left, top) + this.get_cell(right, top) + this.get_cell(left, bottom) + this.get_cell(right, bottom)) / 4) - height);
      this.set_cell(x_centre, y_centre, centre_point_value);
      this.set_cell(x_centre, top, Math.floor((this.get_cell(left, top) + this.get_cell(right, top)) / 2));
      this.set_cell(x_centre, bottom, Math.floor((this.get_cell(left, bottom) + this.get_cell(right, bottom)) / 2));
      this.set_cell(left, y_centre, Math.floor((this.get_cell(left, top) + this.get_cell(left, bottom)) / 2));
      this.set_cell(right, y_centre, Math.floor((this.get_cell(right, top) + this.get_cell(right, bottom)) / 2));
      if ((right - left) > 2) {
        base_height = Math.floor(base_height * Math.pow(2.0, -0.75));
        this.diamond_square(left, top, x_centre, y_centre, base_height);
        this.diamond_square(x_centre, top, right, y_centre, base_height);
        this.diamond_square(left, y_centre, x_centre, bottom, base_height);
        return this.diamond_square(x_centre, y_centre, right, bottom, base_height);
      }
    }
  };
  height_map.populate(33);
  print("  var terrain = " + JSON.stringify(height_map.map).replace("[[", "[\n    [").replace(/\],\[/g, "],\n    [").replace("]]", "]\n  ]") + ";");
}).call(this);
