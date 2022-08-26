thickness = 6;
majorDiameter = 18;
holeDiameter = 2.3;
holeSpacing = 5;
depressionDepth = 1.5;
depressionDiameter = 8;

module dummy() {}

rounding = thickness / (1+sqrt(0.5));
$fn = 36;
dy = rounding * (1-sqrt(0.5));
nudge = 0.01;

difference() {
    rotate_extrude() 
    {
        square([majorDiameter/2-rounding,2*rounding-dy]);
        translate([majorDiameter/2-rounding,0])
        render(convexity=1)
        intersection() {
            translate([-rounding,0]) square([rounding*2,rounding*2]);
            translate([0,rounding-dy])
            circle(r=rounding);
        }
    }
    union() {
        for (angle=[0:90:270])
            rotate([0,0,angle])
                translate([0,holeSpacing/2,-nudge]) cylinder(d=holeDiameter,h=2*rounding+2*nudge);
    }
    translate([0,0,2*rounding-dy-depressionDepth])
    cylinder(d1=depressionDiameter,d2=depressionDiameter+2*depressionDepth,h=depressionDepth+nudge);
}