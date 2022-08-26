use <tubemesh.scad>;
use <ribbon.scad>;
use <pointHull.scad>;

radius = 100;
points = 5;
innerRatio = 0.4;
thickness = 18;
loopThickness = 8;
loopHeight = 6;
loopWidth = 20;
loopVerticalOffset = -15;
rounding = 3;

$fn =32;

module arm() {
    angle = 360/points/2;
    intersection() {
    pointHull(
    [ [-.01,-.01,0], [-.01,.01,0], [0,0,thickness], [radius,0,0], radius*innerRatio*[cos(angle),sin(angle),0], radius*innerRatio*[cos(angle),-sin(angle),0]]);
        linear_extrude(height=thickness)
        hull() {
            translate([radius-rounding*3,0]) circle(r=rounding);
            for (a=[-angle,angle]) translate(radius*innerRatio*[cos(a),sin(a)]) circle(r=.01);
             circle(r=rounding);
        }
    }
}

module star() {
/*    section1 = [ for(i=[0:1:2*points-1]) let(angle=i/points*360) (i%2?radius:radius*innerRatio)*[cos(angle+90),sin(angle+90),0] ];
    section2 = [ [0,0,thickness] ];
    tubeMesh([section1, section2],optimize=0,endCap=false,triangulateEnds=true); */
        for (i=[0:1:points-1]) rotate([0,0,i/points*360+90]) arm();
}

module channel() {
    rotate([90,0,0])
    ribbon([[-loopWidth/2,0],[-loopWidth/2,loopHeight/2],[-loopWidth/2+loopHeight/2,loopHeight],[loopWidth/2-loopHeight/2,loopHeight],[loopWidth/2,loopHeight/2],[loopWidth/2,0]]) sphere(d=loopThickness);
}

difference() {
    star();
    if (loopThickness) translate([0,loopVerticalOffset,0]) channel();
}