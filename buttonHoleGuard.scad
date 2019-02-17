outerLength = 52.5;
buttonHoleWidth = 14.4;
buttonHoleLength = 44.4;
height = 4.3;
screwSpacing = 45.7;
screwHole = 3.8;
screwHoleDepth = 1.5;

module dummy() {}
nudge = 0.01;
outerWidth = outerLength-buttonHoleLength+buttonHoleWidth;

$fn = 32;

module oval(outerLength,outerWidth) {
    hull() {
        translate([-(outerLength-outerWidth)/2,0]) circle(d=outerWidth);
        translate([(outerLength-outerWidth)/2,0]) circle(d=outerWidth);
    }
}

difference() {
    hull() {
    linear_extrude(height=nudge) oval(outerLength,outerWidth);
    translate([0,0,height-nudge])
    linear_extrude(height=nudge) oval(buttonHoleLength,buttonHoleWidth);
    }
    translate([0,0,-nudge])
    linear_extrude(height=height+2*nudge) oval(buttonHoleLength,buttonHoleWidth);
    #for(x=[-screwSpacing/2,screwSpacing/2]) translate([x,0,-nudge])
    cylinder(h=screwHoleDepth,d=screwHole);
}