use <quickthread.scad>;

//<params>
innerHeight = 20.5;
innerDiameter = 51.9;
threadLead = 11.8/2;
threadPitch = 1.6*threadLead/2;
nStarts = 2;
lip = 5;

sideThickness = 3;
bottomThickness = 2;
threadTolerance = 1.2;
cylinderTolerance = 0.7;
//</params>

module dummy(){}

$fn = 72;
d = innerDiameter+2*threadTolerance;
render(convexity=2)
difference() {
    cylinder(d=d+2*sideThickness, h=innerHeight+bottomThickness);
    
    translate([0,0,-1])
    cylinder(d=d-2*lip, h=innerHeight+bottomThickness+2);
    translate([0,0,bottomThickness]) {
        isoThread(d=d, pitch=threadPitch, h=innerHeight+1, lead=threadLead, angle=40, starts=2, internal=true);
        cylinder(d=innerDiameter+2*cylinderTolerance, h=innerHeight+1);
    }
}