mouth = 30;
height1 = 45;
middle = 40;
height2 = 45;
lip = 90;
lipExtra = 1.5;
lipExtraHeight = 1.5;
wall = 1;

$fn = 128;
nudge = 0.001;
module funnel(inset=0) {
    d=2*inset;
    cylinder(d1=lip-d,d2=middle-d,h=height2+nudge);
    translate([0,0,height2]) cylinder(d1=middle-d,d2=mouth-d,h=height1);
}

render(convexity=2)
difference() {
    union() {
        funnel();
        cylinder(d=lipExtra*2+lip,h=lipExtraHeight);
    }
    funnel(inset=wall);
}
