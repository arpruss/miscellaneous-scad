//<params>
left = true;
// oem is 35.5
tabWidth = 39.5;
tabThickness = 8.4;
vaneThickness = 4.45;
vaneTolerance = 0.2;
extraBehindVane = 3;
extraInFrontOfVane = 1.5;
vaneSnapSize = 1.1;
vaneDepth = 19.4;
maxFrontOfVaneToGear = 26.16;
minFrontOfVaneToGear = 23.9;
axleFromFrontOfVane = 6;
gearTolerance = 0.2;
// 0=left, 0.5=center, 1=right (assuming left=true; otherwise, mirrored)
toothPositioning = 0;
toothSpacing = 5;
numberOfTeeth = 5; 
topToothHeight = 6;
bottomToothHeight = 11;
blockerLength = 1;
blockerChamfer = 3;
outerChamfer = 4;
//</params>

module dummy() {}

nudge = 0.01;
vaneThickness1 = vaneThickness + 2 * vaneTolerance;
vaneDepth1 = vaneDepth + 2 * vaneTolerance;
$fn = 128;
toothEndAngle = atan2(bottomToothHeight,(minFrontOfVaneToGear-axleFromFrontOfVane));
toothStartAngle = -atan2(topToothHeight,(minFrontOfVaneToGear-axleFromFrontOfVane));

// 0,0 = front of vane, centered

module outerChamfer() {
    d = outerChamfer;
    x = tabThickness/2+extraInFrontOfVane;
    rotate([90,0,0])
    linear_extrude(center=true,height=tabThickness) polygon([[-100,0],[x-d,0],[x,d],[x,tabWidth-d],[x-d,tabWidth],[-100,tabWidth]]);
}

module outerProfile() {
    intersection() {
        outerChamfer();
        linear_extrude(height=tabWidth)
            translate([-vaneDepth1,0])
            hull() {
                translate([-extraBehindVane,-tabThickness/2]) square([1,tabThickness]);
                translate([vaneDepth1+extraInFrontOfVane,0]) circle(d=tabThickness);
            }
    }
}

function doubleProfile(polyHalf) = 
    let(n=len(polyHalf))
    concat(polyHalf, [for (i=[0:n-1]) 
        [polyHalf[n-1-i][0],-polyHalf[n-1-i][1]]]);
    
module toothProfile() {
    short = minFrontOfVaneToGear;
    long = maxFrontOfVaneToGear;
    teethSize = toothSpacing*numberOfTeeth;
    spine = [ [ axleFromFrontOfVane, teethSize ], [ axleFromFrontOfVane, 0 ] ];
    n = 2*numberOfTeeth+1;
    teeth = [ for(i=[0:n-1]) 
         [ i % 2 == 0 ? short : long, teethSize*i/(n-1) ]  ];
    translate([0,toothPositioning*(tabWidth-teethSize)])
    polygon(concat(teeth,spine)); 
}

module innerProfile() {
    bottom = [
        [ -100,-vaneThickness1/2+vaneSnapSize ], 
        [ -vaneSnapSize*.7, -vaneThickness1/2+vaneSnapSize ],
        [ 0, -vaneThickness1/2 ],
        [ vaneDepth1, -vaneThickness1/2 ],
    ];
    translate([-vaneDepth1,0]) polygon(doubleProfile(bottom));
}

module blocker() {
    linear_extrude(height=blockerLength) 
    polygon( [[  nudge, vaneThickness1/2-blockerChamfer ],
             [  nudge, vaneThickness1/2+nudge ],
             [ -blockerChamfer, vaneThickness1/2+nudge ]] );
}

module main() {
    difference() {
        union() {
            outerProfile();
            translate([-axleFromFrontOfVane,0]) 
            rotate([0,0,180+toothStartAngle])
            rotate_extrude(angle=toothEndAngle-toothStartAngle)  translate([nudge-axleFromFrontOfVane,0]) toothProfile();
        }
        translate([0,0,-nudge]) linear_extrude(height=tabWidth+2*nudge) innerProfile();
    }
    blocker();
    translate([0,0,tabWidth-blockerLength]) blocker();
}


if (left) 
    main();
else
    mirror([1,0,0]) main();
}
