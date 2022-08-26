coverSlipSize = 22.14;
coverSlipThickness = 0.16;
coverSlipOverlap = 3;
length = 76;
width = 26.4;
thickness = 1.5;
tolerance = 0.5;

module dummy() {}

nudge = 0.001;
slipHoleSize = coverSlipSize-2*coverSlipOverlap;
slipAdj = coverSlipSize + 2*tolerance;

render(convexity=2)
difference() {
    translate([-length/2,-width/2,0]) cube([length,width,thickness]);
    translate([-slipHoleSize/2,-slipHoleSize/2,-nudge]) cube([slipHoleSize,slipHoleSize,thickness+2*nudge]);
    translate([-slipAdj/2,-slipAdj/2,thickness-coverSlipThickness]) cube([slipAdj,slipAdj,coverSlipThickness+nudge]);
}
