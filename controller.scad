// add screw holes to right of center
// add holder for pcb to left of center
// make sure bottom and top button angles match

 use <tubemesh.scad>;
use <pointhull.scad>;
use <pcbholder.scad>;

makeJoyMount = 1;

circleSeparation = 140;
radius = 40;
baseCurveHeight = 5;
totalHeight = 30;
wallThickness=2;

screwMinorDiameter = 2.2;
screwMajorDiameter = 3.25;
screwLength = 11.1;
screwHeadDiameter = 6.36;
screwHeadThickness = 1.8;

topBottomFitTolerance = 0.3;
bottomStickoutDistance = 3;
bottomStickoutThickness = 1.5;
pcbWidthTolerance = 0;
pcbLengthTolerance = 0.15;

buttonSideTolerance=0.2;
buttonFlange=2;
buttonStickout=5;
bigButtonDiameter = 12;
bigButtonSeparation = 0;
bigButtonArrayAngle = 30;
smallButtonDiameter = 10;
smallButtonSeparation = 0;
tinyButtonDiameter = 8;
tinyButtonSeparation = 4;
bigButtonSpacing = 16;
bigButtonRows = 2;
bigButtonColumns = 3;
tinyButtonSpacing = 16;
tinyButtonRows = 2;
tinyButtonColumns = 1;

stickCutout = 22;

stickNeckDiameter = 9.84;
stickNeckLength = 3.5;
stickHeadDiameter = 16;
stickHeadThickness = 4; // 6.2;
stickBallRadius = 13;
stickBallThickness = 1.5;
stickBallOffset = -3;
stickWidth = 2.94;
stickHeight = 3.97;
stickLength = 5.3;
stickOffset = 4;
stickHeadRidge = 0.5;
stickWall = 1;

tactWidth = 5.91;
tactHeight = 5.91;
tactThickness = 4.93;
tactPillarHeight = 15; // calculate
tactPillarRatio = 0.67;
tactPillarTopWallThickness = 1.5;
tactPillarTopWallHeight = 2.5;

pressFitTolerance = 0.150;
looserTolerance = 0.25;

joyMountPinSpacingX = 9.8;
joyMountPinSpacingY = 12.5;
joyMountPinLength = 3;
joyMountPinHoleDiameter = 1.5;
joyMountWidth = 30;
joyMountHeight = 27.5;
joyMountScrewHole = 3.5;
joyMountScrewOffset = 4;

pcbWidth = 22.7;
pcbLength = 52.8;
pcbSlideLength = 35;
pcbScrewOffset = 5;

module dummy() {}

rectHeight = pcbLength+pcbLengthTolerance*2+2*wallThickness;

centerY = radius-rectHeight/2; 

screwDistanceFromPCB = 4;

screwTightHole = screwMinorDiameter + 2 * pressFitTolerance;
screwLooseHole = screwMajorDiameter + 2 * looserTolerance;

bottomScrewHole = screwTightHole;
bottomScrewHoleWall = 2;
bottomScrewHeadDiameter = screwHeadDiameter + 2*looserTolerance;
bottomScrewHeadThickness = screwHeadThickness + looserTolerance;

bottomScrewPositions = [ [-circleSeparation/2-radius*0.75,0], [circleSeparation/2+radius*0.75,0] ];

bottomScrewPostHeight = bottomScrewHoleWall+bottomScrewHeadThickness;

$fn = 32;
nudge = 0.01;

joyMountScrewSpacingX = joyMountWidth-joyMountScrewOffset*2;
joyMountScrewSpacingY = joyMountHeight-joyMountScrewOffset*2;

function uniqueLoop(v, soFar=[], pos=0) =
    pos >= len(v) ? soFar :
    v[pos] == v[(pos+1)%len(v)] ? uniqueLoop(v, soFar=soFar, pos=pos+1) :
    uniqueLoop(v, soFar=concat(soFar,[v[pos]]), pos=pos+1);
    

function outline(sep, rectHeight, radius) = 
    uniqueLoop(let(
        angle0=asin((radius-rectHeight)/radius),
        angle1=180-asin((radius-rectHeight)/radius)) 
    concat( 
        [for(i=[0:$fn]) let(t=i/$fn,
            angle=angle1*(1-t)+(360+90)*t)
        [sep/2,0]+radius*[cos(angle),sin(angle)]],
        [for(i=[0:$fn]) let(t=i/$fn,
            angle=90*(1-t)+(360+angle0)*t)
        [-sep/2,0]+radius*[cos(angle),sin(angle)]]));

