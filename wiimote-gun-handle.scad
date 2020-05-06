use <Bezier.scad>;
use <pointhull.scad>;

//<params>
includeGrip = true;
tolerance = 0.18;
wallThicknesss = 2.5;
tabSize = 3.5;
gripLength = 39;
gripWidth = 17.53;
lip = 3;
// the following only apply if you do include the grip
gripHeight = 80;
gripAngle = 20;
gripBevel = 4;

// the following only apply if you don't include the grip
extrawallThicknesss = 3;
screwHoleDiameter = 4;
screwHoleInsetDepth = 3;
screwHoleInsetDiameter = 9;
//</params>

module dummy() {}

$fn = 36;

nudge = 0.01;

wiiY = 30.8;
size_xsect_0 = [36.240508333,29.876988125];
size_xsect_1 = [size_xsect_0[0],wiiY];
// paths for xsect_1

points_xsect_1_1 = [ [-6.340977708,14.938494063],[-10.041222909,13.991003059],[-11.542611892,13.335288548],[-12.832843571,12.588143262],[-14.843830332,10.909206052],[-16.202173828,9.133482813],[-17.035864698,7.440264924],[-17.472893577,6.008843770],[-17.668927917,4.648557188],[-18.120254167,-5.506045312],[-18.120254167,-13.404016562],[-17.859895898,-14.081701709],[-17.287107708,-14.560520234],[-16.453961250,-14.938494063],[-0.157929792,-14.938494063],[16.454040625,-14.938494063],[17.287147396,-14.560520234],[17.859908301,-14.081701709],[18.120254167,-13.404016562],[18.120254167,-5.506045312],[17.668954375,4.648557188],[17.472919622,6.008843770],[17.035889761,7.440264924],[16.202196979,9.133482813],[14.843850330,10.909206052],[12.832858867,12.588143262],[11.542624159,13.335288548],[8.312682448,14.532875371],[6.340977708,14.938494063],[-6.340977708,14.938494063] ];

module xsect(delta=0) {
 render(convexity=4) {
    rotate(180)
    offset(r=delta)
    scale([1,wiiY/size_xsect_0[1]])
    polygon(points=points_xsect_1_1);
 }
}

module outline() {
    w  = size_xsect_1[0]+2*tolerance-2*tabSize;
    difference() {
        union() {
            xsect(delta=tolerance+wallThicknesss);
            w1 = gripWidth;
            if (!includeGrip) translate([-w1/2,-size_xsect_1[1]/2-extrawallThicknesss-tolerance-wallThicknesss]) square([w1,extrawallThicknesss+wallThicknesss+nudge]);
        }
        xsect(delta=tolerance);
        translate([-w/2,0]) square([w,size_xsect_1[1]+tolerance+wallThicknesss]);
    }
}

module screwHoles() {
    for (i=[0.25,0.75]) 
    translate([0,-size_xsect_1[1]/2-tolerance,i*gripLength])
    rotate([-90,0,0]) {
        translate([0,0,-100+nudge]) cylinder(d=screwHoleDiameter,h=100);
        translate([0,0,-screwHoleInsetDepth+2*nudge]) cylinder(d1=screwHoleDiameter,d2=screwHoleInsetDiameter,h=screwHoleInsetDepth);
    }
}

module gripless() {
    difference() {
        linear_extrude(height=gripLength)
        outline();
        screwHoles();
    }
}

gripOffset = gripHeight*tan(gripAngle);    

gripOutlineSideView = let(dx = sin(gripAngle) * gripBevel, 
    dy = cos(gripAngle) * gripBevel, h = size_xsect_1[1]+2*wallThicknesss+2*tolerance) Bezier(
    [[h*tan(gripAngle),h],LINE(),LINE(),[h*tan(gripAngle)+gripLength,h],LINE(),LINE(),[gripLength-gripOffset+dx,-gripHeight+dy],OFFSET([-dx,-dy]*0.5),OFFSET([gripBevel*0.5,0]),[gripLength-gripOffset-gripBevel,-gripHeight],LINE(),LINE(),[-gripOffset+gripBevel,-gripHeight],LINE(),LINE(),[-gripOffset+dx,-gripHeight+dy]]);

gripOutlineBottomView = Bezier([[-nudge,gripWidth/2],LINE(),LINE(),[-nudge,gripBevel],LINE(),LINE(),[gripBevel,0],LINE(),LINE(),[gripLength-gripBevel,0],SMOOTH_ABS(gripBevel*0.5),SMOOTH_ABS(gripBevel*0.5),[gripLength,gripBevel],LINE(),LINE(),[gripLength,gripWidth/2],REPEAT_MIRRORED([0,1])]);

function atXY(points2D,x,y) = [for (p=points2D) [p[0]+x,y,p[1]]];

module grip() {
    translate([0,0,-nudge])
    rotate([0,-90,0])
    rotate([0,0,gripAngle])
    intersection() {
        union() {
            pointHull(concat(atXY(gripOutlineBottomView,wallThicknesss/2*tan(gripAngle),wallThicknesss/2),atXY(gripOutlineBottomView,-gripOffset,-gripHeight)));
           translate([0,0,gripWidth/2]) rotate([0,90,0]) translate([0,size_xsect_1[1]/2-nudge+tolerance+wallThicknesss,0]) linear_extrude(height=gripLength+tan(gripAngle)*(2*tolerance+2*wallThicknesss+size_xsect_1[1])) outline();
        }
        linear_extrude(height=3*gripWidth+size_xsect_1[1]*3,center=true) polygon(gripOutlineSideView);
    }
}

module grippy() {
    grip();
}

if (!includeGrip) 
    gripless();
else 
    grip();

