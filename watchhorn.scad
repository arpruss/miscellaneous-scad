use <horn.scad>;
use <roundedsquare.scad>;

//<params>
length = 100;
throatWidth = 45;
throatHeight = 40;
mouthWidth = 120;
mouthHeight = 60;
wallThickness = 1.4;
numSections = 20;
flangeLength = 4;
flangeFlare = 3;

watchHolder = 1; // [1:yes, 0:no]
holderCutFromFront = 3;
holderCutHeight = 23;
holderCutThickness = 4;
holderBackWall = 2.5;
holderSideWall = 4;
holderCeiling = 3;
holderDepth = 20;
holderFootWidth = 7;
holderFootThickness = 2;
tolerance = 0.75;
//</params>

module dummy(){}

nudge = 0.001;

module myHorn() {
    horn(length=length, throat=[throatWidth,throatHeight], mouth=[mouthWidth,mouthHeight], wallThickness=wallThickness, numSections=numSections, flangeLength=flangeLength, flangeFlare=flangeFlare);
}

module myFlange() {
    horn(length=length, throat=[throatWidth+tolerance*2,throatHeight+tolerance*2+flangeFlare*4], mouth=[mouthWidth+tolerance*2,mouthHeight+tolerance*2], wallThickness=wallThickness, numSections=numSections, flangeLength=flangeLength+tolerance, flangeFlare=flangeFlare, solidFlangeOnly=true);
}

module holder() {
    w = throatWidth + 2 * wallThickness + 2*flangeFlare + 2*tolerance + 2*holderSideWall;
    h0 = 0.5 * (mouthHeight - throatHeight);
    h = throatHeight + 2*flangeFlare + h0 + wallThickness;
    render(convexity=5)
    difference() {
        translate([-w/2,0,0])
        cube([w,flangeLength+tolerance+holderDepth+holderBackWall,h]);
        
        translate([0,-nudge,h0+throatHeight/2+wallThickness+tolerance])
        rotate([-90,0,0])
        myFlange();
    translate([-w/2-nudge,-nudge,h0+throatHeight*0.75+wallThickness+2*tolerance]) cube([w+2*nudge,flangeLength+tolerance+nudge,nudge+flangeFlare+throatHeight]);
        
        translate([-w/2-nudge,tolerance+flangeLength+holderCutFromFront,h0+throatHeight/2+wallThickness+tolerance-holderCutHeight/2]) cube([w+2*nudge,holderCutThickness,h]);
        translate([-w/2+holderSideWall+flangeFlare,-nudge,h0]) {
            cube([w-2*holderSideWall-2*flangeFlare,flangeLength+tolerance+holderDepth+nudge,h-h0-holderCeiling]);
            cube([w-2*holderSideWall-2*flangeFlare,flangeLength+holderCutFromFront+holderCutThickness+nudge,h+nudge-h0]);
        } 
    }
    linear_extrude(height=holderFootThickness)
    translate([-w/2-holderFootWidth,-holderFootWidth])
    roundedSquare([w+2*holderFootWidth,holderDepth+holderBackWall+2*holderFootWidth],radius=holderFootWidth);
}

if (watchHolder)
    holder();
else
    myHorn();