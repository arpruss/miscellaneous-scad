use <roundedSquare.scad>;
use <tubeMesh.scad>;

//<params>
cartWidth = 82;
cartDepth = 20;
tolerance = 0.6;
holderRim = 5;
wall = 3.5;
holderHeight = 28;
holderRounding = 3;
baseThickness = 5;
baseOuterThickness = 2;
baseExtra = 10;
baseRounding = 5;
flareHeight = 5;
flareThickness = 2;
//</params>

module dummy() {}

width1 = cartWidth + 2*tolerance;
depth1 = cartDepth + 2*tolerance;
holderWidth = width1 + 2*wall;
holderDepth = depth1 + 2*wall;
widthBase = holderWidth + 2*baseExtra;
depthBase = holderDepth + 2*baseExtra;
nudge = 0.01;
$fn = 64;

function rect(w,h) = [[w/2,-h/2],[w/2,h/2],[-w/2,h/2],[-w/2,-h/2]];
function roundedRect(w,h,r,n=60) =
    [for(i=[0:$fn-1])
        let(angle = i / $fn * 360,
            s = angle <= 90 ? [1,1] :
                angle <= 180 ? [-1,1] :
                angle <= 270 ? [-1,-1] :
                [1,-1])
            [s[0]*(w/2-r)+r*cos(angle),s[1]*(h/2-r)+r*sin(angle)]];                    

module cart() {
    sections = [
        sectionZ(roundedRect(width1,depth1,.1),0),
        sectionZ(roundedRect(width1,depth1,.1),holderHeight-flareHeight),
        sectionZ(roundedRect(width1+2*flareThickness,depth1+2*flareThickness,max(.1,holderRounding-flareThickness)),holderHeight+nudge)
    ];
    tubeMesh(sections);
}

module main() {
    sections = [sectionZ(roundedRect(widthBase,depthBase,baseRounding),0),
                sectionZ(roundedRect(widthBase,depthBase,baseRounding),baseOuterThickness),
                sectionZ(roundedRect(holderWidth,holderDepth,holderRounding),baseThickness),
                sectionZ(roundedRect(holderWidth,holderDepth,holderRounding),baseThickness+holderHeight)];
    difference() {
/*        union() {
            linear_extrude(height=baseThickness) roundedSquare([widthBase,depthBase],radius=baseRounding,center=true);
            linear_extrude(height=baseThickness+holderHeight) roundedSquare([holderWidth,holderDepth],radius=holderRounding,center=true);
        }*/
        tubeMesh(sections);
        translate([0,0,baseThickness+holderRim+holderHeight]) cube([holderWidth-2*wall-2*holderRim,holderDepth+nudge,holderHeight*2],center=true);
        translate([0,0,baseThickness]) cart();
    }
    
}

main();
//polygon(roundedRect(20,20,3));