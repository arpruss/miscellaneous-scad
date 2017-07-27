use <tubemesh.scad>;

boatWidth = 172;
attachmentBlockHeight = 10;
attachmentBlockWidth = 50;
attachmentBlockLength = 40;
sideStrapHeight = 50;
rearSlope = 2.02;
strapThickness = 3;

screwHoleSize = 2.6;
screwSpacingY = 9.96;
screwSpacingX = 27.9;
spikeThickness = 6;
spikeLength = 8;

module dummy() {}

nudge = 0.001;

topLength = attachmentBlockLength+attachmentBlockHeight;

module straps() {
    module spike(l) {
       morphExtrude([[0,-nudge,0],[spikeThickness,-nudge,0],[spikeThickness,-nudge,spikeThickness],[0,-nudge,spikeThickness]], [[0,l,0],[0,l,spikeThickness]], numSlices=1);
         }
    module sideStrap() {
        bottomLength = topLength - sideStrapHeight / rearSlope;
        prism(base=[[-topLength,0,-sideStrapHeight],[-sideStrapHeight/rearSlope,0,-sideStrapHeight],[0,0,0],[-topLength,0,0]],vertical=[0,strapThickness,0]);
        translate([-topLength,strapThickness,-sideStrapHeight]) spike(spikeLength);
        translate([-topLength,strapThickness,-sideStrapHeight*0.65]) spike(spikeLength*0.65);
    }
    sideStrap();
    translate([0,boatWidth+2*strapThickness,0]) mirror([0,1,0]) sideStrap();
    translate([-topLength,0,0])
    cube([topLength,boatWidth+2*strapThickness+nudge,nudge+strapThickness]);
    translate([-topLength,strapThickness,0])
        for(t=[1/4,1/2,3/4]) translate([0,t*boatWidth,0]) rotate([-90,0,0]) spike(spikeLength*1.1);
}

module attachmentBlock() {
    prism(base=[[-topLength,0,strapThickness],[0,0,strapThickness],[0,0,attachmentBlockHeight],[-attachmentBlockLength,0,attachmentBlockHeight]], vertical=[0,attachmentBlockWidth,0]);
}

module mainBody() {
    translate([0,-strapThickness,0]) {
        straps();
        translate([0,boatWidth/2+strapThickness-attachmentBlockWidth/2,0])
        attachmentBlock();
    }
}

module screwHole() {
    translate([0,0,-nudge])
    cylinder(d=screwHoleSize,h=attachmentBlockHeight+2*nudge,$fn=16);
}

module screwHoles() {
    screwRearX = screwSpacingX/2-attachmentBlockLength/2;
    screwPositions = [ [screwRearX,-screwSpacingY/2,0], [screwRearX,screwSpacingY/2,0], [screwRearX-screwSpacingX,0,0]];
    translate([0,boatWidth/2,0])
    for (v=screwPositions) translate(v) screwHole();
}

module main() {
    render(convexity=3)
    difference() {
        mainBody();
        screwHoles();
    }
}

//rotate([0,-90,0])
main();
