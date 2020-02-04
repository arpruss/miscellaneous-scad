use <tubemesh.scad>;

makeJoyMount = 1;

circleSeparation = 150;
radius = 40;
rectHeight = 50;
baseCurveHeight = 5;
height=10;
wallThickness=2;

buttonSideTolerance=0.2;
buttonFlange=2;

tactWidth = 5.91;
tactHeight = 5.91;
tactThickness = 4.93;
tactPillarHeight = 3.5;
tactPillarRatio = 0.87;
tactPillarTopWallThickness = 1.5;
tactPillarTopWallHeight = 2.5;

pressFitTolerance = 0.150;

joyMountPinSpacingX = 9.8;
joyMountPinSpacingY = 12.5;
joyMountPinLength = 3;
joyMountPinHoleDiameter = 1.5;
joyMountWidth = 30;
joyMountHeight = 27.5;
joyMountScrewHole = 3.5;
joyMountScrewOffset = 4;

$fn = 36;
nudge = 0.01;

joyMountScrewSpacingX = joyMountWidth-joyMountScrewOffset*2;
joyMountScrewSpacingY = joyMountHeight-joyMountScrewOffset*2;

function outline(sep, rectHeight, radius, $fn=36) = 
    let(
        angle0=asin((radius-rectHeight)/radius),
        angle1=180-asin((radius-rectHeight)/radius)) 
    concat( 
        [for(i=[1:$fn]) let(t=i/$fn,
            angle=angle1*(1-t)+(360+90)*t)
        [sep/2,0]+radius*[cos(angle),sin(angle)]],
        [for(i=[1:$fn]) let(t=i/$fn,
            angle=90*(1-t)+(360+angle0)*t)
        [-sep/2,0]+radius*[cos(angle),sin(angle)]]);

function delta0(z,baseCurveHeight=baseCurveHeight,startAngle=45) =         
    let(baseCurveRadius=baseCurveHeight/sin(startAngle),
        angle=asin((baseCurveHeight-z)/baseCurveRadius))
        baseCurveRadius*cos(angle);

function delta(h,baseCurveHeight=baseCurveHeight,startAngle=45) = delta0(h,baseCurveHeight=baseCurveHeight,startAngle=startAngle)-delta0(baseCurveHeight,baseCurveHeight=baseCurveHeight,startAngle=startAngle);     
        
        
module solidBowl(height=height,startAngle=45,delta=0) {
    
    sections = [for(i=[0:$fn])
    let(t=i/$fn,
    delta = delta(t*baseCurveHeight,startAngle=startAngle))
    sectionZ(outline(circleSeparation,rectHeight+2*delta,radius+delta),t*baseCurveHeight)];

tubeMesh(concat(sections,[sectionZ(outline(circleSeparation,rectHeight+2*delta,radius+delta),height)]));
}

module hollowBowl(height=height,startAngle=45) {
    difference() {
        solidBowl(height=height,startAngle=90);
        translate([0,0,wallThickness])
        solidBowl(height=height,startAngle=90,delta=-wallThickness);
    }
}

module button(radius=10, separation=5, roundingHeight=2, flangeSize=buttonFlange, flangeToTop=8, bumpSize=0) {
    
    function o(delta,z)=sectionZ(outline(separation,2*radius+2*delta,radius+delta),z);
    
    sections1 = roundingHeight ? [for(i=[0:$fn])
    let(t=i/$fn,
    delta = delta(t*roundingHeight,baseCurveHeight=roundingHeight,startAngle=45))
    o(delta,t*roundingHeight)] : [o(0,0)];
    sections2 = [o(0,flangeToTop),
    o(flangeSize,flangeToTop+flangeSize)];
    tubeMesh(concat(sections1,sections2));
    if(bumpSize)
    translate([0,0,flangeToTop-nudge])
    intersection() {
        translate([-bumpSize*2,-bumpSize*2,0]) cube([bumpSize*4,bumpSize*4,bumpSize*2]);
        sphere(r=bumpSize);
    }

}

module buttonWell(radius=10, separation=5,wellDepth=6,flangeSize=buttonFlange,positive=true) {
    
    function flat(delta)=outline(separation,2*radius+2*delta,radius+delta);
    function o(delta,z)=sectionZ(flat(delta),z);

    if (positive) {
        linear_extrude(height=wellDepth)
        polygon(flat(buttonSideTolerance+buttonFlange));
    }
    else {
        translate([0,0,-nudge]) button(flangeToTop=wellDepth+2*nudge-flangeSize, radius=radius+buttonSideTolerance,separation=separation,roundingHeight=0,flangeSize=flangeSize);
    }
}

/*difference() {
    buttonWell(positive=true);
    buttonWell(positive=false);
}
*/

module four(xs,ys) {
            for (i=[-1,1]) for(j=[-1,1]) translate([i*xs/2,j*ys/2]) children();;
}

module joyMount()
{
    linear_extrude(height=joyMountPinLength) 
    translate([joyMountWidth/2,joyMountHeight/2]) 
    difference() 
    {
        hull() union() four(joyMountWidth-joyMountScrewOffset*2,joyMountHeight-joyMountScrewOffset*2) circle(r=joyMountScrewOffset);
                four(joyMountPinSpacingX,joyMountPinSpacingY) circle(d=joyMountPinHoleDiameter);
            four(joyMountScrewSpacingX,joyMountScrewSpacingY) circle(d=joyMountScrewHole);
    }
}

function rect(w,h) = [for(ij=[[1,1],[-1,1],[-1,-1],[1,-1]]) [ij[0]*w/2,ij[1]*h/2]];

module tactPillar() {
    topWidth = tactWidth + 2 * tactPillarTopWallThickness + 2 * pressFitTolerance;
    topHeight = tactHeight + 2 * tactPillarTopWallThickness + 2 * pressFitTolerance;

    difference() {
        morphExtrude(rect(topWidth/tactPillarRatio,topHeight/tactPillarRatio),rect(topWidth,topHeight),height=tactPillarHeight+tactPillarTopWallHeight);
        translate([0,0,tactPillarTopWallHeight+tactPillarHeight]) cube([tactWidth+2*pressFitTolerance,tactWidth+2*pressFitTolerance,2*tactPillarTopWallHeight],center=true);
        translate([-topWidth/2,-topHeight/2,tactPillarHeight+1.5*tactPillarTopWallHeight]) cube([topWidth,topWidth,3*tactPillarTopWallHeight],center=true);
        translate([topWidth/2,topHeight/2,tactPillarHeight+1.5*tactPillarTopWallHeight]) cube([topWidth,topWidth,3*tactPillarTopWallHeight],center=true);
    }
}

/*
if (makeJoyMount) {
    joyMount();    
}
*/

tactPillar();
translate([50,0,0]) tactPillar();