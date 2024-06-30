use <Bezier.scad>;
use <ribbon.scad>;
use <roundedSquare.scad>;

//<params>
knobDiameter = 15;
tolerance = 0.1;
snapHoldAngle = 110;
lip = 3;
lipOffsetAngle = 8;
snapThickness = 2;
snapPlateLength = 40;
snapScrewHoleDiameter = 3.5;
knobScrewHoleDiameter = 4;
screwHeadDiameter = 10;
screwInset = 3;
screwOffsetFromEnd = 5;
width = 15;
rounding = 5;
knobExtraHeight = 5;
//</params>

$fn = 32;

module snapProfile() {
    r = knobDiameter/2 + tolerance + snapThickness/2;
    snapAngle = 90+snapHoldAngle/2;
    innerX = r*cos(snapAngle);
    innerY = r*sin(snapAngle);
    lipAngle = snapAngle-lipOffsetAngle;
    outerX = (r+lip)*cos(lipAngle);
    outerY = (r+lip)*sin(lipAngle);
    lipProfile = [ [outerX,outerY], POLAR(lip/4,180+lipAngle+lipOffsetAngle), POLAR(lip/4,snapAngle-90),
    [innerX,innerY] ];
    rounded = [for(t=[1:20]) let(a=(t/20)*270+(1-t/20)*snapAngle) r*[cos(a),sin(a)]];
    left = concat(Bezier(lipProfile),rounded);
    right = [for(i=[0:len(left)-1]) let(xy=left[len(left)-1-i]) [-xy[0],xy[1]]];
    full = concat(left,right);
    translate([0,r+snapThickness/2]) {
        ribbon(full) circle(d=snapThickness);
    }
}


module snap() {
    linear_extrude(height=width) snapProfile();
    translate([-snapPlateLength/2,snapThickness,0]) 
    rotate([90,0,0])
    linear_extrude(height=snapThickness) {
       difference() {
          roundedSquare([snapPlateLength,width],radius=rounding,$fn=32);
          for (s=[-1,1]) translate([snapPlateLength/2+s*(snapPlateLength/2-screwOffsetFromEnd),width/2]) circle(d=snapScrewHoleDiameter);
       }
   }          
}

module knob() {
    h = width+knobExtraHeight;
    difference() {
        cylinder(d=knobDiameter,h=h,$fn=64);
        cylinder(d=knobScrewHoleDiameter,h=h*3,center=true);
        translate([0,0,h-screwInset]) cylinder(d=screwHeadDiameter,h=screwInset*2);
    }
}

snap();
translate([0,-screwHeadDiameter/2-10,0]) knob();
