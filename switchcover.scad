inch = 25.4;

screwSpacing = (2+3/8)*inch;
screwHole = 0.138*inch;
switchWidth = 3/8*inch;
switchHeight = 1*inch;
switchStickout = 13.83;
screwHead = 7.25;
beyondScrews = screwHead/2+6;
screwTolerance = 0.2;

wall = 2;
minWall = 1.5;

tolerance = 4;

insideWidth = switchWidth + 2*tolerance;
chord = switchHeight * 1.5 + 2*tolerance;
sagitta = switchStickout + tolerance;
R = sagitta/2+chord*chord/(8*sagitta);

nudge = 0.01;

module profile(full=false) {
    $fn = 48;
    render(convexity=2)
    intersection() {
    difference() {
        union() {
            translate([0,-R+sagitta]) circle(r=R+wall);
            translate([-beyondScrews-screwSpacing/2,0]) square([beyondScrews*2+screwSpacing,wall]);
        }
        if (!full) translate([0,-R+sagitta]) circle(r=R);
    }
        translate([-beyondScrews-screwSpacing/2,0]) square([beyondScrews*2+screwSpacing,sagitta+wall]);
    }
}

module positive() {
    linear_extrude(height=wall) profile(full=true);
    linear_extrude(height=wall+switchWidth+2*tolerance) profile(full=false);
    translate([0,0,wall+switchWidth+2*tolerance-nudge])
    linear_extrude(height=wall+nudge) profile(full=true);
    
}

module screwHole() {
    $fn=16;
    translate([0,0,-nudge])
        cylinder(d=screwHole+2*screwTolerance,h=wall+2*nudge);
    translate([0,0,minWall])
        cylinder(d=screwHead+2*screwTolerance,h=wall);
}

rotate([90,0,0])
render(convexity=4)
difference() {
    translate([0,wall+switchWidth/2+tolerance,0])
    rotate([90,0,0])
    positive();
    translate([screwSpacing/2,0,0]) screwHole();
    translate([-screwSpacing/2,0,0]) screwHole();
}