use <pointhull.scad>;

points = [ for(i=[0:99]) let(v=rands(-1,1,3)) 20*v/norm(v) ];
    
dualHull(points);