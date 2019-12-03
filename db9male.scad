use <bezier.scad>;
use <roundedSquare.scad>;

//<params>
pins = 9;
stripsTolerance = 0.35;
socketWall = 1.5;
socketDepth = 7;
mountThickness = 1.75;
// the jack is the female part that fits inside the socket
jackHeight = 8.3;
jackWidthIncrementBeyondNominalPinSpacing = 3.12;
// official value for db9 is 10.7, but that's not so good for our thicker plastic wall
mountHeight = 12.5;
// official value for db9 is 3.04, but I like 3.75
mountEdgeDistanceBeyondScrews = 3.04;
// official distance for db9 is 4.04, but I like 5.3
screwDistanceFromJack = 4.04;
screwHole = 3.05;

slantAngle = 10;
offset = 1.34;
rounding = 0.75;
stripsHeight = 2.51;
// this is what it should be
nominalPinSpacing = 2.76;
// this is what it is if you use 0.1" header
headerPinSpacing = 2.54;
stripsSpacerDepth = 2.77;
// this might be useful to put down an extra layer of plastic at the bottom to help the header pins stick in place
stripsExtraDepth = 0; 
pinHoleDiameter = 0.4;
//</params>

module dummy(){}

stripsDepth = stripsSpacerDepth + stripsExtraDepth;
pinsInRow2 = pins%2 ? (pins+1)/2 : pins/2;
pinsInRow1 = pins%2 ? (pins-1)/2 : pins/2;
jackWidth = pinsInRow2*nominalPinSpacing+jackWidthIncrementBeyondNominalPinSpacing; 

pinSpacing = headerPinSpacing;
screwSpacing = jackWidth+ 2 * screwDistanceFromJack;
mountWidth = screwSpacing + 2*mountEdgeDistanceBeyondScrews;
height = jackHeight;
width2 = jackWidth;
width1 = width2-tan(slantAngle)*(height-2*offset);

stripsWidth2 = pinSpacing * pinsInRow2;
stripsWidth1 = pinSpacing * pinsInRow1;
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
    roundedSquare([mountWidth,mountHeight],center=true,radius=1);
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

if (stripsExtraDepth>0) 
    linear_extrude(height=stripsExtraDepth) difference() {
        outerSocket();
        for (i=[0,1]) {
            pins = [pinsInRow1,pinsInRow2][i];
            translate([-pins/2*headerPinSpacing+0.5*headerPinSpacing,stripsHeight*(i-0.5)]) {
                for(j=[0:pins-1]) {
                    translate([headerPinSpacing*j,0]) circle(d=pinHoleDiameter,$fn=18);
                }
            }
        }
    }
