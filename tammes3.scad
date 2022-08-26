n=3;
minD=1.732050808;
bumpR = 2*sin((1/2)*asin(minD/2));
points = [[-0.353425852,0.467899576,-0.810037131],[0.001839409,0.465234770,0.885185419],[0.351586443,-0.933134346,-0.075148287]];
difference() {
 sphere(r=1,$fn=100);
 for(i=[0:len(points)-1]) translate(points[i]) sphere(r=bumpR,$fn=12);
}

