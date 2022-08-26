length = 122;
width = 14;
height = 8;

module piece() {
    hull() {
        cylinder(d=width,h=height);
        translate([length-width,0,0]) cylinder(d=width,h=height);
    }
}

piece();
translate([length+5,0,0]) piece();