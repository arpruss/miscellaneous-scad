use <roundedsquare.scad>;

screwTolerance = 0.125;
screwHoleSize = 2.6;
maxScrewLength = 10;
screwHoleSize1 = screwHoleSize + 2*screwTolerance;

washer = true;

render(convexity=2)
if (washer) 
difference() {
    cylinder(h=1.5, d=screwHoleSize1+4);
    translate([0,0,-.5])
    cylinder(d=screwHoleSize1+1, h=4, $fn=16);
}
else
difference() {
    linear_extrude(height=5) roundedSquare(size=screwHoleSize1+3,radius=0.5,center=true);
    translate([0,0,-.5])
    cylinder(d=screwHoleSize1, h=6, $fn=16);
}