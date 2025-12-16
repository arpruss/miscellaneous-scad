id = 6.75;
od = 12.5;
h = 5;

$fn = 64;

linear_extrude(height=h) difference() {
    circle(d=od);
    circle(d=id);
}