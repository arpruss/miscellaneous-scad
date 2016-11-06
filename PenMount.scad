plateThickness = 4;
upperArmThickness = 2;
lowerArmThickness = 11;
upperArmSpacing = 58.8;
plateHeight = 80;
bumpSize = 2;
upperArmHorizontalSpacing = 58.9;
upperCatchLength = 3;
upperCatchThickness = 2;
lowerArmHorizontalInset = 2;
upperArmMainLength = 44.5;
upperArmGusset = 3;

plateWidth = upperArmHorizontalSpacing + 2 * upperArmThickness;

rodDiameter = 8.15;
rodInset = 11.4 + rodDiameter/2;
rodCatchDiameter = 17.92;
lowerArmLength = rodInset+rodCatchDiameter;
lowerArmHeight = 2*7.3+rodCatchDiameter;
rodTopZ = lowerArmHeight - rodCatchDiameter / 2 + rodDiameter / 2;

//projection() 
//rotate([90,0,0])
{
// backplate
translate([0,-plateWidth/2,0]) rotate([0,-90,0]) linear_extrude(height=plateThickness) square([plateHeight,plateWidth]);

// loop over two sides
for (i=[0:1]) {
    sign = i * 2 - 1;
    // left: i = 0, sign = -1
    // right: i = 1, sign = 1
    upperArmHeight = (i==0) ? 16.4 : 28;
    upperArmStartZ = rodTopZ + ( (i==0) ? 23.2 : 16 )   ;

    // upper arm: TODO catches
    translate([0,sign*(plateWidth/2-upperArmThickness/2),upperArmStartZ+upperArmHeight/2]) 
    rotate([-sign*90,0,0]) 
        translate([0,-upperArmHeight/2,-upperArmThickness/2]) 
        union() {
        linear_extrude(height=upperArmThickness) 
            square([upperArmMainLength+upperCatchLength, upperArmHeight]);
        translate([upperArmMainLength,0,0])
            rotate([-90,0,0])
            linear_extrude(height=upperArmHeight)
            polygon(points=[[0,upperCatchThickness],[upperCatchLength,0],[0,0]]);
        rotate([-90,0,0])
            linear_extrude(height=upperArmHeight)
            polygon(points=[[0,upperArmGusset],[upperArmGusset,0],[0,0]]);
        }
    armHeightAdjustment = (i==0) ? (7.3-3.68) : 0;
    translate([0,sign*(upperArmHorizontalSpacing/2-lowerArmHorizontalInset-lowerArmThickness/2),0]) rotate([90,0,0]) translate([0,0,-lowerArmThickness/2]) linear_extrude(height=lowerArmThickness) 
    difference() {
        square([lowerArmLength, lowerArmHeight-armHeightAdjustment]);
        translate([rodInset+rodCatchDiameter/2,lowerArmHeight/2]) union() {
            circle(r=rodCatchDiameter/2);
            translate([rodCatchDiameter/2,0]) square([rodCatchDiameter,rodCatchDiameter],center=true);
        }
    }
}  

}