use <Bezier.scad>;

//<params>
stemLength = 6.65;
stemDiameter = 5;
stemExtra = 3;
holeTolerance = 0.25;
flangeDiameter = 13.5;
flangeThickness = 2.25;
indentDepth = 0.7;
indentDiameter = 8;
//</params>

$fn = 32;

module flange() {
    rotate_extrude() polygon(Bezier([[0,flangeThickness],LINE(),LINE(),[flangeDiameter/2-flangeThickness*0.75,flangeThickness],
    POLAR(flangeThickness/2,0),POLAR(flangeThickness/2,90),[flangeDiameter/2,0],LINE(),LINE(),[0,0]]));
}

module male() {
    translate([0,0,flangeThickness])
    rotate([180,0,0])
    flange();
    cylinder(d=stemDiameter,h=stemLength+2*flangeThickness+stemExtra);
}

module female() {
    volume = stemExtra * PI*(stemDiameter/2)*(stemDiameter/2);
    difference() {
        flange();
        cylinder(d=stemDiameter+holeTolerance*2,h=flangeThickness*3,center=true);
        translate([0,0,flangeThickness-indentDepth]) cylinder(d=indentDiameter,h=indentDepth*2);
    }
}

translate([flangeDiameter+2,0,0]) male();
//female();