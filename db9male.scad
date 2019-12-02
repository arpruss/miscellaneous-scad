use <bezier.scad>;
use <roundedSquare.scad>;

//<params>
height = 8.3;
width2 = 16.92;
width1 = 15.5;
offset = 1;
rounding = 0.75;
stripsHeight = 2.51;
stripsTolerance = 0.25;
pinSpacing = 2.77;
stripsDepth = 2.77;
socketWall = 1.5;
socketDepth = 7;
// official spacing is 25, but I like it wider
screwSpacing = 27.5;
// official width is 30.8, but I like it wider
outerWidth = 35; 
outerHeight = 12.5;
mountThickness = 2;
screwHole = 3;
//</params>

module dummy(){}

stripsWidth2 = pinSpacing * 5;
stripsWidth1 = pinSpacing * 3;
nudge = 0.01;

         
module roundedTrapezoid(width1,width2,height) {
path = [ [0,0], LINE(), LINE(), 
         [width1/2-offset,0], SMOOTH_ABS(offset*rounding), SMOOTH_ABS(offset*rounding), 
         [width1/2,offset], LINE(), LINE(), 
         [width2/2,height-offset], SMOOTH_ABS(offset*rounding), SMOOTH_ABS(offset*rounding), 
         [width2/2-offset,height], LINE(), LINE(), [0,height], REPEAT_MIRRORED([10,0])];
    translate([0,-height/2])
    polygon(Bezier(path));         
}

module innerInside() {
    w1 = stripsWidth1+2*stripsTolerance;
    w2 = stripsWidth2+2*stripsTolerance;
    h = stripsHeight+stripsTolerance;
    translate([-w1/2,-h]) roundedSquare([w1,h+nudge+0.5],radius=0.5);
    translate([-w2/2,0]) roundedSquare([w2,h+nudge],radius=0.5);
}

module outerSocket() {
    offset(r=socketWall) roundedTrapezoid(width1,width2,height);
}

linear_extrude(height=mountThickness)
difference() {
    roundedSquare([outerWidth,outerHeight],center=true,radius=1);
    innerInside();
    for (i=[-1,1]) translate([i*(screwSpacing/2),0]) circle($fn=16,d=screwHole);
}

linear_extrude(height=stripsDepth)
difference() {
    outerSocket();
    innerInside();
}

linear_extrude(height=stripsDepth+socketDepth)
difference() {
    outerSocket();
    roundedTrapezoid(width1,width2,height);
}
