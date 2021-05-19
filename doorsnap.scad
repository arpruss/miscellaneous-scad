use <bezier.scad>;

// NB: GLUE, NOT SCREW!

//<params>
length = 140;
width = 32;
snapHeight = 14;
snapOuterAngle = 50;
snapInnerAngle = 18;
stickout = 18;
trimOff = 1.5;
thickness = 2.5;
edgeHeight = 15;
edgeOffsetFromEnd = 64.4;
//</params>

module dummy(){}

nudge = 0.001;

module profile() {
    intersection() {
        polygon( 
            [ [0,thickness], [length,thickness], [length,0],
              [length-tan(snapOuterAngle)*snapHeight,-snapHeight],
              [length-tan(snapOuterAngle)*snapHeight-tan(snapInnerAngle)*snapHeight,0], [0,0]]);
        translate([0,-snapHeight+trimOff]) square([length,snapHeight+thickness-trimOff]);
    }
    translate([length,0])
    rotate(90-snapOuterAngle)
    square([stickout,thickness]);
    translate([edgeOffsetFromEnd,nudge]) polygon(Bezier([[-1,0],POLAR(thickness/2,0),POLAR(thickness/2,90),[0,-thickness],LINE(),LINE(),[0,-edgeHeight],LINE(),LINE(),[thickness,-edgeHeight],LINE(),LINE(),[thickness,-thickness],POLAR(thickness/2,90),POLAR(thickness/2,180),[thickness*2,0]]));
}

linear_extrude(height=width) profile();

