use <tubeMesh.scad>;

//<params>
boardThickness = 17.4;
handleLength = 176;
handleWidth = 33.75;
screwHole = 4;
screwInsetDiameter = 9;
screwInsetDepth = 3.5;
thicknessRatio = 1;
domeExponent = 2.4;
//</params>

$fn = 64;

handleThickness = thicknessRatio*(handleWidth-boardThickness)/2;
nudge = 0.01;

module dome(radius) {
    sections = 
        [
            for (i=[0:40]) let(t = i / 40)
                ngonPoints(n=$fn,r=sqrt(1-pow(t,domeExponent))*radius, z=t*radius) 
        ];
    tubeMesh(sections);
}

//dome(handleWidth/2);

module screw() {
    $fn = 16;
    translate([0,0,-0.5]) cylinder(d=screwHole,h=handleThickness+1);
    translate([0,0,handleThickness-screwInsetDepth]) cylinder(d=screwInsetDiameter,h=screwInsetDepth+nudge);
}

module basic() {
    intersection() {
        scale([1,1,handleThickness/(handleWidth/2)]) hull() {
            dome(handleWidth/2);
            translate([handleLength,0,0]) dome(handleWidth/2);
        }
        translate([-handleWidth/2,-handleWidth/2,0]) cube([handleLength+2*handleWidth,handleWidth,handleThickness]);
    }
}

difference() {
    basic();
    screw();
    translate([handleLength/2-5,0,0]) screw();
    translate([handleLength-10,0,0]) screw();
}