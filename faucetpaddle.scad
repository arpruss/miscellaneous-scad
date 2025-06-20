use <Bezier.scad>;

//<params>
fullHeight = 30;
leverHeight = 16;
// longest dimension of faucet, from rounded end to rounded end
length = 43.21;
// distance from flat to flat on faucet
width = 37.32;
// length of flat side
flatLength = 23.71;
// distance from center of rotation to end of lever
leverLength = 80;
tolerance = 0.12;
minimumThickness = 2.5;
leverThickness = 8;
inset = 3.5;
insetHeight = 1.25;
//</params>

H = (length-flatLength)/2;
W = width;
R = H/2+W*W/(8*H);
center = H-R;
echo(R);
echo(norm([W/2,H-R]));
$fn = 200;

module profile() {
    polygon(Bezier([[0,0],LINE(),LINE(),[leverLength-leverHeight/4,0],POLAR(leverHeight/4,45),POLAR(leverHeight/4,-90),[leverLength,leverHeight/2],REPEAT_MIRRORED([0,1])],precision=0.02));
}

module baseShape(delta=0) {
    hull() {
        radius = R+delta;
        top = length/2+delta-radius;
        intersection() {
            union() {
                translate([0,top])
                intersection() {
                    circle(r=radius);
                    translate([0,radius]) square(2*radius,center=true);
                }
                translate([0,-top])             intersection() {
                    circle(r=radius);
                    translate([0,-radius]) square(2*radius,center=true);
                }
            square([W+2*delta,flatLength],center=true);
            }
            square([W+2*delta,flatLength+4*radius],center=true);
        }
    }
}

x = width/2+minimumThickness;
y = flatLength/2+minimumThickness;
x0 = leverThickness/2;
y1 = leverLength;
edge = Bezier([[x,0],POLAR(length/4,90),POLAR(y/2,-90),[x,y],SMOOTH_ABS(y/2),POLAR(3*y,-90), [x0,y1-x0],SMOOTH_ABS(x0/2),POLAR(x0/2,0),[0,y1],REPEAT_MIRRORED([1,0])],precision=0.01);

module section() {
    difference() {
        union() {
            polygon(edge);
            baseShape(delta=minimumThickness);
        }
        baseShape(delta=tolerance);
    }
}


module main() {
    intersection() {
        union() {
            linear_extrude(height=leverHeight) section();
            linear_extrude(height=insetHeight)
                difference() {
                    baseShape(delta=tolerance*1.5);
                    baseShape(delta=-inset);
                }
            }
        rotate_extrude() profile();
        }

    linear_extrude(height=fullHeight) difference() {
        baseShape(delta=minimumThickness);
        baseShape(delta=tolerance);
    }
}

main();
