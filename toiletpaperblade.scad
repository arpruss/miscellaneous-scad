
bladeWidth = 17;
bladeLength = 100; // (downstairs 120);
bladeMaxThickness = 5;
bladeMinThickness = .75;
toothLength = 6;
toothBottomAngle = 40;
toothTopAngle = 70;
mountWall = 1.5;
mountInnerDiameter = 22.16; // (downstairs 19.6)
mountTolerance = 0.2;
mountSlitAngle = 6;
holdingStripThickness = 2;
holdingStripWidth = 15;
tabWidth = 10;
screwHole = 4.5;

module dummy() {}

nudge = 0.01;

bottomPitch = tan(90-toothBottomAngle) * toothLength;
topPitch = tan(90-toothTopAngle) * toothLength;
pitch = bottomPitch+topPitch;
count = ceil(bladeLength/pitch);
adjustedLength = count * pitch;

$fn = 64;

maxStripPosition = adjustedLength-holdingStripWidth/2;
function adjust(z) = max(tabWidth+holdingStripWidth/2,min(z,adjustedLength-holdingStripWidth/2));
strapZ = [ adjust(adjustedLength*1/3), adjust(adjustedLength*2/3) ];

module teeth2D() {
    edge = [for(i=[0:count-1]) for(xy=i<count-1?[[bladeWidth-toothLength,pitch*i],[bladeWidth,pitch*i+bottomPitch]]:[[bladeWidth-toothLength,pitch*i],[bladeWidth,pitch*i+bottomPitch],[bladeWidth-toothLength,pitch*(i+1)]]) xy];
    polygon(concat([[0,adjustedLength],[0,0]],edge));
}

module teeth() {
    translate([r,0,0])
    intersection() {
    rotate([90,0,0])
    translate([0,0,-bladeMaxThickness/2]) linear_extrude(height=bladeMaxThickness) teeth2D();
        linear_extrude(height=adjustedLength)
        polygon([[0,-bladeMaxThickness/2],[bladeWidth,-bladeMinThickness/2],[bladeWidth,bladeMinThickness/2],[0,bladeMaxThickness/2]]);
    }
}

r = mountInnerDiameter/2+mountTolerance;

module mount() {
    rotate([0,0,180+mountSlitAngle/2])
    rotate_extrude(angle=360-mountSlitAngle) #translate([r,0]) 
    { 
        square([mountWall,adjustedLength]);
        for (z=strapZ)
      translate([0,z-holdingStripWidth/2]) printableRectangle(holdingStripThickness,holdingStripWidth);
    }
}

module printableRectangle(w,h) {
    polygon([[0,-w],[w,0],[w,h],[0,h]]);
}

module tab(i) {
    angle = holdingStripThickness/(2*PI*r)*360;
    for(a=[180-mountSlitAngle/2-angle,180+mountSlitAngle/2])     rotate([0,0,a]) rotate_extrude(angle=holdingStripThickness/(2*PI*r)*360)
    translate([r+mountWall-nudge,strapZ[i]-holdingStripWidth/2]) difference() {
        printableRectangle(tabWidth,holdingStripWidth);
        translate([tabWidth/2,holdingStripWidth/2]) circle(d=screwHole);
    }
}

mount();
tab(0);
tab(1);
teeth();