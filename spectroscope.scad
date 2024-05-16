use <tubeMesh.scad>;
use <matrixUtils.scad>;

//<params>
mode = 0; //0:attach to tube, 1:include tube
mainTubeDiameter = 43.95;
slit = 0.4;
frontThickness = 1.5;
wall = 1.5;
eyeTubeDiameter = 32;
slideThickness = 2;
slideSize = 51.1;
// only for attach-to-tube mode
attachmentLength = 15;
// only for include-tube mode
mainTubeLength = 140;
//</params>

nudge = 0.001;

$fn = 80;

module slit(length) {
    difference() {
        cylinder(d=mainTubeDiameter+2*wall,h=frontThickness);
        tubeMesh(
            [sectionZ(squarePoints([slit-nudge*2,mainTubeDiameter]),-nudge),
             sectionZ(squarePoints([slit+2*frontThickness,mainTubeDiameter]),frontThickness+nudge)]);
    }
    linear_extrude(height=length) difference() {
        circle(d=mainTubeDiameter+2*wall);
        circle(d=mainTubeDiameter);
    }
}

h1 = 2*(slideSize - mainTubeDiameter)*1.05;
z1 = attachmentLength+h1;

module opticsSolid(extra=0,nudge=0) {
     h2 = (slideSize - eyeTubeDiameter)*1.45;
     sections = [
        sectionZ(ngonPoints(n=$fn,d=mainTubeDiameter+2*extra),-nudge),
        sectionZ(ngonPoints(n=$fn,d=mainTubeDiameter+2*extra),attachmentLength),
        sectionZ(squarePoints(slideSize+2*extra,n=$fn),z1),
        sectionZ(squarePoints(slideSize+2*extra,n=$fn),z1+slideThickness),
        multmatrixPoints(translateMatrix([0,0,h2])*rotateMatrix([30,0,0]), sectionZ(ngonPoints(n=$fn,d=eyeTubeDiameter+2*extra),nudge+attachmentLength+h2))
    ];
    tubeMesh(sections,optimize=floor($fn/4));
}

module optics() {
    difference() {
        opticsSolid(extra=wall);
        opticsSolid(nudge=0.01);
        translate([0,-slideSize/2,z1+slideThickness/2]) cube([slideSize,slideSize,slideThickness],center=true);
   }
}

if (mode == 0) {
    optics();
    translate([max(slideSize+5,mainTubeDiameter+5),0,0]) slit(attachmentLength);
}
else {
    rotate(90)
    slit(mainTubeLength);
    translate([0,0,mainTubeLength-attachmentLength]) optics();
}