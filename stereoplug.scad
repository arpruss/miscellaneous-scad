tolerance  = 0.2;
wall = 1.5;
bottomHole = 3.5;
middleHole = 6;
topHole = 4;

bottomLength = 2;
middleLength = 10;
topLength = 4;

module dummy(){}

$fn = 24;
nudge = 0.01;

module cyl(id,height,id2=undef) {
    id2 = id2 == undef ? id : id2;
    
    difference() {
        cylinder(d1=id+2*wall+2*tolerance,d2=id2+2*wall+2*tolerance,height+2*nudge);
        translate([0,0,-nudge])
        cylinder(d1=id+2*tolerance,d2=id2+2*tolerance,height+4*nudge);
    }
}

cyl(bottomHole,bottomLength,middleHole);
translate([0,0,bottomLength]) cyl(middleHole,middleLength);
translate([0,0,bottomLength+middleLength]) cyl(middleHole,topLength,topHole);