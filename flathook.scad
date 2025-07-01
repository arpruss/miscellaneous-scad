use <ribbon.scad>;
use <bezier.scad>;
use <pointHull.scad>;

//<params>
topWidth = 14;
bottomWidth = 18;
thickness = 6;
hookedPartHeight = 60;
hookOpeningAngle = 5;
hookOpeningDistance = 53;
straightPartHeight = 20;
holeSpacing = 13;
holeDiameter = 4.75;
screwHeadInsetDepth = 3.5;
screwHeadInsetDiameter = 9;
numberOfHoles = 2;
hookBottomHorizontalOffset = -2;
hookSideRoundednessParameter = .6;
hookBottomFrontRoundessParameter = .45;
hookBottomRearRoundessParameter = .5;
//</params>

b = [ [0,straightPartHeight],LINE(),
      [0,0], POLAR(hookedPartHeight*hookSideRoundednessParameter,-90),
      POLAR(hookOpeningDistance*hookBottomRearRoundessParameter,180),
      [hookOpeningDistance/2+hookBottomHorizontalOffset,-hookedPartHeight],
      POLAR(hookOpeningDistance*hookBottomFrontRoundessParameter,0),
      POLAR(hookedPartHeight*hookSideRoundednessParameter,-90-hookOpeningAngle),
      [hookOpeningDistance,0] ];

module hook() {
    difference() {
    ribbon(Bezier(b,precision=.01)) cylinder(d=thickness,max(topWidth,bottomWidth),$fn=32,center=true);
        for(i=[0:numberOfHoles-1]) translate([0,straightPartHeight-topWidth/2-i*holeSpacing,0]) rotate([0,90,0]) {
            cylinder(d=holeDiameter,h=thickness*2,$fn=32,center=true);
            translate([0,0,-thickness/2+screwHeadInsetDepth]) cylinder(d=screwHeadInsetDiameter,h=screwHeadInsetDepth+1,$fn=32);
        }
    }
}

module main() {
    if (topWidth==bottomWidth) hook();
    else {
        h = hookedPartHeight+straightPartHeight+thickness;
        slantAngle = 2*atan((topWidth-bottomWidth)/h/2);
        rotate([slantAngle/2,0,0]) 
        intersection() {
            translate([thickness/2,hookedPartHeight+thickness/2,0]) hook();
            pointHull(
                [[-100,0,-bottomWidth/2],
                 [-100,0,bottomWidth/2],
                 [100+hookOpeningDistance,0,bottomWidth/2],
                 [100+hookOpeningDistance,0,-bottomWidth/2],
                [-100,h,-topWidth/2],
                 [-100,h,topWidth/2],
                 [100+hookOpeningDistance,h,topWidth/2],
                 [100+hookOpeningDistance,h,-topWidth/2]]
            );
        }
    }
}

main();