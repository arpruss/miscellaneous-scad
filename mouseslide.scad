use <tubemesh.scad>;

right = 0;

boardThickness = right ? 5.27 : 9.52;
length = 114; // fix
deltaBottom = 1.5; // fix
deltaTop = 1.5; // fix
deltaRatio = 1.5;
bottomSlideWidth = 15;
topSlideWidth = 10;
holderWidth = 9;
tolerance = 0.1;
bottomMinimumThickness = 3.5;
bottomMaximumThickness = 9;
topThickness = 2;
holeDiameter = 4;
hole1Offset = 10; 
holeInsetDiameter = 8;
holeInset = 4;
numHoles = 4;

function crossSection(delta=0) =
        [[-holderWidth,-bottomMaximumThickness],
        [bottomSlideWidth/3,-bottomMaximumThickness],
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

nudge = 0.01;

render(convexity=2)
mirror([right?0:1,0,0])
difference() {
    slide();
    for (i=[0:numHoles-1]) {
        z = (length-(hole1Offset*2))/(numHoles-1)*i+hole1Offset;
        translate([-holderWidth/2,0,z])
        rotate([90,0,0]) {
        cylinder(h=100,d=holeDiameter,center=true,$fn=32);
        #translate([0,0,bottomMaximumThickness-holeInset+nudge]) cylinder(h=holeInset,d=holeInsetDiameter,center=false,$fn=32);
        }
    }
}