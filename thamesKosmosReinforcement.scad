knobDiameter = 8;
knobHeight = 7;
pieceLength = 5;
baseDimension = 10;
tolerance = 0.25;
cutWidth = 1.75;
cutHeight = 6;
chamfer = 1.25;

module dummy() {}

nudge = 0.001;

module chamferedCylinder(d=10,r=undef,h=10,chamfer=1) {
    diameter = r==undef ? d : 2*r;
    cylinder(d=diameter,h=h-chamfer+0.001);
    translate([0,0,h-chamfer])
    cylinder(d1=diameter,d2=diameter-chamfer*2,h=chamfer);
}

module knob() {
    render(convexity=2)
    difference() {
        translate([0,0,-nudge])
            chamferedCylinder(d=knobDiameter-2*tolerance,h=knobHeight+nudge,chamfer=chamfer,$fn=24);
        translate([-cutWidth/2,-knobDiameter/2,knobHeight-cutHeight]) cube([cutWidth,knobDiameter,cutHeight+nudge]);
    }
}

translate([tolerance,tolerance-baseDimension/2,0])
cube([pieceLength*baseDimension-2*tolerance,baseDimension-2*tolerance,baseDimension]);
translate([baseDimension/2,0,baseDimension]) knob();
translate([pieceLength*baseDimension-baseDimension/2,0,baseDimension]) knob();