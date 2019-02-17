use <tubemesh.scad>;

//<params>
baseThickness = 4;
length = 60;
kerf = 1.6;
tubingDiameter = 23.5;
clampingWidth = 30;
minWall = 2.5;
tubingTolerance = 0.15;
kerfTolerance = 0.1;
endAngle = 30;
stopWall = 2;
cornerSize = 4;
extraCutHeight = 2;
part = 2; // [0:miter,1:right end stop,2:left end stop]
//</params>

module dummy() {}

nudge = 0.01;
length1 = part==0 ? length : length/2;
kerf1 = kerf+kerfTolerance;
tubingDiameter1 = tubingDiameter + 2 * tubingTolerance;
tubingMax = tubingDiameter1 + 2*minWall;
clampingWidth1 = clampingWidth + cornerSize;
tubeCutHeight = tubingDiameter1 + extraCutHeight; 
module solid() {
    cornerTri = [[nudge,0],[-cornerSize,0],[nudge,cornerSize]];
    sideProfile = [[0,0],[length1,0],[length1,extraCutHeight+tubingDiameter1/2],[length1-((part==0)?(tubeCutHeight-tubingDiameter1/2)*tan(endAngle):0),extraCutHeight+tubeCutHeight],[(tubeCutHeight-tubingDiameter1/2)*tan(endAngle),extraCutHeight+tubeCutHeight],[0,extraCutHeight+tubingDiameter1/2]];
    
    translate([0,-clampingWidth1-tubingMax/2,0]) cube([length1,tubingMax+clampingWidth1,baseThickness+nudge]);
    translate([0,-tubingMax/2,baseThickness]) 
    difference() {
        union() {
            tubeMesh([sectionY(sideProfile,0),sectionY(sideProfile,tubingMax)]);
            tubeMesh([sectionX(cornerTri,0),sectionX(cornerTri,length1)]);
        }
        translate([-nudge,tubingMax/2,tubingDiameter1/2+extraCutHeight]) rotate([0,90,0]) cylinder(d=tubingDiameter1,h=length1+2*nudge);
        translate([-nudge,tubingMax/2-tubingDiameter1*cos(45)/2,tubingDiameter1/2]) cube([length1+2*nudge,tubingDiameter1*cos(45),tubeCutHeight]);
     
    }
}

render(convexity=2)
if (part==0) {
    difference() {
        solid();
        translate([length1/2-kerf1/2,-tubingMax/2-cornerSize ,baseThickness]) cube([kerf1,tubingMax+cornerSize+nudge,extraCutHeight+tubingMax+nudge]);
    }
}
else if (part==1 || part==2) {
    mirror([part==2?1:0,0,0]) {
        solid();
        translate([length1-stopWall,-tubingMax/2,0]) cube([stopWall,tubingMax,extraCutHeight+tubeCutHeight+baseThickness+nudge]);
    }
}