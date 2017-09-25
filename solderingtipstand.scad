holeSize = 7.5;
holeDepth = 14;
depth = 44;
width = 64;
holesPerRow = 6;
numberOfRows = 4;
angle = 30;

minimumPlasticDepth = 2;

module dummy() {}

slope = tan(angle);
xSpacing = (width-holesPerRow*holeSize) / (1+holesPerRow);
ySpacing = (depth-numberOfRows*holeSize) / (1+numberOfRows);

delta = max(0, 2-(ySpacing+holeSize/2)*slope);

function getZ(y) = holeDepth+y*slope+delta;

echo(ySpacing);

module base() {
    rotate([0,0,90])
    rotate([90,0,0])
    linear_extrude(height=width)
    polygon([[0,0],[depth,0],[depth,getZ(depth-ySpacing-holeSize/2)],[depth-ySpacing-holeSize/2,getZ(depth-ySpacing-holeSize/2)],[0,getZ(0)]]);
}

module holes() {
    for (row=[0:numberOfRows-1])
       for (col=[0:holesPerRow-1]) {
            x=xSpacing+holeSize/2+col*(xSpacing+holeSize);
            y=ySpacing+holeSize/2+row*(ySpacing+holeSize);
            z=getZ(y);
            translate([x,y,z-holeDepth]) cylinder(d=holeSize,h=holeDepth+holeSize,$fn=36);
       }
}

render(convexity=4)
difference() {
    base();
    holes();
}
