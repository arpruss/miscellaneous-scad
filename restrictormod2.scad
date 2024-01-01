use <Bezier.scad>;
use <tubeMesh.scad>;

//<params>
mode = 4; //[0:vertical, 2:horizontal, 4:four-way]
bottomDiameter = 21.97;
topDiameter = 19.44;
octagonTolerance = .13;
postTolerance = .27;
restrictorHeight = 7;
baseHeight = 6;
neckHeight = 3;
neckExpansion = .25;
outerDiameter = 34;
postDiameter = 4.11;
postSpacing = 27.06;
postHoleExpansion = 0.5;
flowerCircleRatio = .45; // .5 works
inset = 1.5;
topInset = 1;
//</params>
nudge = .001;

slope = (bottomDiameter-topDiameter)/2/restrictorHeight;

$fn = 64;

module hole() {
    d0 = postDiameter+2*postTolerance;
    cylinder(d=d0,h=baseHeight); 
    translate([0,0,baseHeight-postHoleExpansion]) cylinder(d1=d0,d2=d0+postHoleExpansion*2,h=postHoleExpansion+2*nudge);    
    translate([0,0,baseHeight-nudge]) cylinder(d=d0+postHoleExpansion*2,h=10);    
}

module outerShape() {
    difference() {
        union() {
            translate([0,0,baseHeight-nudge]) cylinder($fn=8,d2=topDiameter-2*octagonTolerance,d1=bottomDiameter-2*octagonTolerance,h=restrictorHeight);
            cylinder(d1=outerDiameter+baseHeight/3, d2=outerDiameter, h=baseHeight);
        }
        for (s=[-1,1]) translate([postSpacing/2*s,0,-nudge]) hole();
    }

    translate([0,0,baseHeight-nudge]) cylinder($fn=8,d1=topDiameter-2*octagonTolerance,d2=topDiameter-2*octagonTolerance+neckExpansion*2,h=restrictorHeight+neckHeight);
}

function innerOutlineBezier(r1,ratio=flowerCircleRatio) = let(b=Bezier([[0,1],
        POLAR(1/4,0),
        POLAR(1/4,135),[PI/4-PI/24,1-ratio/2],POLAR(1/12/2,135+180), 
    POLAR(1/16/2,180), 
    [PI/4,1-ratio/2-.05],
    REPEAT_MIRRORED([1,0]),REPEAT_MIRRORED([1,0]),REPEAT_MIRRORED([1,0])]))
    [for(tr=b) let(angle=tr[0]*180/PI,r=r1*tr[1]) r*[cos(angle),sin(angle)]];
        
function horizontal(outline) = [for(z=outline) let(angle=atan2(z[1],z[0])) if(angle >= -40 && angle<=40 || angle >= 140 || angle<=-140) z ];

function vertical(outline) = [for(z=outline) let(aa=abs(atan2(z[1],z[0]))) if(aa >= 50 && aa<=130) z ];

module innerOutline(d) {
    for (a=[0:90:270]) rotate(a) translate([d/2-flowerCircleRatio*d/2,0]) circle(flowerCircleRatio*d/2);
}

module innerShapeBezier() {
    inner = innerOutlineBezier(bottomDiameter/2+slope*baseHeight-inset);
    section1 =  sectionZ(mode==4 ? inner : mode == 2 ? horizontal(inner) : vertical(inner),-nudge);
    nPoints = len(section1);
    section2 = sectionZ( ngonPoints(r=topDiameter/2-inset,n=nPoints),baseHeight+restrictorHeight);
    section3 = sectionZ(ngonPoints(r=topDiameter/2-topInset+neckExpansion,n=8),baseHeight+restrictorHeight+neckHeight+nudge);
    tubeMesh([section1, section2, section3]);
}

module innerShape() {
    scale = (topDiameter/2+slope*(restrictorHeight+baseHeight))/(bottomDiameter/2);
    
    translate([0,0,-nudge])
    linear_extrude(scale=1/scale,height=restrictorHeight+baseHeight+2*nudge) innerOutline((topDiameter-2*inset)*scale);
    translate([0,0,restrictorHeight+baseHeight-nudge])
    linear_extrude(height=neckHeight+2*nudge) scale(1/scale) innerOutline(topDiameter-2*inset); 
}

difference() {
    outerShape();
    innerShapeBezier();
}

