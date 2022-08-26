inch = 25.4;
rim = 0.75 * 1/8 * inch;
id = (3/4+1/16) * inch - 0.2;
length = 0.5 * inch;
thickness = 1/16 * inch;
wall = 2;
id1 = id - 0.5;

difference() {
    cylinder(d1=id,d2=id1,h=length);
    translate([0,0,-0.01]) cylinder(d1=id-wall*2,d2=id1-wall*2,h=length+0.02);
}

cylinder(d=id1+2*rim,h=thickness);