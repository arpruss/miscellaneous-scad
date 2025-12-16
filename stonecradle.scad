stoneLength = 100;
stoneThickness = 5;
stoneWidth = 20;
sideWall = 2;
endWall = 2.5;
recess = 2.5;
lipThickness = 1.5;
lipLength = 4;
backingThickness = 2;
stickoutSize = 3;
stoneHolderWidth = 2;
thicknessTolerance = 0.25;
endTolerance = 0.25;
sideTolerance = 0.2;

module dummy() {}

l = stoneLength+2*endWall+2*endTolerance+2*stickoutSize;
hStone = stoneThickness+2*thicknessTolerance;
h1 = hStone-thicknessTolerance+backingThickness-recess;
h2 = hStone+backingThickness+lipThickness;
w = sideWall*2+2*sideTolerance+stoneWidth;

module side() {
    polygon([
        [0,0], [l,0], [l-stickoutSize,stickoutSize],
        [l-stickoutSize,h2],[l-stickoutSize-lipLength,h2],[l-stickoutSize-lipLength-(h2-h1),h1],
        [stickoutSize+lipLength+(h2-h1),h1],[stickoutSize+lipLength,h2],[stickoutSize,h2],
        [stickoutSize,stickoutSize] ]);
}

difference() {
    translate([-l/2,0,0]) rotate([90,0,0]) linear_extrude(height=w,center=true) side();
    translate([0,0,hStone/2+backingThickness]) cube([stoneLength+2*endTolerance,stoneWidth+2*sideTolerance,hStone],center=true);
}