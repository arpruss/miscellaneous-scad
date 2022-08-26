use <Bezier.scad>;

ratio = 1.1;
thickness = 8;
length = 32;
wall = 1.25;
handle = 8;

heart = Bezier([ [ 0, 12 ], POLAR(2,90), POLAR(1,180), [ 4, 15 ], POLAR(1,0), POLAR(4,90), [8,10], POLAR(4,-90), POLAR(4,90-20), [0,0], REPEAT_MIRRORED([-1,0]) ], precision=0.05);

length0 = max([for (a=heart) a[1]]);
    
scale = length/length0;

module drawIt(points) {
    scaled = length/length0 * [for (a=points) a-[0,length0/2]];
    top= scaled*ratio;

    intersection() {
        for (i=[0:len(scaled)-1]) {
            j=(i+1)%len(scaled);
            hull() {
                translate([scaled[i][0],scaled[i][1],0]) sphere(d=wall);
                translate([scaled[j][0],scaled[j][1],0]) sphere(d=wall);
                translate([top[i][0],top[i][1],thickness]) sphere(d=wall);
                translate([top[j][0],top[j][1],thickness]) sphere(d=wall);
            }
        }
        translate([-length*4,-length*4,0]) cube([8*length,8*length,thickness]);
    }
}

drawIt(heart);
drawIt([ [8,10], [8+handle/scale,10] ]);
drawIt([ [-8,10], [-8-handle/scale,10] ]);
drawIt([ [0,0], [0,-handle/scale] ]);
drawIt([ [0,12], [0,12+handle/scale] ]);