use <tubemesh.scad>;

angles = [12,15,18];
labels = ["A", "B", "C"];
angleNumber = 0;
currentAngle = 12; 
radius = 105;
boardDiameter = 450;
trimSize = 100;
knobSize = 20;
hexSize = 11.11; // across flats
tolerance = 0.1;
hexMinimumDistance = 10;
hexThickness = 5.6;
boltDiameter = 6.35;
boltTolerance = 0.2;
jointDiameter = 10;
jointThickness = 5;
jointHorizontalTolerance = 1;
jointVerticalTolerance = 2;
alignmentHoles = 0; //[0:no,1:yes]

module dummy() {}

hexDiameter = (hexSize+tolerance*2)/cos(180/6);

function getOffset(angle) = let(boardRadius = boardDiameter / 2,
    y0 = radius * cos(angle),
    x0 = radius * sin(angle),
    //line: -(x-x0) * x0/y0 =(y-y0)
    //-(boardRadius-x0) * x0/y0 = offset - y0
    offset = y0 - (boardRadius-x0) * x0/y0) offset;
function getContactHeight(angle) = radius-radius*cos(angle);
function getContactRadius(angle) = radius*sin(angle);
function getWidth(offset) = 2*sqrt(radius*radius - offset*offset);
function getHeight(offset) = radius-offset;
echo(15,getHeight(getOffset(12)),getWidth(getOffset(12)),getContactHeight(12));
echo(17,getHeight(getOffset(15)),getWidth(getOffset(15)),getContactHeight(15));
echo(20,getHeight(getOffset(18)),getWidth(getOffset(18)),getContactHeight(18));

currentAngle = angles[angleNumber];
currentOffset = getOffset(currentAngle);
heightDifference = getOffset(angles[0])-getOffset(angles[len(angles)-1]);
echo("heightDifference", heightDifference);

nudge = 0.01;
$fn = 100;

function letterSum(n,soFar="") = 
    n == 0 ? str(labels[n],soFar) :
    letterSum(n-1,soFar=str("+",labels[n],soFar));
    
difference() {
    if (angleNumber == 0) {
        difference() {
            intersection() {
                translate([0,0,-currentOffset]) sphere(r=radius,$fn=128);
                translate([-radius-1,-radius-1,0]) cube([2*radius+2,2*radius+2,radius+1]);
                cylinder(d=trimSize+knobSize,h=radius);
                echo("Thickness", getHeight(currentOffset));
                echo("Spare size", trimSize-2*getContactRadius(currentAngle));
            }
            if (getContactRadius(currentAngle) > trimSize/2) {
                echo("trimSize too small!");
            }
            h0 = hexMinimumDistance + hexThickness + tolerance + 
        boltDiameter + heightDifference;
            translate([0,0,-nudge]) cylinder(d=boltDiameter+2*boltTolerance,h=h0);
            translate([0,0,hexMinimumDistance]) cylinder(d=hexDiameter,h=hexThickness,$fn=6);
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
            translate([0,0,-nudge]) cylinder(d=boltDiameter+2*tolerance,h=radius*2);
        }
    }
    if (alignmentHoles) { 
        for (angle=[45,45+180]) rotate([0,0,angle]) translate([trimSize/2*0.75,0,-nudge]) cylinder(d=jointDiameter+2*jointHorizontalTolerance,h=jointThickness+jointVerticalTolerance);
        }
        for (angle=[0:60:360-45]) rotate([0,0,angle]) translate([trimSize/2+knobSize/2,0,-1]) cylinder(d=knobSize,h=radius+10);
    translate([0,10,-nudge])
    mirror([1,0,0])
    linear_extrude(height=2)
        text(labels[angleNumber],halign="center",size=20,font="Arial:style=Bold");
    translate([0,-15,-nudge])
    mirror([1,0,0])
    linear_extrude(height=2)
        text(str(currentAngle, "\u00B0=", letterSum(angleNumber)),halign="center",size=10,font="Arial:style=Bold");
    }
