use <paths.scad>;
use <bezier.scad>;

//<params>
length = 51;
offsetHeight = 40;
holeDiameter = 3;

dovetailWidth = 13;
dovetailHeight = 3;
extraHeight = 4;
baseWidth = 13;
webThickness = 1.5;
mountThickness = 2.5;
mountWidth = 20;
cornerRadius = 2;
triangleSide = 6;
//</params>

module dummy() {}

nudge = 0.01;

module section() {
    left = [[-mountWidth/2,0], SHARP(), SHARP(), [-mountWidth/2,mountThickness], SHARP(), SYMMETRIC(),
    [-webThickness/2-cornerRadius,mountThickness],
    OFFSET([cornerRadius/2,0]), OFFSET([0,-cornerRadius/2]),
    [-webThickness/2,mountThickness+cornerRadius],SYMMETRIC(),SYMMETRIC(),
    [-webThickness/2,mountThickness+offsetHeight-cornerRadius], OFFSET([0,cornerRadius/2]),
    OFFSET([cornerRadius/2,0]),[-webThickness/2-cornerRadius,mountThickness+offsetHeight], SYMMETRIC(),
    SHARP(), [-baseWidth/2,mountThickness+offsetHeight], SHARP(), SHARP(), 
    [-baseWidth/2,mountThickness+offsetHeight+extraHeight],
    SHARP(), SHARP(),
    [-dovetailWidth/2+dovetailHeight/2,mountThickness+offsetHeight+extraHeight],SHARP(),SHARP(),[-dovetailWidth/2,mountThickness+offsetHeight+extraHeight+dovetailHeight],SHARP(),SHARP(),[0,mountThickness+offsetHeight+extraHeight+dovetailHeight]    
    ];
    //BezierVisualize(left);
    l = Bezier(left);
    path=stitchPaths(l,reverseArray(transformPath(mirrorMatrix([1,0]),l)));
    polygon(path);
}

extraWidth = dovetailWidth - 2*dovetailHeight;

module webbedMount() {
    render(convexity=2) 
    rotate([90,0,0])
    linear_extrude(height=length) {
        section();
    }
}

module triangleEnd() {
    linear_extrude(height=offsetHeight+mountThickness+nudge)
    polygon([[-triangleSide/2,0], [0,-triangleSide*sqrt(3)/2], [triangleSide/2,0]]);
}

module main() {
    render(convexity=4)
    difference() {
        webbedMount(); 
        translate([-mountWidth/2,0,-nudge]) cylinder(r=cornerRadius,h=mountThickness+2*nudge,$fn=4);
        translate([mountWidth/2,0,-nudge]) cylinder(r=cornerRadius,h=mountThickness+2*nudge,$fn=4);
        translate([-mountWidth/2,-length,-nudge]) cylinder(r=cornerRadius,h=mountThickness+2*nudge,$fn=4);
        translate([mountWidth/2,-length,-nudge]) cylinder(r=cornerRadius,h=mountThickness+2*nudge,$fn=4);
        
    hx = mountWidth/2-1.3*holeDiameter;
    translate([hx,-mountWidth/2,-nudge]) cylinder(d=holeDiameter, h=3*nudge+mountThickness+0.75*offsetHeight, $fn=16);
    translate([-hx,-mountWidth/2,-nudge]) cylinder(d=holeDiameter, h=3*nudge+mountThickness+0.75*offsetHeight, $fn=16);
    translate([hx,-length+mountWidth/2,-nudge]) cylinder(d=holeDiameter, h=3*nudge+mountThickness+0.75*offsetHeight, $fn=16);
    translate([-hx,-length+mountWidth/2,-nudge]) cylinder(d=holeDiameter, h=3*nudge+mountThickness+0.75*offsetHeight, $fn=16);
    }

    triangleEnd();
    translate([0,-length,0]) rotate([0,0,180]) triangleEnd();
}

rotate([-90,0,0]) main();