use <bezier.scad>;
use <ribbon.scad>;

//<params>
curve = [ [0.5,0], OFFSET([0,-5]), OFFSET([0,5]), 
          [0,-10], OFFSET([0,-10]), OFFSET([0,-10]), 
          [-10,-10], OFFSET([0,5]), OFFSET([0,5]), 
          [0,-10], OFFSET([0,5]), OFFSET([0,5]), 
          [-10,-10], OFFSET([0,10]), OFFSET([-8,2]),
          [0,10], SMOOTH_REL(1.4), OFFSET([-2,0]), 
          [5,-10], SYMMETRIC(), OFFSET([-.1,0]), [5.2,-10]
          
        ];  
//</params>

//BezierVisualize(curve, lineThickness=0.1, precision=0.1);
ribbon(Bezier(curve, precision=0.1)) sphere(d=3.5, $fn=6);
