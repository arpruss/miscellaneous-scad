use <quickthread.scad>;

innerHeight = 20.5;
innerDiameter = 51.9;
threadLead = 11.58;
threadPitch = threadLead/2;
nStarts = 2;
lip = 5;

sideThickness = 3;
bottomThickness = 2;
tolerance = 0.7;

module dummy(){}

$fn = 72;
d = innerDiameter+2*tolerance;

render(convexity=2)
difference() {
    cylinder(d=d+2*sideThickness, h=innerHeight+bottomThickness);
    
    translate([0,0,-1])
    cylinder(d=d-2*lip, h=innerHeight+bottomThickness+2);
    translate([0,0,bottomThickness]) {
        isoThread(d=d, pitch=threadPitch, h=innerHeight+1, lead=threadLead, angle=40, starts=2, internal=true);
        cylinder(d=d, h=innerHeight+1);
    }
}