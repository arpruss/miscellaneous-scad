nutToGlassMinumum = 2.4;
nutToGlassOffset = 2;
bottomWall = 1.5;
nutFlatToFlat = 12.88;
nutThickness = 7.92;
screwShaft = 7.91;
nutEdgeTolerance = 0.2;
nutTopTolerance = 0.4;
screwShaftTolerance = 0.25;
outerDiameter = 62;
outerWall = 2;
curvatureOffset = 1.5;
nudge = 0.01;
topWall = 1.5;
handleDiameter = 40;
handleThickness = 10;
handleHeight = 20;

$fn = 64;

module loop() {
    x = handleDiameter/2-handleThickness/2;
    translate([-x,0,0])
    cylinder(d=handleThickness,h=handleHeight);
    translate([x,0,0])
    cylinder(d=handleThickness,h=handleHeight);
    hull() {
        translate([-x,0,handleHeight])
        sphere(d=handleThickness);
        translate([x,0,handleHeight])
        sphere(d=handleThickness);
    }
}

module solid() {
    sphereR = outerDiameter*outerDiameter/(8*curvatureOffset)+curvatureOffset/2;
    
    difference() {
        cylinder(d=outerDiameter,h=bottomWall+nudge);
        translate([0,0,-sphereR+curvatureOffset])
        sphere(r=sphereR,$fn=128);
    }
    
    z1 = nutThickness+nutTopTolerance+topWall;
    translate([0,0,bottomWall]) {
        cylinder(d1=outerDiameter,d2=handleDiameter,h=z1+nudge);
        translate([0,0,z1]) loop();
    }
}

difference() {
    solid();
    cylinder(d=screwShaft+2*screwShaftTolerance,h=bottomWall+nutThickness+nutTopTolerance);
    translate([0,0,bottomWall])
    cylinder(d=(nutFlatToFlat+nutEdgeTolerance*2)/cos(180/6),h=nutThickness+nutTopTolerance,$fn=6);
}
