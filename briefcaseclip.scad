use <pointHull.scad>;

//<params>
bigWidth = 34;
smallWidth = 22;
thickness = 4;
majorAxis = 46;
minorAxis = 21;
slitThickness = 0.7;
innerTolerance = 0.25;
innerSmallEnd = 12;
innerBigEnd = 8;
outer = 0; // 0:no,1:yes
inner = 1; // 0:no,1:yes
//</params>

module innerProfile() {
    minor = minorAxis-2*thickness-innerTolerance*2;
    major = majorAxis-2*thickness-innerTolerance*2;
    intersection() {
        resize([major,minor]) circle(d=majorAxis);
        translate([-innerBigEnd,-minor/2]) square([major-innerBigEnd-innerSmallEnd,minor]);
    }
}

module profile() {
    difference() {
        resize([majorAxis,minorAxis]) circle(d=majorAxis);
        resize([majorAxis-2*thickness,minorAxis-2*thickness]) circle(d=majorAxis);
        translate([-majorAxis*.43,0,0]) rotate(-35) translate([minorAxis/4,0]) square([majorAxis,slitThickness]);
    }
}

$fn = 64;

module mask() {
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

module outer() {
    rotate([0,-atan2((bigWidth-smallWidth)/2,majorAxis),0])
    translate([-majorAxis/2,0,0])
    intersection() {
        linear_extrude(height=bigWidth)
            profile();
        mask();
        
        
    }
}

module inner() {
    rotate([0,-atan2((bigWidth-smallWidth)/2,majorAxis),0])
    translate([-majorAxis/2,0,0])
    intersection() {
        linear_extrude(height=bigWidth)
            innerProfile();
        mask();
        
        
    }
}

if(outer) outer();
if(inner) translate([0,minorAxis]) inner();