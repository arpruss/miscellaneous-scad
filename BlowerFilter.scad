use <Bezier.scad>;
use <ribbon.scad>;

//<params>
topTolerance = 0.2;
bottomTolerance = 0.2;
topDiameter = 15.5;
bottomDiameter = 55;
lip = 3;
bottomHeight = 7;
topWall = 1.5;
topNeck = 6;
grilleWidth = 1.2;
grilleHeight = 1.5;
bottomWall = 1.2;
extraHeightRatio = 1.1;
mode = 2; //[0:all, 1:bottom, 2:top]
//</params>

$fn = 128;

delta = bottomDiameter*.1;

height = (bottomDiameter/2-topDiameter/2+delta+topNeck)*extraHeightRatio;

profile = [
    [bottomDiameter/2-lip,0],
    LINE(),LINE(),
    [bottomDiameter/2,0],
    LINE(),LINE(),
    [bottomDiameter/2,2],
    POLAR(delta,90),
    POLAR(delta,-90),
    [topDiameter/2+topWall/2+topTolerance,height-topNeck],
    LINE(),LINE(),
    [topDiameter/2+topWall/2+topTolerance,height]
    ];
    
module top() {
    translate([0,0,topWall/2]) 
    rotate_extrude() ribbon(Bezier(profile),topWall);
    base();
}

bottomDiameter2 = bottomDiameter+2*bottomTolerance+topWall;

module base(circles=true) {
    linear_extrude(height=grilleHeight) {
        if (circles)
        for(d=[10:13:bottomDiameter-grilleWidth/2]) {
            difference() {
                circle(d=d+grilleWidth,$fn=6);
                circle(d=d-grilleWidth,$fn=6);
            }
        }
        
        for(angle=[0:120:240]) rotate(angle) 
        square([bottomDiameter-lip+grilleWidth,grilleWidth],center=true);
    }
}

module bottom() {
    difference() {
        cylinder(h=bottomHeight, d=bottomDiameter2+bottomWall*2);
        cylinder(h=bottomHeight*3,d=bottomDiameter2,center=true);
    }
    linear_extrude(height=grilleHeight+0.5) {
        union() {
            difference() {
                circle(d=bottomDiameter2+bottomWall*2);
                circle(d=bottomDiameter-2*lip);
            }
        }
    }
    base(circles=true);
    
}

if (mode != 1) top();
if (mode != 2) translate([bottomDiameter+10,0,0]) bottom();