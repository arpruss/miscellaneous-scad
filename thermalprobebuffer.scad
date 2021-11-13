volume = 40;
aspect = 1.5;

probeLength = 16.8;
probeDiameter = 5.04;
probeTolerance = 0.5;
probeNeckDiameter = 6.45;
probeNeckLength = 5;
probeHolderDiameter = 8.26;
probeHolderLength = 5;
probeHolderExtra = 10;
probeHolderTolerance = 0.25;
attachmentWidth = 15;

// volume = 4 aspect pi r^3

r = pow(volume*1000/(4*aspect*PI),1/3);

$fn = 64;

h = aspect*2*r;
nudge = 0.001;

module probeHole() {
    length = probeLength+probeNeckLength+probeHolderLength+probeHolderExtra;
    cylinder(d=probeDiameter+2*probeTolerance,h=length);
    translate([0,0,probeLength]) {
        cylinder(d=probeNeckDiameter+2*probeTolerance,h=probeNeckLength+nudge);
        translate([0,0,probeNeckLength]) cylinder(d=probeHolderDiameter+2*probeHolderTolerance,h=probeHolderLength+probeHolderExtra);
    }
}

module buffer() {
    difference() {
        union() {
            cylinder(r=r,h=h);
            translate([r-attachmentWidth,-attachmentWidth/2,0]) cube([attachmentWidth,attachmentWidth,h]);
        }
        translate([0,0,h/2-probeLength/2]) probeHole();
    }
}

buffer();

echo("bottom wall", h/2-probeLength/2);
echo("side wall", r-probeDiameter/2-probeTolerance);