endToEndLength = 26;
wireDiameter = 2.25;
topNubLength = 3;
topNubThickness = 2.3;
bottomNubThickness = 3;
bottomNubLength = 4;
endDiameter = 22.4;
endThickness = 2;
hubThickness = 3;
hubWall = 1;
insideDiameter = 8;
wirePressFitTolerance = 0.08;
stemPressFitTolerance = 0.04;
threadHoleDiameter = 2.65;
includeBottomEnd = 1; // [0:No,1:Yes]
includeTopEnd = 1; // [0:No,1:Yes]

module dummy() {}

nudge = 0.001;
$fn = 64;
insideLength = endToEndLength-2*endThickness;

module end(withStem) {
    difference() {
        id = insideDiameter+stemPressFitTolerance*2;
        union() {
            cylinder(d=endDiameter,h=endThickness);
            translate([0,0,endThickness-nudge])
            cylinder(d1=id+2*hubWall+hubThickness,d2=id+2*hubWall,h=hubThickness+nudge);
            if (withStem) {
                translate([0,0,endThickness]) cylinder(d=insideDiameter,h=insideLength);
            }
        }
        union() {            
            if (!withStem) {
                translate([0,0,endThickness]) cylinder(d=insideDiameter+2*stemPressFitTolerance,h=insideLength);
            }
            else {
                translate([(id+2*hubWall+hubThickness+endDiameter)/4,0,-nudge]) cylinder(d=threadHoleDiameter,h=endThickness+hubThickness+2*nudge);
            }
            translate([0,0,-nudge])
            cylinder(d=wireDiameter+(withStem?2*wirePressFitTolerance:0),h=endToEndLength+2*nudge);
        }
    }
}

if (includeTopEnd)
    end(true);
if (includeBottomEnd)
    translate([endDiameter+5,0,0]) end(false);
