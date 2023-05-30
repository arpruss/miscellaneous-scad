use <Bezier.scad>;

//<params>
demo = 0; // [0:no,1:yes]
count = 1;
spacing = 20;
hullCrowns = 1; // [0:no,1:yes]
includeCrown = 0; // [0:no,1:yes]
includePlunger = 1; // [0:no,1:yes]
includeWell = 0; // [0:no,1:yes]

buttonTopDiameter = 12;
cutoutDiameter = 18;
buttonHeightPastCrown = 1.4;
buttonExtraHeight = 1.25; // make negative for dent
crownDiameter = 22;
crownSleeveHeight = 3;
crownTopHeight = 2;
plungerHeight = 9;
plungerThinning = 1.25;
plungerRadialExtra = 1;
plungerThinningAngle = 50;

verticalTolerance = 1.3;
moveTolerance = 0.3;
fitTolerance = 0.1;
tactTolerance = 0.12;
tactWidth = 6;
tactHeight = 5;
tactHeightNoButton = 3.5;
tactSlit = 2;
wellBase = 1;
legHole = 2.5;

crownOuterRatio = 0.7;
crownTensionBottom = 0.5;
crownTensionSide = 0.3;

//</params>

module dummy() {}

$fn=64;
nudge = 0.001;

cutoutDiameter1 = cutoutDiameter - 2 * fitTolerance;
plungerDiameter = buttonTopDiameter + 2 * plungerRadialExtra;
wellID = plungerDiameter + 2 * moveTolerance;
walls = (cutoutDiameter1 - wellID) / 2;
echo("walls", walls);
wellWall = walls / 2 - fitTolerance / 2;
echo("wellWall", wellWall);
wellOD = wellID + 2 * wellWall;
crownSleeveWall = walls / 2 - fitTolerance / 2;
crownSleeveID = wellOD + 2 * fitTolerance;
crownSleeveOD = crownSleeveID + 2 * crownSleeveWall;
echo("should be zero", crownSleeveOD - cutoutDiameter1);
wellDepth = wellBase + plungerHeight + tactHeight + verticalTolerance;
echo("wellDepth", wellDepth);

module well() {    
    id = wellID;
    od = wellOD;

    module holes() {
        for (s=[-1,1]) translate([s*tactWidth/2,0]) 
        for(u=[-1,1]) translate([0,u*tactWidth/2]) circle(d=legHole);
    }
    module slits() {
        for (s=[-1,1]) translate([s*tactWidth/2,0]) {
            square([tactSlit,tactWidth+2*tactTolerance],center=true);
        }
    }
    linear_extrude(height=wellBase) {
        difference() {
            circle(d=od);
            holes();
            slits();
        }
    }
    linear_extrude(height=wellBase+tactHeightNoButton-verticalTolerance) {
        difference() {
            circle(d=od);
            hull() slits();
            holes();
        }
    }
    linear_extrude(height=wellDepth) {
        difference() {
            circle(d=od);
            circle(d=id);
        }
    }
}

module plunger() {
    x = plungerDiameter / 2;
    x1 = buttonTopDiameter / 2;
    dx = plungerThinning;
    y0 = dx * tan(plungerThinningAngle) + dx;
    y1 = plungerHeight + crownTopHeight + buttonHeightPastCrown;
    y2 = y1 + buttonExtraHeight;
    profile = [ 
        [ 0, 0], LINE(), 
        LINE(), [ x - dx, 0 ], POLAR(dx, plungerThinningAngle),
        POLAR(dx, -90), [ x, y0], LINE(), 
        LINE(), [ x, plungerHeight ], LINE(),
        LINE(), [ x1, plungerHeight ], LINE(),
        LINE(), [ x1, y1 ], POLAR(buttonExtraHeight,90),
        POLAR(x1/3,0), [ 0, y2 ] ];
    rotate_extrude() polygon(Bezier(profile));
}

module spread() {
    for(i=[0:count-1]) 
        translate([0,spacing*i]) children();
}

module crowns() {
    x0 = buttonTopDiameter / 2 + moveTolerance;
    x1 = crownDiameter / 2;
    dx = crownTopHeight * crownOuterRatio;
    y1 = crownTopHeight;
    x2 = crownSleeveOD / 2;
    y2 = y1 + crownSleeveHeight;
    x3 = x2 - crownSleeveWall;
    profile = [
        [0, 0], LINE(), 
        LINE(), [x1-dx, 0], POLAR(y1 * crownTensionBottom, 50),
        POLAR(y1 * crownTensionSide, -90), [x1, y1], LINE(),
        LINE(), [0,y1] ];
//    BezierVisualize(profile);
    module top() {
        rotate_extrude() polygon(Bezier(profile));
    }
    
    module sleeve() {
        translate([0,0,y1-nudge])
        linear_extrude(height=crownSleeveHeight+nudge)
            difference() {
                circle(d=crownSleeveOD);
                circle(d=crownSleeveID);
            }
    }
    
    module hole() {
        translate([0,0,-nudge]) cylinder(d=2*x0, h=2*nudge+y1);
    }
    
    difference() {
        if (hullCrowns) {
            hull() spread() top();
        }
        else {
            spread() top();
        }
        spread() hole();
    }
    spread() sleeve();
}

if (demo) {
    %spread() well();
    translate([0,0,wellBase+tactHeight+moveTolerance]) spread() plunger();
    %translate([0,0,wellDepth+crownTopHeight]) rotate([180,0,0]) crowns();
}
else {
    if(includeWell) spread() well();
    if (includePlunger) translate([wellOD/2+plungerDiameter/2 + 5,0,0]) spread() plunger();
    if (includeCrown) translate([-wellOD/2-crownDiameter/2 - 5,0,0]) crowns();
}