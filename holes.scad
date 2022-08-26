$fn = 64;

module myCircle(r,rMinor) {
        intersection() {
            translate([r,0]) circle(r=rMinor);
            translate([0,-rMinor]) square([r+rMinor,2*rMinor]);
        }
}

module donut(r=10,rMinor=1) {
    rotate_extrude() {
        myCircle(r,rMinor);
    }
}

module pancake(r1,y1,r2,y2,color1="red",color2="blue",thickness=15) {
    if (y2<y1) {
        pancake(r2,y2,r1,y1,color1=color2,color2=color1,thickness=thickness);
    }
    else {
        translate([0,0,y1]) rotate_extrude() hull() {
            myCircle(r1,thickness/2);
            translate([0,y2-y1]) myCircle(r2,thickness/2);
        }
        color(color1) translate([0,0,y1]) donut(r=r1,rMinor=thickness/2+.01);
        color(color2) translate([0,0,y2]) donut(r=r2,rMinor=thickness/2+.01);
    }
}

r1 = 50+30*cos($t*360);
r2 = 50+30*cos($t*360+180);
y1 = 30*sin($t*360);
y2 = 30*sin($t*360+180);
pancake(r1,y1,r2,y2);