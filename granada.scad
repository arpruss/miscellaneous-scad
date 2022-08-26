use <quickthread.scad>;

verticalPeriod = 25;
horizontalAmplitude = 5;
slicesPerPeriod = 24;
height = 100;

center_solomonic_1 = [79.199909333,42.292352021];
size_solomonic_1 = [1.631156250,7.371619750];
stroke_width_solomonic_1 = 0.066145833;
// paths for solomonic_1
points_solomonic_1_1 = [ [-0.815578125,-3.685809875],[-0.748958998,-3.150609391],[-0.572605793,-2.734330050],[-0.031722219,-2.073088138],[0.262295618,-1.735402233],[0.525022465,-1.331190808],[0.721202056,-0.814092195],[0.815578125,-0.137744729],[0.745489380,0.521014405],[0.560709961,1.042796876],[0.299470093,1.470260329],[-0.299470093,2.212860759],[-0.560709961,2.613313024],[-0.745489380,3.090076848],[-0.815578125,3.685809875] ];

points_left = points_solomonic_1_1[0][0];
points_bottom = points_solomonic_1_1[0][1];
points_top = points_solomonic_1_1[len(points_solomonic_1_1)-1][1];
scale = verticalPeriod / (points_top-points_bottom);
innerDiameter = 4.607347540 * scale;
profile = scale * [for (p=points_solomonic_1_1) p-[points_left,points_bottom]];
rawThread(profile, d=innerDiameter, h=height, clip=true);    