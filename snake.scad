d1 = 10;
d2 = 60;
delta = 10;

tAdj = $t < 0.75 ? $t / 0.75 : 1;

for (angle=[0:delta:720-delta]) {
    pos1 = (d2/2 + (1-tAdj)*angle/360*d1) * [cos(angle),sin(angle)];
    pos2 = (d2/2 + (1-tAdj)*(angle+delta)/360*d1) * [cos(angle+delta),sin(angle+delta)];
    hull() {
        translate(pos1) rotate([0,0,angle]) rotate([90,0,0]) linear_extrude(height=1) circle(d=d1);
        translate(pos2) rotate([0,0,angle+delta]) rotate([90,0,0]) linear_extrude(height=1) circle(d=d1);
    }
}
