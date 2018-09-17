thickness = 8;
width = 46;
height = 50;
attenuate = 2;

module base(delta) {
    hull() {
    circle(d=thickness-2*delta);
    translate([width-thickness-thickness/2+delta,-thickness/2+delta]) square(thickness-2*delta);
    }
}

for(a=[0,90]) rotate([0,0,a]) {
    linear_extrude(height=height-attenuate) base(0);
    translate([0,0,height-attenuate-0.001])
    hull() {
        linear_extrude(height=0.001) base(0);
        translate([0,0,attenuate]) linear_extrude(height=0.001) base(attenuate);
    }
}
