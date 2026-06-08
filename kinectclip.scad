//<params>
tvThickness = 13;
bezelHeight = 12;

tvTolerance = .07;
baseWidth = 86.7;
baseDepth = 72.9;
baseTolerance = .5;
wallHeight = 17;
wallThickness = 2;
braceThickness = 1.25;
cableHoleWidth = 8.1;
cableHoleOffset = 5;
//</params>

module dummy(){}

w1 = baseDepth+baseTolerance+2*wallThickness;
w2 = tvThickness+tvTolerance;

module holderWall() {
    hull() {
        square([wallThickness,wallThickness]);
        translate([wallThickness/2,-bezelHeight+wallThickness/2]) circle(d=wallThickness,$fn=16);
    }
}

module braces() {
    hull() {
        translate([-w1/2,0]) square([w1/2-w2/2,wallThickness]);
        translate([-w2/2-wallThickness,0]) holderWall();
    }
    mirror([1,0]) hull() {
        translate([-w1/2,0]) square([w1/2-w2/2,wallThickness]);
        translate([-w2/2-wallThickness,0]) holderWall();
    }
}

module profile() {
    translate([-w1/2,0]) square([w1,wallThickness]);
    translate([-w2/2-wallThickness,0]) holderWall();
    translate([w2/2,0]) holderWall();
//    brace();
}

w3 = baseWidth + baseTolerance;
module main() {
    linear_extrude(height=w3+2*wallThickness) profile();
    linear_extrude(height=braceThickness) braces();
    translate([0,0,w3+2*wallThickness-braceThickness]) linear_extrude(height=braceThickness) braces();
    for (x=[-w1/2,w1/2-wallThickness]) translate([x,0,0]) cube([wallThickness,wallHeight+wallThickness,w3+2*wallThickness]);
    for (z=[0,w3+wallThickness]) translate([-w1/2,0,z]) cube([w1,wallHeight+wallThickness,wallThickness]);
}


difference() {
    main();
    translate([baseDepth/2,wallThickness+cableHoleOffset,baseWidth/2+wallThickness])
    translate([-1.5*wallThickness,0,-.5*cableHoleWidth])
    cube([3*wallThickness,wallHeight-(cableHoleOffset+1),cableHoleWidth]);
}