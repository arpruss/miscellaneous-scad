use <tubeMesh.scad>;

length = 90;
tripodHoleFromBack = 20;
thickness = 10;
screwHeadThickness = 5;
screwHeadAreaDiameter = 35;
width = 90;
legWidth = 5;
legHeight = 15;
tripodScrewHole = 7;
chamfer = 2;

nudge = 0.001;

module chamferedCubeY(size,chamfer) {
    function layer(delta,z) = [
    [0,-delta,z],
    [size[0],-delta,z],
    [size[0],size[1]+delta,z],
    [0,size[1]+delta,z] ];
    tubeMesh([layer(0,0),layer(0,size[2]-chamfer),layer(-chamfer,size[2])]);
}

difference() {
    translate([-width/2-legWidth,0,0]) chamferedCubeY([width+2*legWidth,length,thickness],chamfer);
    translate([0,tripodHoleFromBack,0]) {
        translate([0,0,thickness-screwHeadThickness]) cylinder(d=screwHeadAreaDiameter,h=screwHeadThickness+nudge);
        translate([0,0,-nudge]) cylinder(d=tripodScrewHole,h=thickness+2*nudge);
    }
}

for (x=[-width/2-legWidth+nudge,width/2-nudge]) translate([x,0,0]) linear_extrude(height=legHeight+thickness) polygon(
        [[0,chamfer],[chamfer,0],[legWidth-chamfer,0],[legWidth,chamfer],[legWidth,length-chamfer],[legWidth-chamfer,length],[chamfer,length],[0,length-chamfer]]);
