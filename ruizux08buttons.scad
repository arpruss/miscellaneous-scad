length = 14.8;
width = 4.1;
baseThickness = 0.75;
buttonWidth = 2;
buttonsAreaLength = 13.3;
buttonThickness = 1.75;

module dummy(){}
$fn = 64;

linear_extrude(height=baseThickness)
hull()
for (i=[-1,1]) {
    translate([i*(length/2-width/2),0])
    circle(d=width);
}

difference() {
linear_extrude(height=baseThickness+buttonThickness)
hull() 
for (i=[-1,1]) {
        translate([i*(buttonsAreaLength/2-buttonWidth/2),0]) circle(d=buttonWidth);
}
translate([0,0,baseThickness+buttonThickness])
rotate([90,0,0])
cylinder(r=buttonThickness*0.6,h=4*buttonWidth,center=true);
}