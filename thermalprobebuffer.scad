volume = 40;
aspect = 1.25;
plugRatio = 1.5;
probeLength = 20;
probeThickness = 8;
probeTolerance = 0.5;
cableHoleDiameter = 2;
plugStickout = 5;

// volume = 4 aspect pi r^3

r = pow(volume*1000/(4*aspect*PI),1/3);

$fn = 64;

h = aspect*2*r;
nudge = 0.001;

plugR1=probeThickness/2+probeTolerance;
plugR2=plugR1*plugRatio;

module buffer() {
    difference() {
        cylinder(r=r,h=h);
        translate([0,0,h/2-probeLength/2]) {
            cylinder(r=probeThickness/2+probeTolerance,h=probeLength+nudge);
            translate([0,0,probeLength]) cylinder(r1=plugR1,r2=plugR2,h=h/2-probeLength/2+nudge);
        }
    }
}

module plug() {
    difference() {
        union() {
            cylinder(h=plugStickout+nudge,r=plugR2);
            translate([0,0,plugStickout]) cylinder(r1=plugR2,r2=plugR1,h=h/2-probeLength/2);
        }
        translate([0,0,-nudge]) linear_extrude(height=plugStickout+h/2-probeLength/2+2*nudge) hull() {
            circle(d=cableHoleDiameter);
            translate([plugR2,0]) square(cableHoleDiameter,center=true);
        }
    }
}

buffer();
translate([r+10,0,0]) plug();