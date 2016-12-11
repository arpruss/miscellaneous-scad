
module nerfRail(positive=false,length=35,tolerance=0.25) {
    outerWidth = 18.25;
    outerThickness = 2.87;
    valleyDepth = 1.43;
    shoulderWidth = 5.41;
    nubDistanceFromFront = 15;
    nubSize=1.81;
    nubThickness=0.8;
    overhang = 2.94;
    tolerance = 0.25;
    outerDepth = 3.56;
    nudge = 0.01;
        
    // positive tolerance makes it larger
    module positiveRailProfile(tolerance=0) {
    points=[[-outerWidth/2-tolerance+overhang,0],
        [-outerWidth/2-tolerance+overhang,outerDepth-tolerance],
        [-outerWidth/2-tolerance,outerDepth-tolerance],
        [-outerWidth/2-tolerance,outerDepth+outerThickness+tolerance],
        [-outerWidth/2+shoulderWidth+tolerance,outerDepth+outerThickness+tolerance],
        [-outerWidth/2+shoulderWidth+tolerance+valleyDepth,
        outerDepth+outerThickness+tolerance-valleyDepth],
        [nudge,
        outerDepth+outerThickness+tolerance-valleyDepth],
        [nudge,0]    
        ];

        union() {
            polygon(points=points);
            scale([-1,1,1]) polygon(points=points);
        }
    }

    module negativeRailProfile(tolerance=0.25) {
        translate([0,-outerDepth/2])
        render(convexity=3) difference() {
            translate([-outerWidth/2-outerDepth/2,outerDepth/2]) square([outerWidth+outerDepth,overhang+outerDepth]);
            positiveRailProfile(tolerance=tolerance);
        }
        
        
    }
        
    if (positive) {
        linear_extrude(height=length)
        positiveRailProfile(tolerance=-tolerance);
    }
    else {
        linear_extrude(height=length)
        negativeRailProfile(tolerance=tolerance);
        translate([0,(outerDepth+outerThickness+tolerance-valleyDepth)-outerDepth/2+nudge,length-nubDistanceFromFront])
        rotate([90,0,0])
        linear_extrude(height=nubThickness,scale=0.5)
        square(nubSize,center=true);
    }
  
}

nerfRail();