hole = 4;
outerThickness = 1;
innerThickness = 3.5;
head = 8;
minThickness = 2;
diameter = 16;

nudge = 0.001;
$fn = 64;

rotate_extrude() {
    polygon([[diameter/2,0],
            [diameter/2,minThickness],
            [head/2,innerThickness],
            [hole/2,minThickness],
            [hole/2,0]]);
}
