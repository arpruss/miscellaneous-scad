use <tubemesh.scad>;

//<params>
slotTolerance = 0.08;
slotWidth = 16.9;
slotThickness = 3.2;
slotHeight = 14;
bottomSlotExtra = 1.2;
baseDiameter = 24;
baseHeight = 10;
sphereDiameter = 40;
verticalSphereStretch = 0.8;
//</params>

module dummy() {}

nudge = 0.01;

module hemisphere(d=10,r=undef) {
    intersection() {
        sphere(d=d,r=r);
        translate([0,0,d/2+5]) cube((d==undef?2*r:d)+10,center=true);
    }
}

module mushroom() {
    cylinder(d1=baseDiameter, d2=sphereDiameter, h=baseHeight+nudge);
    translate([0,0,baseHeight]) scale([1,1,verticalSphereStretch]) hemisphere(d=sphereDiameter);
}

function rectangle(w,h) =
    [ [-w/2,-h/2], [w/2,-h/2], [w/2,h/2], [-w/2,h/2] ];

difference() {
    mushroom();
    cube([slotWidth+2*slotTolerance,slotThickness+2*slotTolerance,2*slotHeight+slotTolerance], center=true);
    translate([0,0,-nudge])
    morphExtrude(rectangle(slotWidth+2*slotTolerance+2*bottomSlotExtra,slotThickness+2*slotTolerance+2*bottomSlotExtra), rectangle(slotWidth+2*slotTolerance,slotThickness+2*slotTolerance), height=2*bottomSlotExtra);
}
