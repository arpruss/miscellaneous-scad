baseDiameter = 30;
baseThickness = 2.5;
holderThickness = 1.75;
holderHeight = 4;
holderSpacing = 2.85;
holderWidth = 15;
holderWidth2 = 8;

cylinder(d=baseDiameter,h=baseThickness);
module holder() {
    translate([0,holderThickness/2,baseThickness-0.01])
    rotate([90,0,0])
    linear_extrude(height=holderThickness)
    polygon([[-holderWidth/2,0],[holderWidth/2,0],[holderWidth2/2,  holderHeight],[-holderWidth2/2,holderHeight]]);
}

translate([0,holderThickness/2+holderSpacing/2,0])
holder();
translate([0,-holderThickness/2-holderSpacing/2,0])
holder();