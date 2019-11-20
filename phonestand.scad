use <Bezier.scad>;
bottomSpacing = 10;
minWidth = 7;
lip = 12;
depth = 72;
height = 96;
thickness = 5;
tolerance = 0.2;
supportHeight = 35;
supportHeight2 = 20;
supportSpacing = 48;

nudge = 0.001;

module side() {
    difference() {
    polygon(Bezier( 
        [[minWidth,minWidth],POLAR(minWidth/2,180),POLAR(minWidth/2,-90),[0,minWidth+lip/2],POLAR(minWidth/2,90), POLAR(minWidth/2,0), [0,minWidth+lip],POLAR(minWidth,180),POLAR(minWidth/2,90),[-minWidth,minWidth],SYMMETRIC(),POLAR(minWidth/2,180),[0,0],LINE(),LINE(),[depth,0],POLAR(minWidth/2,0),POLAR(minWidth/2,-90),[depth+minWidth,minWidth],LINE(),LINE(),[depth+minWidth,minWidth+height],POLAR(minWidth/3,90),POLAR(minWidth/3,0),[depth+minWidth/2,minWidth+height+minWidth/2],POLAR(minWidth/3,180),POLAR(minWidth/3,90),[depth,minWidth+height],POLAR(height/3,-90),POLAR(height/3,0),[bottomSpacing,minWidth]
    
    ]));
        translate([depth-thickness-2*tolerance,-nudge]) square([thickness+2*tolerance,supportHeight/2+tolerance]);
        translate([depth*0.6,-nudge]) square([thickness+2*tolerance,supportHeight2/2+tolerance]);
    }
}

module support(supportHeight) {
    w = minWidth*2+supportSpacing+thickness*2+4*tolerance;
    difference() {
        square([w,supportHeight]);
        for (i=[0,1])
        translate([minWidth+i*(supportSpacing+thickness+2*tolerance),supportHeight/2+nudge-tolerance]) square([thickness+2*tolerance,supportHeight]);
        translate([w/2,supportHeight/2]) circle(d=supportHeight-2*minWidth,$fn=32);
    }
}

linear_extrude(height=thickness) 
{
    translate([0,supportHeight+10]) side();
    support(supportHeight);
    translate([0,-supportHeight2-10]) support(supportHeight2);
    translate([depth+max(depth,supportSpacing)+2*minWidth+10,0])
    mirror([1,0]) translate([0,10]) side();
}