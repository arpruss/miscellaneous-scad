od = 9.43;
upperOD = 8;
upperExtra = 3;
id = 5.81;
height = 13.1;
bottomLipHeight = 0.75;
bottomLipStickout = 1.5;
tolOuter = .05;
tolInner = .2;
bottomSlitLength = 9;
slitOverlap = 1.75;
slitWidth = 1;

$fn = 32;
nudge = .001;

module annulus(id=5,od=10) {
    difference() {
        circle(d=od);
        circle(d=id);
    }
}

module main() {
    difference() {
        union() {
            linear_extrude(height=bottomLipHeight) annulus(id=id+2*tolInner,od=od-2*tolOuter+2*bottomLipStickout);
            linear_extrude(height=height) annulus(id=id+2*tolInner,od=od-2*tolOuter);
            linear_extrude(height=height+upperExtra) annulus(id=id+2*tolInner,od=upperOD-2*tolOuter);
        }
        cube([30,slitWidth,2*bottomSlitLength],center=true);
        translate([-slitWidth/2,-15,bottomSlitLength-slitOverlap]) cube([slitWidth,30,30]);
    }
}

main();