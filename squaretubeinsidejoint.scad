width = 45-.3;
corner = 5;
thickness = 1.5;
height = 10;
horizontalTaper = 1;
verticalTaper = 3;

nudge=0.001;

module mySquare(width) {
    $fn = 32;
    c = width/2-corner;
    hull() {
        translate([-c,-c]) circle(r=corner);
        translate([c,-c]) circle(r=corner);
        translate([-c,c]) circle(r=corner);
        translate([c,c]) circle(r=corner);
    }
}

module tapered(width=width,extra=0) {
    translate([0,0,-extra]) {
        linear_extrude(height=verticalTaper,scale=(width)/(width-2*horizontalTaper)) mySquare(width-2*horizontalTaper);
        translate([0,0,verticalTaper-nudge])
        linear_extrude(height=height+2*extra+2*nudge) mySquare(width);
        translate([0,0,verticalTaper+height+2*extra])
        linear_extrude(height=verticalTaper,scale=(width-2*horizontalTaper)/(width)) mySquare(width);
    }
}

render(convexity=2)
difference() {
    tapered();
    tapered(width=width-2*thickness,extra=nudge);
}