use <pointhull.scad>;

//<params>
dimension = 3;
maxNumberOfPoints = 500;
seed = 1;
radius = 50;
//</params>

points0 = rands(-radius,radius,dimension*maxNumberOfPoints,seed);
points = [for (i=[0:maxNumberOfPoints-1]) let(p=[for(j=[0:dimension-1]) points0[i*dimension+j]]) if(norm(p)<=radius) p];

pointHull(points);
