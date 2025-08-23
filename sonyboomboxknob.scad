use <Bezier.scad>;
use <paths.scad>;

//<params>
trimForNoSupport = 1;

//outer stuff
height = 15.43;
bottomDiameter = 17.15;
topDiameter = 10.73;
topDiameterToTip = .89;
ribStart = 5.26;
ribEnd = 13.65;
ribWidth = .81;
ribHeight = .62;
indicatorLength = 2.8;
numberOfRibs = 24;
wallThickness = 1.5;
looseTolerance = .3;
tightTolerance = .18;
topAngle = 55;
// inner stuff
slitInStem = 1.5;
stemDiameter = 5.94;
innerHeight = 13.8;
innerSlitHeight = 7;
innerInset = 1.23;
//</params>

outerRadius = bottomDiameter/2+looseTolerance;

$fn = 128;
nudge = 0.005;

function profile(wall) = [ [0,0], LINE(), [outerRadius-wall,0], LINE(),
            [outerRadius-wall,ribStart], POLAR(1,90),
            POLAR(5,-topAngle), [topDiameter/2-wall,height-topDiameterToTip-wall], wall==0?POLAR(topDiameterToTip/2,180-topAngle):LINE(), wall==0?POLAR(topDiameter/2.5,0):LINE(), [0,wall==0?height:height-topDiameterToTip-wall] ];
            
outerProfile = Bezier(profile(0));
            
shortRibTop =  findCoordinateIntersections(outerProfile,1,ribEnd)[0];           
shortRibProfile = [ [outerRadius,ribStart],
    LINE(), [outerRadius+ribHeight,ribStart+ribHeight], POLAR(1,90), POLAR(5,-topAngle), shortRibTop+[ribHeight/sqrt(2),ribHeight/sqrt(2)], LINE(), 
    [topDiameter/4,height-topDiameterToTip+ribHeight/sqrt(2)]];
            
indicatorEnd = findCoordinateIntersections(outerProfile,0,shortRibTop[0]-indicatorLength)[1];            
longRibProfile = [ [outerRadius,ribStart], LINE(), [outerRadius+ribHeight,ribStart+ribHeight], POLAR(1,90), POLAR(5,-topAngle), [topDiameter/2+ribHeight,height-topDiameterToTip+ribHeight], POLAR(topDiameterToTip/2,180-topAngle), POLAR(indicatorLength/3,0), indicatorEnd+[0,ribHeight], LINE(), indicatorEnd-[ribHeight,0] ];

module smooth() {            
    rotate_extrude() {
        difference() {
            polygon(outerProfile);
            translate([0,0,-nudge]) polygon(Bezier(profile(wallThickness)));
        }
    }
}

module shortRib() {
    rotate([90,0,0]) linear_extrude(height=ribWidth, center=true) polygon(Bezier(shortRibProfile));
}

module longRib() {
    rotate([90,0,0])
    linear_extrude(height=ribWidth, center=true) polygon(Bezier(longRibProfile));
}

module insert() {
    d = stemDiameter+tightTolerance*2;
    translate([0,0,innerInset]) 
    linear_extrude(height=innerHeight-innerInset) difference() {
        circle(d=d+2*wallThickness);
        circle(d=d);
    }
    y = slitInStem-2*tightTolerance;
    translate([-d/2,-y/2,innerHeight-innerSlitHeight]) cube([d,y,innerSlitHeight]);
}

module main() {
    smooth();
    for (i=[1:numberOfRibs-1]) rotate([0,0,360/numberOfRibs*i]) shortRib();
    longRib();
    insert();
}

if (trimForNoSupport) {
    difference() {
        main();
        translate([-50,-50,-nudge]) cube([100,100,innerInset]);
    }
}
else {
    main();
}
//shortRib();