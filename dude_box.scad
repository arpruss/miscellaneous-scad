use <divided_box.scad>;

big = 100;
small = 0.01;

// Individual dude measurements
dude_head_d = 9.3;
dude_neck_d = 6.0;
dude_neck_h = 13.9;
dude_foot_d = 12.0;
dude_height = 24.5;

// Collective dude array
dude_colors = ["cyan", "pink", "orange", "lime", "green", "olive", "white"];
dude_stride = 17;
dude_pad = 1.0;
dude_line = 17.475 - dude_pad - dude_foot_d;

house_height = 14;
circle_d = 20;

// Outside/bottom/inside thicknesses
box_to = 2;
box_tb = 2;
box_ti = 1.5;

// Box divisions
div1 = box_to + box_ti/2 + dude_height + 2*dude_pad;
div2 = box_to + box_ti/2 + circle_d;
div3 = div1 + box_ti + circle_d;

// Overall box dimensions
box_dim = [div3 + house_height + box_ti/2 + box_to,
           dude_foot_d + 2*dude_pad + floor(len(dude_colors)/2)*dude_stride + 2*box_to,
           19.475];
echo("Box dimensions: ", box_dim);

// Slide rail
rail_profile = [[0, 0], [0, 2.5], [2, 2.5], [1, 0.75], [1, 0]];

// Draw a single dude, for visualization only
module dude() {
  hull() {
    translate([0, 0, dude_height - dude_head_d/2])
    sphere(d=dude_head_d);

    translate([0, 0, dude_neck_h])
    linear_extrude(height=small)
    circle(d=dude_neck_d);
  }

  cylinder(h=dude_neck_h, d1=dude_foot_d, d2=dude_neck_d);
}

// Draw a row of dudes, for visualization only
module dude_array(colors) {
  for (i = [0:len(colors)-1]) {
    translate((dude_foot_d/2 + dude_pad) * [1, 1, 0])
    translate([dude_stride * i, 0, 0])
    color(colors[i])
    dude();
  }
}

// Draw all the dudes, for visualization only
module dude_stack(colors) {
  dude_array([for (i = [0:2:len(colors)-1]) colors[i]]);
  translate([dude_stride/2, dude_line, dude_height])
  scale([1, 1, -1])
  dude_array([for (i = [1:2:len(colors)-1]) colors[i]]);
}

// Build little dividers between the dudes to keep them packing correctly
module dude_sep() {
  n = floor(len(dude_colors)/2);

  intersection() {
    translate([0, box_to + dude_pad + dude_foot_d/2 + dude_stride/2, 0])
    for (i = [0:n-1]) {
      translate([0, i * dude_stride, box_tb]) {
        translate([box_to, 0, 0])
        rotate([90, 0, 0])
        cylinder(r = dude_foot_d/2 + dude_pad, h = 3, center=true);

        translate([div1, 0, 0])
        rotate([90, 0, 0])
        cylinder(r = dude_head_d/2 + dude_pad, h = 5, center=true);
      }
    }
    cube([div1, big, big]);
  }
}

// A single rail
module rail(height) {
  rotate([0, 90, 0])
  linear_extrude(height=height)
  rotate([0, 0, 90])
  polygon(rail_profile);
}

// Rails along 3 top edges
module rails() {
  translate([0, 0, box_dim[2]])
  rail(box_dim[0]);

  translate([0, box_dim[1], box_dim[2]])
  scale([1, -1, 1])
  rail(box_dim[0]);

  translate([0, 0, box_dim[2]])
  rotate([0, 0, 90])
  scale([1, -1, 1])
  rail(box_dim[1]);
}

// Sliding lid with a little bulge for a handle
module box_top(handle_r = 5, handle_offset = 5) {
  difference() {
    translate([small, small, box_dim[2] + 0.25])
    cube([box_dim[0]-2*small, box_dim[1]-2*small, 2]);

    rails();
  }

  intersection() {
    translate([0, 0, box_dim[2]+1.5])
    cube([big, big, big]);

    translate([box_dim[0] - handle_offset, 0, box_dim[2] - 1.5])
    hull() {
      translate([0, 10, 0])
      sphere(r=handle_r);

      translate([0, box_dim[1]-10, 0])
      sphere(r=handle_r);
    }
  }
}

module dude_box(dudes=1, box=1, top=0) {
  if (dudes) {
    // For visualization only
    translate([box_to + dude_pad, box_to, box_tb])
    rotate([90, 0, 90])
    dude_stack(dude_colors);
  }

  if (box) {
    divided_box([div1, [div2], div3], box_dim, box_to, box_tb, box_ti);
    dude_sep();
    rails();
  }

  if (top) {
    box_top();
  }
}

dude_box(top=0,dudes=0);
