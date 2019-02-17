use <tubemesh.scad>;

boardThickness = 5.27;
length = 114; 
inset1 = 1.5; 
inset2 = 1.5; 
insetRatio = 1.5;
bottomSlideWidth = 15;
topSlideWidth = 10;
holderWidth = 9;
tolerance = 0;
bottomMinimumThickness = 3.5;
bottomMaximumThickness = 5;
topThickness = 2;
holeDiameter = 4;
hole1Offset = 10; 
numHoles = 4;

function crossSection(inset=0) =
        [[-holderWidth,-bottomMaximumThickness],
        [bottomSlideWidth,-bottomMinimumThickness],
        [bottomSlideWidth,-inset],
        [-inset,-inset],
        [-inset,boardThickness+tolerance+inset],
        [topSlideWidth,boardThickness+tolerance+inset],
        [topSlideWidth,boardThickness+tolerance+topThickness],
        [-holderWidth,boardThickness+tolerance+topThickness]];

module slide() {
    s0 = crossSection(inset=inset1);
    s1 = crossSection();
    s2 = crossSection(inset=inset2);
    tubeMesh([sectionZ(s0,0), sectionZ(s1,inset1*insetRatio), sectionZ(s1,length-(inset1+inset2)*insetRatio), sectionZ(s2,length)]);
}

rotate([90,0,0])
render(convexity=2)
difference() {
    slide();
    for (i=[0:numHoles-1]) {
        z = (length-(hole1Offset*2))/(numHoles-1)*i+hole1Offset;
        translate([-holderWidth/2,0,z])
        rotate([90,0,0])
        cylinder(h=100,d=holeDiameter,center=true,$fn=32);
    }
}