width_vase = 1;

center_vase_1 = [6.271974021,11.693050000];
size_vase_1 = [12.543948041,23.386100000];
stroke_width_vase_1 = 0.400000010;
// paths for vase_1
points_vase_1_1 = [for (a=[ [-6.271974021,-11.693050000],[1.345207579,-11.693050000],[4.222142029,-8.976240000],[5.916018511,-5.911742500],[6.271974021,-4.049662500],[6.089241979,-2.004530000],[4.625331593,1.310545313],[0.982232296,4.565118438],[0.142494579,6.013560000],[0.191887295,7.556129687],[0.797035804,8.834300000],[4.285171979,11.693050000] ]) [(a[0]+center_vase_1[0])*1.25,(a[1]+center_vase_1[1])*1.9]];

module ribbon(points, thickness=1) {
    p = points;
    
    union() {
        for (i=[1:len(p)-1]) {
            hull() {
                translate(p[i-1]) scale([1,1.25]) circle(d=thickness, $fn=8);
                translate(p[i]) scale([1,1.25]) circle(d=thickness, $fn=8);
            }
        }
    }
}

module ribbon_vase_1(width=width_vase) {
  ribbon(points_vase_1_1, thickness=width);
}

rotate_extrude($fn=64) intersection() {
    ribbon_vase_1();
    translate([0,-10]) square([100,100]);
}

