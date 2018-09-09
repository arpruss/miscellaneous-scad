use <bezier.scad>;
use <tubemesh.scad>;

postSize = 50.4;
supportHeight = 50;
supportWidth = 50;
thicknessAtBottom = 3;
thicknessAtTop = 3;
topVerticalityControl = 0.7;
bottomHorizontalityControl = 0.8;
precision = 0.05;
countersinkDiameter = 8;
screwHoleDiameter = 3.5;
screwHoleLength = 3;
teardropHoles = true;
minimumHoleDistanceFromEdge = 5;
xFaceHolePositions = 
    [ [0,1], [0.5,0.5], [1,0] ];
yFaceHolePositions = 
    [ [1,1], [1,0], [0,1] ];
zFaceHolePositions = 
    [ [0,0.1], [0.5,0.4], [1,0.1] ];

module dummy() {}

nudge = 0.005;

curve = Bezier([ 
    [supportWidth,0],
    SHARP(),
    SHARP(),
    [supportWidth,thicknessAtBottom],
    OFFSET([-bottomHorizontalityControl * supportWidth,0]),
    OFFSET([0,-topVerticalityControl*supportHeight]),
    [thicknessAtTop,supportHeight] ], precision=precision); 

sections = [for(p=curve) let(d=p[0]+postSize)
     [ [0,0,p[1]], [d,0,p[1]], [d,d,p[1]], [0,d,p[1] ] ]
     ];

module support() {
    render(convexity=2)
    difference() {
        tubeMesh(sections);
        translate([0,0,-nudge]) cube([postSize,postSize,supportHeight+2*nudge]);
    }
}

module horizontalHole(diameter=10,length=50,teardrop=true) {
    rotate([0,90,0]) {
        cylinder(d=diameter, h=length);
        if (teardrop)
        translate([-diameter/(2*sqrt(2)),0,0]) cylinder(d=diameter/sqrt(2), h=length, $fn=4);
    }
}

module horizontalScrewHole(teardrop=teardropHoles) {
    $fn = 16;
    translate([screwHoleLength,0,0])
    horizontalHole(diameter=countersinkDiameter, length=supportWidth+2*nudge, teardrop=teardrop);
    translate([-nudge,0,0])
    horizontalHole(diameter=screwHoleDiameter, length = screwHoleLength + 2*nudge, teardrop=teardrop);
}
module verticalScrewHole() {
    rotate([0,-90,0])
    horizontalScrewHole(teardrop=false);
}

holeOffset =  minimumHoleDistanceFromEdge + countersinkDiameter / 2;

module xFaceScrewHoles() {
    y0 = holeOffset;
    z0 = thicknessAtBottom + holeOffset;
    y1 = supportWidth - holeOffset;
    z1 = supportHeight - holeOffset;
    for(pos=xFaceHolePositions) {
        y = (1-pos[0])*y0 + (pos[0])*y1;
        z = (1-pos[1])*z0 + (pos[1])*z1;
        translate([postSize-nudge,y,z]) horizontalScrewHole();
    }
}

module yFaceScrewHoles() {
    x0 = postSize + thicknessAtTop - holeOffset;
    z0 = thicknessAtBottom + holeOffset;
    x1 = holeOffset;
    z1 = supportHeight - holeOffset;
    for(pos=yFaceHolePositions) {
        x = (1-pos[0])*x0 + (pos[0])*x1;
        z = (1-pos[1])*z0 + (pos[1])*z1;
        translate([x,postSize-nudge,z])
        rotate([0,0,90]) horizontalScrewHole();
    }
}

module zFaceScrewHoles() {
    x0 = postSize + supportWidth - holeOffset;
    x1 = postSize + thicknessAtTop + holeOffset;
    y0 = holeOffset;
    
    for(pos=zFaceHolePositions) {
        x = (1-pos[1])*x0 + pos[1]*x1;
        y1 = x;
        y = (1-pos[0])*y0 + (pos[0])*y1;
        translate([x,y,0]) verticalScrewHole();
        translate([y,x,0]) verticalScrewHole();
    }
}

render(convexity=5)
difference() {
    support();
    xFaceScrewHoles();
    yFaceScrewHoles();
    zFaceScrewHoles();
}