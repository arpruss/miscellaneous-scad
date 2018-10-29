use <tubemesh.scad>;

boardThickness = 4; // fix
length = 80; // fix
deltaBottom = 0.8; // fix
deltaTop = 1.8; // fix
deltaRatio = 1.5;
right = 0;
bottomSlideWidth = 15;
topSlideWidth = 10;
holderWidth = 9;
tolerance = 0.5;
bottomMinimumThickness = 3.5;
bottomMaximumThickness = 5;
topThickness = 2;
holeDiameter = 4;
hole1Offset = 20; 
numHoles = 3;

function crossSection(delta=0) =
        [[-holderWidth,-bottomMaximumThickness],
        [bottomSlideWidth,-bottomMinimumThickness],
        [bottomSlideWidth,-delta],
        [-delta,-delta],
        [-delta,boardThickness+tolerance+delta],
        [topSlideWidth,boardThickness+tolerance+delta],
        [topSlideWidth,boardThickness+tolerance+topThickness],
        [-holderWidth,boardThickness+tolerance+topThickness]];

module slide() {
    s0 = crossSection(delta=deltaBottom);
    s1 = crossSection();
    s2 = crossSection(delta=deltaTop);
    tubeMesh([sectionZ(s0,0), sectionZ(s1,deltaBottom*deltaRatio), sectionZ(s1,length-(deltaBottom+deltaTop)*deltaRatio), sectionZ(s2,length)]);
}

render(convexity=2)
mirror([right?0:1,0,0])
difference() {
    slide();
    for (i=[0:numHoles-1]) {
        z = (length-(hole1Offset*2))/(numHoles-1)*i+hole1Offset;
        translate([-holderWidth/2,0,z])
        rotate([90,0,0])
        cylinder(h=100,d=holeDiameter,center=true,$fn=32);
    }
}