function delta0(z,baseCurveHeight=baseCurveHeight,startAngle=45) =         
    let(baseCurveRadius=baseCurveHeight/sin(startAngle),
        angle=asin((baseCurveHeight-z)/baseCurveRadius))
        baseCurveRadius*cos(angle);

function delta(h,baseCurveHeight=baseCurveHeight,startAngle=45) = delta0(h,baseCurveHeight=baseCurveHeight,startAngle=startAngle)-delta0(baseCurveHeight,baseCurveHeight=baseCurveHeight,startAngle=startAngle);     
        
        
module solidBowl(height=totalHeight/2,radius=radius,startAngle=45,delta=0) {
    
    sections = [for(i=[0:$fn])
    let(t=i/$fn,
    delta = delta+delta(t*baseCurveHeight,startAngle=startAngle))
    sectionZ(outline(circleSeparation,rectHeight+2*delta,radius+delta),t*baseCurveHeight)];

tubeMesh(concat(sections,[sectionZ(outline(circleSeparation,rectHeight+2*delta,radius+delta),height)]));
}

module hollowBowl(height=totalHeight/2,startAngle=45, rim=false) {
    difference() {
        solidBowl(height=height,startAngle=90);
        translate([0,0,wallThickness])
        solidBowl(height=height,startAngle=90,delta=-wallThickness);
    }
    if (rim) {
        translate([0,0,height]) bowlRim();
    }
}

module bowlRim(height=bottomStickoutDistance,thickness=bottomStickoutThickness) {
    
    function o(delta)=outline(circleSeparation,rectHeight+2*delta,radius+delta);
    
    inset = wallThickness+looserTolerance*5+thickness;

    h = 1.5*(looserTolerance+thickness);

    translate([0,0,-h])
    difference() {
        linear_extrude(height=h+nudge) polygon(o(-wallThickness+nudge));
        morphExtrude(sectionZ(o(-wallThickness),-nudge),sectionZ(o(-inset),h+2*nudge));
    } 
    translate([0,0,-nudge])
    linear_extrude(height=height) {
        difference() {
            polygon(o(-inset+thickness));
            polygon(o(-inset));
        }
    }
}

module bottomScrew(positive=true) {
    if (positive) {
        cylinder(d=bottomScrewHoleWall*2+bottomScrewHeadDiameter,h=bottomScrewPostHeight);
    }
    else {
        translate([0,0,-nudge]) {
            cylinder(d=bottomScrewHole,h=bottomScrewPostHeight+2*nudge);
            cylinder(d=bottomScrewHeadDiameter,h=bottomScrewHeadThickness+nudge);
        }
    }
}

module bottomScrews(positive=true) {
    for (p=bottomScrewPositions)
    translate(p) bottomScrew(positive);
}

module bottom() {
    difference() {
        union() {
            hollowBowl(rim=true);
            bottomScrews(positive=true);
            translate([circleSeparation/2,0,0]) rotate([0,0,bigButtonArrayAngle]) tactPillarArray(rows=bigButtonRows,columns=bigButtonColumns,spacing=bigButtonSpacing);
            translate([0,centerY,0]) tactPillarArray(rows=tinyButtonRows,columns=tinyButtonColumns,spacing=tinyButtonSpacing,joinAll=true);
        }
        bottomScrews(positive=false);
    }
}

module top_unflipped() {
    cx = circleSeparation/2;
    difference() {
        union() {
            hollowBowl();
        }
        translate([0,0,-nudge]) {
            translate([-cx,0,0]) cylinder($fn=8,d=stickCutout,h=wallThickness+2*nudge);
        }
    }
}

module top() {
    mirror([1,0,0]) top_unflipped();
}

module button(radius=10, separation=5, roundingHeight=2, flangeSize=buttonFlange, flangeToTop=8, bumpSize=0,startAngle=45) {
    
    function o(delta,z)=sectionZ(outline(separation,2*radius+2*delta,radius+delta),z);
    
