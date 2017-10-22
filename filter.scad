wallThickness = 1;
length = 20;
innerDiameterOfInnerCylinder = 15;
tolerance = 0.25;
hexStickout = 1;
hexHeight = 3;
hole = 3;
baseThickness = 2;
slit = 1; //[1:yes, 0:no]

module dummy() {}

nudge = 0.01;
id1 = innerDiameterOfInnerCylinder;
od1 = innerDiameterOfInnerCylinder+2*wallThickness;
id2 = od1+2*tolerance;
od2 = id2+2*wallThickness;
hexID = od2+hexStickout*2;
hexOD = hexID / cos(180/6);

module taperedCylinder(d=10,h=10,taper=2,taperRatio=2) {
    if (taper>0) {
        cylinder(d=d,h=h-taper*taperRatio+nudge);
        translate([0,0,h-taper*taperRatio]) cylinder(d1=d,d2=d-2*taper,h=taper*taperRatio);
    }
    else {
        difference(){
            cylinder(d=d,h=h);
            translate([0,0,h+taper*taperRatio+nudge]) cylinder(d1=d+2*taper,d2=d,h=-taper*taperRatio);
        }
    }
}

module hexRing() {
    cylinder(d=hexOD,h=hexHeight,$fn=6);
}

module inner() {
    render(convexity=1)
    difference() {
        union() {
            taperedCylinder(d=od1,h=length,taper=wallThickness);
            hexRing();
        }
        translate([0,0,baseThickness]) cylinder(d=id1,h=length);
        translate([0,0,-nudge])
        cylinder(d=hole,h=baseThickness+2*nudge,$fn=16);
        if (slit)
        translate([-hole/2,0,-nudge]) 
        cube([hole,od2*2,baseThickness+length+2*nudge]);
    }
}

module outer() {
    render(convexity=1)
    difference() {
        union() {
            taperedCylinder(d=od2,h=length,taper=-wallThickness);
            hexRing();
        }
        translate([0,0,baseThickness]) cylinder(d=id2,h=length);
        translate([0,0,-nudge]) 
        cylinder(d=hole,h=baseThickness+2*nudge,$fn=16);
        if (slit)
        translate([-hole/2,0,-nudge]) 
        cube([hole,od2*2,baseThickness+length+2*nudge]);
    }
}

inner();
translate([0,od2+5,0]) outer();