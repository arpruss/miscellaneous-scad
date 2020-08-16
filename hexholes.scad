diameter = 0.6*25.4;
spacing = 0.3*25.4;
rows = 20;
columns = 20;

$fn = 32;

delta = spacing+diameter;

module row() {
    for (i=[0:columns-1])
        translate([delta*i,0]) circle(d=diameter);
}

for (i=[0:rows-1]) {
    if (i%2==0) {
        translate([0,sqrt(3)/2*delta*i]) row();
    }
    else {
        translate([delta/2,sqrt(3)/2*delta*i]) row();
    }
}
