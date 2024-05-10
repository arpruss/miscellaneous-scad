use <Bezier.scad>;

//<params>
length = 59;
width = 63.5;
wTolerance = 0.2;
hTolerance = -.2;
height = 23.5;
minThickness = 3.5;
typicalThickness = 6;
side = 22;
screwBigDiameter = 9;
screwSmallDiameter = 4.5;
screwDepth = 4;
//</params>

width1 = width + 2*wTolerance;
height1 = height + hTolerance;


module profile() {
p = [ 
    [ -side - width1/2, 0 ], POLAR(minThickness/2,90), POLAR(minThickness/2,180),
    [ -side - width1/2 + minThickness*0.6, minThickness], POLAR(side,0),
    POLAR(side/2,180), [ -width1/2, height1 + typicalThickness ], LINE(), LINE(), [0, height1+typicalThickness], REPEAT_MIRRORED([1,0]) ];
    difference() {
        polygon(Bezier(p));
        square([width1,height1*2],center=true);
    }
}

module screw() {
    $fn = 32;
    bigH = 2*(height+typicalThickness+10);
    rotate([-90,0,0]) union() {
        cylinder(d=screwSmallDiameter,h=bigH,center=true);
        translate([0,0,screwDepth]) cylinder(d=screwBigDiameter,h=bigH,center=false);
    }
}

difference() {
    linear_extrude(height=length) profile();
    for (s=[-1,1]) {
        translate([s*(-side/2-width1/2),0,length/4]) screw();
        translate([s*(-side/2-width1/2),0,3*length/4]) screw();
    }
}