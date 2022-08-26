n=2;
minD=2.000000000;
bumpR = 2*sin((1/2)*asin(minD/2));
points = [[-0.523507946,0.820984997,-0.227866333],[0.523507946,-0.820984997,0.227866333]];
difference() {
 sphere(r=1,$fn=100);
 for(i=[0:len(points)-1]) translate(points[i]) sphere(r=bumpR,$fn=12);
}

