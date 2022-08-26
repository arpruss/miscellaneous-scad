use <Bezier.scad>;

jumpgateWidth = 101.4;
widthAdjust = 4;
switchWidth = 173;
tolerance = 0.3;
joint = 8;

baseY = -13;
baseX = -21.450146500;
x1 = -10.394344500;
y1 = 5.618686000;
x2 = 2.834822500;
y2 = 2.216901000;
v0 = [x2,y2]-[x1,y1];
d1 = norm(v0)+4.3;
v1 = v0/norm(v0)*d1;

$fn = 32;

profile = [ [-12.284223500,baseY],["s",[baseX,baseY]],[-14.485268500,12.996640000],[-8.787945500,12.996640000],[x1,y1],[x1,y1]+v1,[7.937502500+3,12.611245000],[21.450146500,12.611245000],["s",[14.616048500,baseY]] ];

fixedProfile = [for (xy=Bezier(PathToBezier(profile, offset=1.5, closed=true))) xy-[baseX,baseY]];
    
width = (switchWidth-jumpgateWidth)/2-widthAdjust;

module block() {
linear_extrude(height=width) polygon(fixedProfile);
}

spacing = jumpgateWidth+tolerance*2;
rotate([90,0,0]) {
    block();
    translate([0,0,width+spacing]) block();
    difference() {
        linear_extrude(height=width*2+spacing) scale([0.75,1]) translate([joint*.25,0]) intersection() {
            circle(r=joint);
            translate([0,joint]) square(2*joint,center=true);
        }
        translate([0,-.01,width]) linear_extrude(height=spacing) polygon(fixedProfile);
    }
}