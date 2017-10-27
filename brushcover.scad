brushHandleThickness = 4.72;
brushHandleWidth = 13.74;
bristleWidth=10.61;
bristleLength=14.28;
coverBottomLength=54;
coverTopLength=47;
wall = 1.5;
tolerance = 0.3;

module dummy() {}

nudge = 0.01;

totalThickness = bristleLength+brushHandleThickness;
adjWall = wall + (brushHandleWidth-bristleWidth)/2;

module cover() {
    render(convexity=2)
    intersection() {
        union() {
            difference() {
                union() {
                    cube([coverBottomLength,brushHandleWidth+2*tolerance+2*wall,wall]);
                    cube([coverTopLength,adjWall,wall+totalThickness]);
                    translate([0,brushHandleWidth+2*tolerance+2*wall-adjWall,0]) cube([coverTopLength,adjWall,totalThickness+wall]);
                    cube([coverBottomLength,adjWall,wall+brushHandleThickness]);
                    translate([0,brushHandleWidth+2*tolerance+2*wall-adjWall,0]) cube([coverBottomLength,adjWall,wall+brushHandleThickness]);
                cube([wall,brushHandleWidth+2*tolerance+2*wall,totalThickness+2*wall]);
                    translate([0,0,wall+totalThickness-nudge]) cube([coverTopLength,brushHandleWidth+2*tolerance+2*wall,wall]);
                }
                translate([wall,wall,wall]) cube([coverBottomLength,brushHandleWidth+2*tolerance,brushHandleThickness+2*tolerance]);
                translate([-nudge,-nudge,wall+brushHandleThickness+2*tolerance+wall]) cube([coverTopLength+nudge,adjWall-wall+nudge,wall+totalThickness]);
                translate([-nudge,brushHandleWidth+2*tolerance+2*wall-(adjWall-wall),wall+brushHandleThickness+2*tolerance+wall]) cube([coverTopLength+nudge,adjWall-wall+nudge,wall+totalThickness]);
            }
        }
        cube([coverBottomLength,brushHandleWidth+2*tolerance+2*wall,totalThickness+2*wall]);

    }
}

rotate([0,-90,0])
cover();