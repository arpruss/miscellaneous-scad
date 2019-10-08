use <paths.scad>;

//<params>
phoneWidth = 77.5;
snapHeight = 10.6;
thickness = 4;
holderHeight = 52;

tubeDiameterBottom = 35;
tubeDiameterTop = 25;
tubeGrabberHeight = 40;
tubeGrabberStalkThickness = 15;
tubeGrabberStalkLengthBottom = 5;
tubeGrabberStalkLengthTop = 20;
tubeGrabberWall = 3;
tubeGrabberScrewAreaWall = 4;
tubeGrabberScrewAreaWidth = 15;
tubeExtraDepthBottom = 0;
tubeExtraDepthTop = 20;
tubeTolerance = 1;
cinch = 4;

screwPosition1 = 0.25;
screwPosition2 = 0.75;
screwHoleDiameter = 5;

delta1 = 1;
delta2 = 3.75;
delta3 = 4.75;
bumpHeight = 3;
snapInset = 1.5;
snapThickness = 1.5;
rounding = 0.8;
//</params>

module dummy() {}

extraThickness = thickness - bumpHeight;
b1 = phoneWidth + 2*delta1;
b1a = phoneWidth + 2*delta2;
b2 = phoneWidth + 2*delta3;
h1a = bumpHeight / 3;

nudge = 0.001;

rightPath = 
  [ [b1/2,0],
    [b1a/2,h1a],
    [b2/2,bumpHeight],
    [b2/2,bumpHeight+extraThickness],
    [phoneWidth/2+snapThickness,bumpHeight+extraThickness+snapHeight*0.5],
    [phoneWidth/2+snapThickness,bumpHeight+extraThickness+snapHeight+snapThickness+2],
    [phoneWidth/2-snapInset,bumpHeight+extraThickness+snapHeight+snapThickness],
    [phoneWidth/2-snapInset,bumpHeight+extraThickness+snapHeight],
    [phoneWidth/2,bumpHeight+extraThickness+snapHeight],
    [phoneWidth/2,bumpHeight+extraThickness],
    [0, bumpHeight+extraThickness]];
    
    
path = stitchPaths(rightPath,reverseArray(transformPath(mirrorMatrix([1,0]),rightPath)));

module mainHolder() {
    linear_extrude(height=holderHeight) 
offset(r=-rounding) offset(r=rounding) polygon(points=path);
}

module tube(outset=0) {
    nudgez = outset==0 ? nudge : 0;
    hull() {
        for (dy=[0,-tubeExtraDepthBottom]) 
        translate([0,-tubeGrabberStalkLengthBottom-tubeGrabberWall-tubeTolerance-tubeDiameterBottom/2+dy,-nudgez])
        cylinder(d=tubeDiameterBottom+2*tubeTolerance+2*outset,h=nudge);
        for (dy=[0,-tubeExtraDepthTop]) 
        translate([0,-tubeGrabberStalkLengthTop-tubeGrabberWall-tubeTolerance-tubeDiameterTop/2+dy,tubeGrabberHeight-nudge+nudgez])
        cylinder(d=tubeDiameterTop+2*tubeTolerance+2*outset,h=nudge);        
    }
    if(outset>0) {
        hull() for (dydz=[[tubeGrabberStalkLengthBottom,0,tubeDiameterBottom],[tubeGrabberStalkLengthTop,tubeGrabberHeight-nudge,tubeDiameterTop]]) {
            {
                dy = dydz[0];
                dz = dydz[1];
                tubeDiameter = dydz[2];
                translate([-tubeGrabberStalkThickness/2,-dy-tubeDiameter/2-nudge,dz])
              cube([tubeGrabberStalkThickness,dy+tubeDiameter/2+2*nudge,nudge]);
            }
        }
}   


    w = outset>0 ? (tubeGrabberScrewAreaWall*2+cinch) : cinch;
    nudgey = outset>0 ? 0 : nudge;
        hull() for (dydz=[[tubeGrabberStalkLengthBottom+tubeExtraDepthBottom+nudgey,-nudgez,tubeDiameterBottom],[tubeGrabberStalkLengthTop+tubeExtraDepthTop+nudgey,tubeGrabberHeight-nudge+nudgez,tubeDiameterTop]]) {
            dy = dydz[0];
            dz = dydz[1];
            tubeDiameter = dydz[2];
            translate([-w/2,-tubeGrabberScrewAreaWidth-dy-tubeDiameter-tubeTolerance/2-tubeGrabberWall*2,dz]) cube([w,tubeGrabberScrewAreaWidth+tubeDiameter/2,nudge]);
        }

}

module screwStuff() {
    syBottom = -tubeGrabberStalkLengthBottom-tubeExtraDepthBottom-tubeGrabberScrewAreaWidth/2-tubeDiameterBottom-tubeTolerance/2-tubeGrabberWall*2;
    syTop = -tubeGrabberStalkLengthTop-tubeExtraDepthTop-tubeGrabberScrewAreaWidth/2-tubeDiameterTop-tubeTolerance/2-tubeGrabberWall*2;
    sy1 = syBottom * (1-screwPosition1) + syTop * screwPosition1;
    sy2 = syBottom * (1-screwPosition2) + syTop * screwPosition2;
    sz1 = screwPosition1 * tubeGrabberHeight;
    sz2 = screwPosition2 * tubeGrabberHeight;
    for (pos=[[sy1,sz1],[sy2,sz2]]) 
        translate([0,pos[0],pos[1]]) rotate([0,90,0])
    cylinder(d=screwHoleDiameter,h=tubeGrabberScrewAreaWall*2+cinch+2*nudge,center=true,$fn=12);
}

mainHolder();
difference() {
    tube(outset=tubeGrabberWall);
    tube(outset=0);
    screwStuff();
}
