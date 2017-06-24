mouth = 30;
height1 = 45;
middle = 40;
height2 = 45;
lip = 90;
wall = 1;

nudge = 0.001;
module funnel(inset=0) {
    d=2*inset;
    cylinder(d1=lip-d,d2=middle-d,h=height2+nudge);
    translate([0,0,height2]) cylinder(d1=middle-d,d2=mouth-d,h=height1);
}

render(convexity=2)
difference() {
    funnel();
    funnel(inset=wall);
}