// Licensed under MIT license or CC 3.0-by-nc-sa

use <tubemesh.scad>;

//<params>
d = 20;
h = 17;
lineHeight = 1.5;
lineThickness = 2;
holeDiameter = 3.2;
holeHeight = 10;
stickoutRatio = 0.5;
knurl = 1.3;
//</params>

//<params>
module knurledCylinder(h=10,r1=5,r2=1.5) {
    n = ceil(2 * PI * r1 / (2 * r2));
    cylinder(h=h,r=r1,$fn=n);
    for (i=[0:n-1]) {
        x = r1*cos(360./n*i);
        y = r1*sin(360./n*i);
        translate([x,y,0]) cylinder(h=h,r=r2,$fn=12);
    }
}
//</params>

render(convexity=3) 
difference() {
knurledCylinder(h=h,r1=d/2,r2=knurl);
translate([0,0,-0.01]) cylinder(h=holeHeight,d=holeDiameter,$fn=12);
}

translate([0,0,h])
morphExtrude([[0,-lineThickness/2],[d/2+knurl,-lineThickness/2],[d/2+knurl,lineThickness/2],[0,lineThickness/2]], 
    [[0,-lineThickness/2],[d/2+knurl+lineHeight*stickoutRatio,-lineThickness/2],[d/2+knurl+lineHeight*stickoutRatio,lineThickness/2],[0,lineThickness/2]],
    height=lineHeight);
