d = 5.63-0.6;
d2 = 5.63;
l1 = 11;
l2 = 21;
w = 10;
t = 1;
chamfer = 0.75;

nudge = 0.01;
rotate([90,0,0])
render(convexity=3) 
    intersection() {
        union() {
        cylinder(h=chamfer+nudge, d1=d-2*chamfer, d2=d, $fn=6);
        translate([0,0,chamfer])
        cylinder(h=l1-chamfer+nudge, d=d, $fn=6);
        translate([0,0,l1])
        cylinder(h=l2+t-2*chamfer+nudge, d=d2, $fn=6);
        translate([0,0,l1+l2+t-chamfer])
        cylinder(h=chamfer+nudge, d1=d2, d2=d2-2*chamfer, $fn=6);
        
        //cylinder(h=l1+l2+1, d=d, $fn=6);
        translate([0,0,l1])
            cylinder(h=1, d=w, $fn=12);
        }
    translate([-w,-d/2*cos(180/6),-1]) cube([2*w,2*w,l1+l2+t]);
    }
