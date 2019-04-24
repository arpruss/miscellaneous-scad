angles = [12,15,17];
labels = ["A", "B", "C"];
angleNumber = 0;
sphereRadius = 105;
boardDiameter = 450;
trimSize = 100;
knobSize = 20;
// measured across flats; 11.11 for 1/4" and 12.7 for 5/16
hexNutSize = 12.7; 
// 5.6 for 1/4"; 6.75 for 5/16
hexNutThickness = 6.75;
// minimum amount of plastic between nut and wooden board
hexNutMinimumDistance = 10;
tolerance = 0.1;
// 6.35 for 1/4"; 8.23 for 5/16
boltDiameter = 8.23;
boltTolerance = 0.2;
jointDiameter = 10;
jointThickness = 5;
jointHorizontalTolerance = 1;
jointVerticalTolerance = 2;
angleLabel = 1; //[0:no,1:yes]
alignmentHoles = 0; //[0:no,1:yes]

module dummy() {}

hexNutSizeDiameter = (hexNutSize+tolerance*2)/cos(180/6);

function getOffset(angle) = let(boardRadius = boardDiameter / 2,
    y0 = sphereRadius * cos(angle),
    x0 = sphereRadius * sin(angle),
    //line: -(x-x0) * x0/y0 =(y-y0)
    //-(boardRadius-x0) * x0/y0 = offset - y0
    offset = y0 - (boardRadius-x0) * x0/y0) offset;
function getContactHeight(angle) = sphereRadius-sphereRadius*cos(angle);
function getContactRadius(angle) = sphereRadius*sin(angle);
function getWidth(offset) = 2*sqrt(sphereRadius*sphereRadius - offset*offset);
function getHeight(offset) = sphereRadius-offset;
/*echo(15,getHeight(getOffset(12)),getWidth(getOffset(12)),getContactHeight(12));
echo(17,getHeight(getOffset(15)),getWidth(getOffset(15)),getContactHeight(15));
echo(20,getHeight(getOffset(18)),getWidth(getOffset(18)),getContactHeight(18));*/

currentAngle = angles[angleNumber];
currentOffset = getOffset(currentAngle);
heightDifference = getOffset(angles[0])-getOffset(angles[len(angles)-1]);
echo("heightDifference", heightDifference);

nudge = 0.01;
$fn = 100;

function letterSum(n,soFar="") = 
    n == 0 ? str(labels[n],soFar) :
    letterSum(n-1,soFar=str("+",labels[n],soFar));
    
rotate([angleNumber==0 || alignmentHoles ? 0 : 180,0,0])
difference() {
    if (angleNumber == 0) {
        difference() {
                intersection() {
                translate([0,0,-currentOffset]) sphere(r=sphereRadius,$fn=128);
                translate([-sphereRadius-1,-sphereRadius-1,0]) cube([2*sphereRadius+2,2*sphereRadius+2,sphereRadius+1]);
                cylinder(d=trimSize+knobSize,h=sphereRadius);
                echo("Thickness", getHeight(currentOffset));
                echo("Spare size", trimSize-2*getContactRadius(currentAngle));
            }
            if (getContactRadius(currentAngle) > trimSize/2) {
                echo("trimSize too small!");
            }
            h0 = hexNutMinimumDistance + hexNutThickness + tolerance + 
        0.5*boltDiameter + heightDifference;
            echo("Bolt should stick out ",h0,"mm from board");
            translate([0,0,-nudge]) cylinder(d=boltDiameter+2*boltTolerance,h=h0);
            bhe = (sphereRadius-currentOffset)-h0;
            echo("Bolt hole ends ",bhe,"mm before end of plastic");
            if (bhe<=4.8)
                echo("WARNING: That not enough!");
            translate([0,0,hexNutMinimumDistance]) cylinder(d=hexNutSizeDiameter,h=hexNutThickness,$fn=6);
            echo("Insert nut just before z=",hexNutMinimumDistance+hexNutThickness);
        }
    }
        
    else {
        baseOffset = getOffset(angles[angleNumber-1]);
        h = baseOffset-currentOffset;
        if (alignmentHoles)
        for (angle=[45,45+180]) rotate([0,0,angle]) translate([trimSize/2*0.75,0,h-nudge]) cylinder(d=jointDiameter,h=jointThickness);
        difference() {
            echo("Thickness", h);
            cylinder(d=min(getWidth(getOffset(angles[0])),trimSize+knobSize),h=h);
            translate([0,0,-nudge]) cylinder(d=boltDiameter+2*tolerance,h=sphereRadius*2);
        }
    }
    if (alignmentHoles) { 
        for (angle=[45,45+180]) rotate([0,0,angle]) translate([trimSize/2*0.75,0,-nudge]) cylinder(d=jointDiameter+2*jointHorizontalTolerance,h=jointThickness+jointVerticalTolerance);
        }
        for (angle=[0:60:360-45]) rotate([0,0,angle]) translate([trimSize/2+knobSize/2,0,-1]) cylinder(d=knobSize,h=sphereRadius+10);
    translate([0,10,-nudge])
    mirror([1,0,0])
    linear_extrude(height=2)
        text(labels[angleNumber],halign="center",size=20,font="Arial:style=Bold");
    if(angleLabel)
    translate([0,-15,-nudge])
    mirror([1,0,0])
    linear_extrude(height=2)
        text(str(currentAngle, "\u00B0=", letterSum(angleNumber)),halign="center",size=10,font="Arial:style=Bold");
    }
