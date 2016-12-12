
module nerfRail(positive=false,length=40,tolerance=0.25) {
    outerWidth = 18.25;
    outerThickness = 2.87;
    valleyDepth = 1.43;
    shoulderWidth = 5.41;
    nubDistanceFromFront = 15;
    nubSize=1.81;
    nubThickness=.9;
    overhang = 2.94;
    outerDepth = 3.56;
    nudge = 0.01;
        
    // positive tolerance makes it larger
    module positiveRailProfile(tolerance=0) {
        echo(tolerance);
    points=[[-outerWidth/2-tolerance+overhang,0],
        [-outerWidth/2-tolerance+overhang,outerDepth-tolerance],
        [-outerWidth/2-tolerance,outerDepth-tolerance],
        [-outerWidth/2-tolerance,outerDepth+outerThickness+tolerance],
        [-outerWidth/2+shoulderWidth+tolerance,outerDepth+outerThickness+tolerance],
        [-outerWidth/2+shoulderWidth+tolerance+valleyDepth,
        outerDepth+outerThickness+tolerance-valleyDepth+tolerance],
        [nudge,
        outerDepth+outerThickness+tolerance-valleyDepth+tolerance],
        [nudge,0]    
        ];

        union() {
            polygon(points=points);
            scale([-1,1,1]) polygon(points=points);
        }
    }

    module negativeRailProfile(tolerance=0.25) {
        translate([0,-outerDepth/2+tolerance])
        render(convexity=3) difference() {
            translate([-tolerance-outerWidth/2-outerDepth/2,outerDepth/2-tolerance]) square([outerWidth+outerDepth+2*tolerance,overhang+outerDepth+2*tolerance]);
            positiveRailProfile(tolerance=tolerance);
        }
        
        
    }
    
    module nub() {
        hull() {
        translate([-outerWidth/2+shoulderWidth+tolerance+valleyDepth+nubSize/2,0,0])
        rotate([90,0,0])
        linear_extrude(height=nubThickness,scale=0.25)
        square(nubSize,center=true);
        translate(-[-outerWidth/2+shoulderWidth+tolerance+valleyDepth+nubSize/2,0,0])
        rotate([90,0,0])
        linear_extrude(height=nubThickness,scale=0.25)
        square(nubSize,center=true);
        }
    }
        
    if (positive) {
        linear_extrude(height=length)
        positiveRailProfile(tolerance=-tolerance);
    }
    else {
        linear_extrude(height=length)
        negativeRailProfile(tolerance=tolerance);
        translate([0,(outerDepth+outerThickness+3*tolerance-valleyDepth)-outerDepth/2+nudge,length-nubDistanceFromFront+tolerance])
        nub();
    }
  
}

nerfRail(tolerance=0.63);