use <bezier.scad>;

//<params>
extrusionHeight = 20;
tension = 0.5;
precision = 0.1;
points = [ [ [0,0], [25,0], [50,0], [50,25], [50,50], [25,50], [0,50], [0,25] ], [[0,1,2,3,4,5,6,7]] ]; // [draw_polygon:100x100]
//</params>

linear_extrude(height=extrusionHeight);
for (path = points[1])
    polygon(points=Bezier(BezierSmoothPoints([for (p=path) points[0][p]],tension=tension,precision=-precision,closed=true)));