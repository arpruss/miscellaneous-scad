innerDiameter = 40;
outerDiameter = 140;
totalThickness = 2.25;
mountingHoles = 4;
relativeHoleLocation = 0.5;
tolerance = 0.4;

module dummy() {}

$fn = 128;

module mountingHole() {
    translate([0,-3]) square([5,2.5],center=true);
    translate([0,3]) square([5,2.5],center=true);
}

module base() {
    rotate(360/(2*mountingHoles))
    difference() {
        circle(d=outerDiameter);
        circle(d=innerDiameter);
        for (i=[0:1:mountingHoles-1]) rotate(360/mountingHoles*i) translate([(outerDiameter*(relativeHoleLocation)+innerDiameter*(1-relativeHoleLocation))/2,0]) mountingHole();
    }
}

module extra(tolerance) {
    intersection() {
        translate([outerDiameter/2,0]) square([outerDiameter,innerDiameter+2*tolerance], center=true);
        base();
    }
}

linear_extrude(height=totalThickness/2) difference() {
        base();
        extra(tolerance/2);
    }
linear_extrude(height=totalThickness) intersection() {
        base();
        rotate(180) extra(-tolerance/2);
    }
