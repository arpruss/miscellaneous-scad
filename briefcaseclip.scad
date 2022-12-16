use <pointHull.scad>;

//<params>
bigWidth = 34;
smallWidth = 22;
thickness = 4;
majorAxis = 46;
minorAxis = 21;
slitThickness = 0.7;
//</params>

module profile() {
    difference() {
        resize([majorAxis,minorAxis]) circle(d=majorAxis);
        resize([majorAxis-2*thickness,minorAxis-2*thickness]) circle(d=majorAxis);
        translate([-majorAxis*.43,0,0]) rotate(-35) translate([minorAxis/4,0]) square([majorAxis,slitThickness]);
    }
}

$fn = 64;
rotate([0,-atan2((bigWidth-smallWidth)/2,majorAxis),0])
translate([-majorAxis/2,0,0])
intersection() {
    linear_extrude(height=bigWidth)
        profile();
    pointHull([
                [-majorAxis/2,-minorAxis,bigWidth/2-smallWidth/2],
                [-majorAxis/2,minorAxis,bigWidth/2-smallWidth/2],
                [-majorAxis/2,-minorAxis,bigWidth/2+smallWidth/2],
                [-majorAxis/2,minorAxis,bigWidth/2+smallWidth/2],
                [majorAxis/2,-minorAxis,bigWidth],
                [majorAxis/2,minorAxis,bigWidth],
                [majorAxis/2,-minorAxis,0],
                [majorAxis/2,minorAxis,0]
    ]);
    
    
}