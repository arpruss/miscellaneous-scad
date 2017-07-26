use <roundedsquare.scad>;

//<params>
distanceWallWartSticksOut=38;
powerbarHeight=36.5;
powerbarWidth=51;
wallWartWidth=55;
thickness=3.5;
innerCorner=6;
outerCorner=3;
cutOut=3;
thickness=3.5;
//</params>

module dummy(){}

w =distanceWallWartSticksOut;
h =powerbarHeight;
l =wallWartWidth;
extra=powerbarWidth;

module main() {
    linear_extrude(height=l)
    render(convexity=2)
    difference() {
        roundedSquare([h+thickness,w],radius=outerCorner);
        translate([thickness,thickness])
        roundedSquare([h-2*thickness,w-2*thickness],radius=innerCorner);
        translate([h-thickness-1,w/2-cutOut/2]) square([thickness+2+thickness,cutOut]);
    }
    translate([h,-extra])
    cube([thickness,extra+2*outerCorner,l]);
    translate([0,-extra-thickness+0.01])
    cube([h+thickness,thickness,l]);
}

main();