width = 97.4;
strings = 12;
stringHole = 1.3;
length = 20;

thickness = 3;

spacing = width / (strings-1);
d = spacing-stringHole;

linear_extrude(height=thickness) {
    for (i=[0:strings-2]) {
        hull() {
            translate([i*spacing,0]) circle(d=d,$fn=32);
            translate([i*spacing,length-d]) square(d,center=true);
        }
        translate([i*spacing,length-d]) square(spacing+0.01,center=true);
    }
}