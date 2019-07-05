use <pointHull.scad>;

baseThickness = 1.5;
columns = 5;
rows = 5;
squareInnerSize = 20;
dividerHeight = 2;
// between 0 and 90 exclusive, 90 would be perfectly vertical
dividerAngle = 45; 

module dummy() {}

nudge = 0.001;
dz = dividerHeight;
dw = dz / tan(dividerAngle);

w = (squareInnerSize + 2 * dw) * columns;
h = (squareInnerSize + 2 * dw) * rows;

cube([w,h,baseThickness]);
echo(w,h);

translate([0,0,baseThickness-nudge]) {
    pointHull([[0,0,0],[0,0,dz],[dw,0,0],[0,h,0],[0,h,dz],[dw,h,0]]);
    pointHull([[w,0,0],[w,0,dz],[w-dw,0,0],[w,h,0],[w,h,dz],[w-dw,h,0]]);
    pointHull([[0,0,0],[0,0,dz],[0,dw,0],[w,0,0],[w,0,dz],[w,dw,0]]);
    pointHull([[0,h,0],[0,h,dz],[0,h-dw,0],[w,h,0],[w,h,dz],[w,h-dw,0]]);
    for (i=[1:1:columns-1]) {
        translate([i*(squareInnerSize+2*dw),0,0]) pointHull([[-dw,0,0],[-dw,h,0],[dw,0,0],[dw,h,0],[0,0,dz],[0,h,dz]]);
    }
    for (i=[1:1:rows-1]) {
        translate([0,i*(squareInnerSize+2*dw),0]) pointHull([[0,-dw,0],[w,-dw,0],[0,dw,0],[w,dw,0],[0,0,dz],[w,0,dz]]);
    }
}