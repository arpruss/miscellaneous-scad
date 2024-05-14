use <tubeMesh.scad>;

id = 43.95;
slit = 0.4;
frontThickness = 1.5;
sideThickness = 1.5;
length = 20;

nudge = 0.001;

$fn = 64;

module slit() {
    difference() {
        cylinder(d=id+2*sideThickness,h=frontThickness);
        tubeMesh(
            [sectionZ(squarePoints([slit-nudge*2,id]),-nudge),
             sectionZ(squarePoints([slit+2*frontThickness,id]),frontThickness+nudge)]);
    }
}

slit();
linear_extrude(height=length) difference() {
    circle(d=id+2*sideThickness);
    circle(d=id);
}
