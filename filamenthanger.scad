cupDepth = 40;
bearingInnerDiameter = 8;
bearingOffset = 2;
bearingNutWall = 3.5;
bearingOuterDiameter = 22;
bearingTolerance = 0.2;
bearingLipRadial = 2.5;
bearingLipThickness = 1;
cupTolerance = 0.25;
innerCupOuterDiameter = 40;
filamentHoleDiameter = 50;
filamentHolderDiameter = 80;
filamentHolderWall = 2;

module dummy() {}

nudge = 0.001;
$fn=64;

module hollowCylinder(od=10,id=5,h=10) {
    difference() {
        cylinder(d=od,h=h);
        translate([0,0,-nudge]) cylinder(d=id,h=h+2*nudge);
    }
}

module inner() {
    translate([0,0,bearingOffset+bearingNutWall]) 
        hollowCylinder(id=bearingOuterDiameter+bearingTolerance*2,od=innerCupOuterDiameter,h=cupDepth);
    translate([0,0,bearingNutWall])
        hollowCylinder(id=bearingOuterDiameter+bearingTolerance*2-bearingLipRadial*2,od=innerCupOuterDiameter,h=bearingLipThickness+bearingOffset+nudge);
    hollowCylinder(id=bearingInnerDiameter,od=innerCupOuterDiameter,h=bearingNutWall+2*nudge);
}

module innerHolder() {
    hollowCylinder(id=innerCupOuterDiameter+2*cupTolerance, od=innerCupOuterDiameter+2*cupTolerance+2, h=filamentHolderWall+2);
    hollowCylinder(id=bearingOuterDiameter+bearingTolerance*2, od=filamentHolderDiameter, h=filamentHolderWall);
    
}

module outer() {
    translate([0,0,filamentHolderWall-nudge]) hollowCylinder(id=innerCupOuterDiameter+2*cupTolerance, od=filamentHoleDiameter-2*cupTolerance, h=cupDepth);
    hollowCylinder(id=innerCupOuterDiameter+2*cupTolerance, od=filamentHolderDiameter, h=filamentHolderWall);
}

inner();

translate([filamentHolderDiameter+10,0,0]) outer();

translate([0,filamentHolderDiameter+10,0]) innerHolder();