    sections1 = roundingHeight ? [for(i=[0:$fn])
    let(t=i/$fn,
    delta = delta(t*roundingHeight,baseCurveHeight=roundingHeight,startAngle=startAngle))
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

module tactPillar(truncated=false) {
    topWidth = tactWidth + 2 * tactPillarTopWallThickness + 2 * pressFitTolerance;
    topHeight = tactHeight + 2 * tactPillarTopWallThickness + 2 * pressFitTolerance;

    w = !truncated ? topWidth : topWidth*10;

    difference() {
        morphExtrude(rect(topWidth/tactPillarRatio,topHeight/tactPillarRatio),rect(topWidth,topHeight),height=tactPillarHeight+tactPillarTopWallHeight);
        translate([0,0,tactPillarTopWallHeight+tactPillarHeight]) cube([tactWidth+2*pressFitTolerance,tactWidth+2*pressFitTolerance,2*tactPillarTopWallHeight],center=true);
        translate([-topWidth/2,-topHeight/2,tactPillarHeight+1.5*tactPillarTopWallHeight]) cube([w,w,3*tactPillarTopWallHeight],center=true);
        translate([topWidth/2,topHeight/2,tactPillarHeight+1.5*tactPillarTopWallHeight]) cube([w,w,3*tactPillarTopWallHeight],center=true);
    }
}

module pyramidcube(xyz) {
    points = concat(
        [ for(x=[0:1]) for(y=[0:1]) for(z=[0:1]) [xyz[0]*x,xyz[1]*y,xyz[2]*z] ],
        [ [ xyz[0]/2, xyz[1]/2, xyz[2] + 0.5*max(xyz[0],xyz[1]) ] ] );
    pointHull(points);
}

module stickTop() {
    r = stickHeadDiameter/2-stickHeadThickness/2;
    rotate_extrude() {
        hull() {
        square([stickNeckDiameter/2,stickHeadThickness]);
        translate([r,stickHeadThickness/2])
       intersection() {
       circle(d=stickHeadThickness);
       translate([0,stickHeadThickness/2]) square(stickHeadThickness,center=true);
       }
   }
        translate([r,stickHeadThickness]) circle(r=stickHeadRidge);
        translate([r*2/3,stickHeadThickness]) circle(r=stickHeadRidge);
        translate([r*1/3,stickHeadThickness]) circle(r=stickHeadRidge);
    }
}

module stickCap() {
    pressFitTolerance = pressFitTolerance + 0.1;
    w1 = stickWidth+2*pressFitTolerance+2*stickWall;
    h1 = stickHeight+2*pressFitTolerance+2*stickWall;
    translate([0,0,stickBallRadius+stickBallOffset+stickNeckLength]) 
    
    stickTop();
    difference() {
        union() {
            translate([-w1/2,-h1/2,stickOffset])
            cube([w1,h1,stickLength+5]);
            intersection() {
                translate([0,0,stickBallOffset]) {                difference() {
                            union() {
cylinder(d=stickNeckDiameter,h=stickNeckLength+nudge+stickBallRadius);
                sphere(r=stickBallRadius);
                            }
                    sphere(r=stickBallRadius-stickBallThickness);
                }
                }
                cylinder(d=stickBallRadius*3,h=stickBallRadius*3+100);
            }
        }
        
            translate([-stickWidth/2-pressFitTolerance,-stickHeight/2-pressFitTolerance,stickOffset-nudge]) 
        pyramidcube([stickWidth+2*pressFitTolerance,stickHeight+2*pressFitTolerance,stickLength+2*nudge]);
    }
}

module pcbSlide() {
    pcbHolder(screwDistanceFromPCB=screwDistanceFromPCB, pcbWidth=pcbWidth,
    screw1DistanceFromFront=pcbScrewOffset,
    screw2DistanceFromFront=pcbSlideLength-pcbScrewOffset,
    pcbLength=pcbSlideLength,rearHole=1000,screwHoleDiameter=screwTightHole,tolerance=pcbWidthTolerance);
    
}

module buttonArray(rows=2,columns=3,spacing=20,joinRows=false) {
    y0 = -spacing * (rows-1) / 2;
    x0 = -spacing * (columns-1) / 2;
    
    module a() {
        for(i=[0:columns-1]) translate([x0+i*spacing,0,0]) children();
    }

    for (i=[0:rows-1]) translate([0,i*spacing+y0,0]) if (joinRows) hull() a() children(); else a() children();
}

module tactPillarArray(rows=2,columns=3,spacing=20,joinRows=true, joinAll=false) {
    buttonArray(rows=rows,columns=columns,spacing=spacing,joinRows=false) tactPillar();
    if (joinRows) buttonArray(rows=rows,columns=columns,spacing=spacing,joinRows=joinRows) tactPillar(truncated=true);
    if (joinAll) hull() buttonArray(rows=rows,columns=columns,spacing=spacing,joinRows=joinRows) tactPillar(truncated=true);
}

bottom();
//pcbSlide();
