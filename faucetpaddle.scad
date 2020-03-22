use <Bezier.scad>;

fullHeight = 30;
length = 43.21;
width = 37.32;
straightLength = 23.71;
tolerance = 0.1;
minimumThickness = 2.5;
paddleHeight = 16;
paddleThickness = 8;
paddleLength = 80;
inset = 3.5;
insetHeight = 1.25;

H = (length-straightLength)/2;
W = width;
R = H/2+W*W/(8*H);
center = H-R;
echo(R);
echo(norm([W/2,H-R]));

module profile() {
    polygon(Bezier([[0,0],LINE(),LINE(),[paddleLength-paddleHeight/4,0],POLAR(paddleHeight/4,45),POLAR(paddleHeight/4,-90),[paddleLength,paddleHeight/2],REPEAT_MIRRORED([0,1])]));
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
            square([W+2*delta,straightLength],center=true);
            }
            square([W+2*delta,straightLength+4*radius],center=true);
        }
    }
}

x = width/2+minimumThickness;
y = straightLength/2+minimumThickness;
x0 = paddleThickness/2;
y1 = paddleLength;
edge = Bezier([[x,0],POLAR(length/4,90),POLAR(y/2,-90),[x,y],SMOOTH_ABS(y/2),POLAR(3*y,-90), [x0,y1-x0],SMOOTH_ABS(x0/2),POLAR(x0/2,0),[0,y1],REPEAT_MIRRORED([1,0])]);

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
            linear_extrude(height=paddleHeight) section();
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
