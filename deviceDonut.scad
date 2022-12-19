/*
Mobile Device Donut Stand byrwagzis licensed under theCreative Commons - Attributionlicense.
https://creativecommons.org/licenses/by/4.0/
By downloading this thing, you agree to abide by the license: Creative Commons - Attribution - Non-Commercial - No Derivatives
Remixed by Alexander Pruss from: https://www.thingiverse.com/thing:4616985/
*/

use <Bezier.scad>;

//<params>
r1 = 31;
r2 = 55;
h = 33;
rounding = 3;
mode = 0; // 0:puck, 1:donut, 2:puck with hole, 3:lid for puck with hole, 4:puck with bridging
lidLip = 2;
lidTolerance = 2;
slotScaling = 1.5;
//</params>

size_upright = [17.5,16.5];
// paths for upright
points_upright = slotScaling*[ [5.25,-5.75],[8.75,-2.251],[8.75,1.74701],[7.733,1.89801],[7.41,2.01401],[6.528,2.54301],[6.27299,2.77301],[5.661,3.59901],[5.51399,3.91],[5.26399,4.90701],[5.25,5.20714],[5.25,8.25],[-2.75,8.25],[-8.75,-8.25],[5.25,-8.25],[5.25,-5.75] ];


size_angled = [26.5,14.5];
// paths for angled
points_angled = slotScaling*[ [-4.75,7.25],[-9.75,7.25],[-9.75,6.292877],[-9.89799,5.233],[-10.014,4.91],[-10.543,4.02802],[-10.773,3.77301],[-11.599,3.16101],[-11.91,3.01401],[-12.907,2.76401],[-13.25,2.74701],[-13.25,-1.25099],[-9.75101,-4.75],[-9.75,-4.753],[-9.75,-7.25],[13.25,-7.25],[-4.75,7.25] ];

module angled() {
    rotate([-90,0,0]) linear_extrude(height=150,center=true) translate([0,-size_angled[1]/2])
    polygon(points_angled);
}

module upright() {
    rotate([-90,0,0]) linear_extrude(height=150,center=true) translate([0,-size_upright[1]/2])
    polygon(points_upright);
}

module puck(hole=true) {
    rotate_extrude($fn=128) {
        polygon(Bezier([ [r1,0],LINE(),LINE(),[r2,0],
        LINE(),LINE(),[r2,h-rounding],POLAR(rounding/2,90),
        POLAR(rounding/2,0),[r2-rounding,h],
        LINE(),LINE(),[r1+rounding,h],POLAR(rounding/2,180),
        POLAR(rounding/2,90),[r1,h-rounding],LINE(),LINE(),
        [r1,0] ]));
        if (!hole)
            square([r1+rounding+.001,h]);
    }
}

module fillHoleProfile(inset=0,leftShift=0,rightShift=0) {
    leftShift = leftShift - 0.5*size_angled[0]*(slotScaling-1);
    rightShift = rightShift - 0.5*size_upright[0]*(slotScaling-1);
    intersection() {
        circle(r=r2-max(rounding,1.5)-lidLip-inset,$fn=128);
        translate([-leftShift-12,-r2]) square([38-lidLip-inset+leftShift+rightShift,2*r2],center=false);
    }
}

module fillHole() {
    myH = (mode==4)?(h-1.5-1.5):h-1.5+.01;
    if (mode==4) echo("lid height",myH);
    translate([0,0,1.5])
    hull() {
        translate([0,0,myH-.01]) linear_extrude(height=.01) fillHoleProfile(0);
        linear_extrude(height=.01) fillHoleProfile(0,leftShift=18,rightShift=8);
    }
}

module fillHoleLid() {
    linear_extrude(height=0.75) fillHoleProfile(inset=-lidLip);
    linear_extrude(height=2) fillHoleProfile(inset=lidTolerance);
}

module main() {
    if (mode == 3) 
        fillHoleLid();
    else difference() {
        puck(mode==1);
        translate([34,0,h-25+9-size_upright[1]*0.5*(slotScaling-1)]) upright();
        translate([-26,0,h-25+11-size_angled[1]*0.5*(slotScaling-1)]) angled();
        if (mode==2 || mode==4) fillHole();
    }
}

main();
