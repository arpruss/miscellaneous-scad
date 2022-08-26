bottomWidth = 17;
wall = 1.25;
topWidth = 9;
height = 24;
filledSection = 10;
hole = 4.5;
lip = 0.75;
lipHeight = 2;

$fn = 36;

t = filledSection / height;

difference() {
    cylinder(d1=topWidth, d2=bottomWidth, h=height);
    translate([0,0,filledSection/2]) rotate([90,0,0]) cylinder(d=hole, h=bottomWidth*2, center=true);
    translate([0,0,filledSection]) cylinder(d2=bottomWidth-2*wall, h=height-filledSection+.01, d1=topWidth * t + bottomWidth * (1-t) - 2*wall);
}

translate([0,0,height-lipHeight])
linear_extrude(height=lipHeight) {
    difference() {
        circle(d=bottomWidth-2*wall+.01);
        circle(d=bottomWidth-2*wall-2*lip);
    }
}