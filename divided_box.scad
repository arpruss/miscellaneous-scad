
module dividers(div, size, thickness) {
  // div: an array of divider positions (centers), must be increasing.
  //      Nested arrays will alter direction from +x to +y, or +y to +x.
  // size: a 3 component vector
  // thickness: thickness of each wall

  for (i = [0:len(div)-1]) {
    if (len(div[i])) {
      // Handle nested dividers by flipping direction.
      assign (start = i > 0 ? div[i-1] : 0,
              end = i < len(div)-1 ? div[i+1] : size[0]) {
        translate([start, 0, 0])
        multmatrix([[0, 1, 0, 0],
                    [1, 0, 0, 0],
                    [0, 0, 1, 0],
                    [0, 0, 0, 1]])
        dividers(div[i], [size[1], end - start, size[2]], thickness);
      }
    } else {
      translate([div[i]-thickness/2, 0, 0]) cube([thickness, size[1], size[2]]);
    }
  }
}

module divided_box(div, size, to=2, tb=1.5, ti=1) {
  // div:  see dividers()
  // size: outside dimensions of the box
  // to:   thickness of outsize wall
  // tb:   thickness of bottom
  // ti:   thickness of inside wall
  difference() {
    cube(size);
    translate([to, to, tb]) cube(size - [2*to, 2*to, 0]);
  }
  dividers(div, size, ti);
}

divided_box([[50], 25, 50, [33, 66], 75, [50]], [100, 100, 10]);
