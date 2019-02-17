width = 15;
spacing = 20;
restAngle = 30;
jawLength = 20;
handleLength = 25;
jawThickness = 2.5;
bottomTeethOffset = 1;
bottomToothHeight = 1.5;
bottomToothWidth = 1.5;
bottomToothSet = 0.2; // 0.5 for symmetric teeth
topTeethOffset = 1;
topToothHeight = 0;
topToothWidth = 1.5;
topToothSet = 0.3; // 0.5 for symmetric teeth
springThickness = 2.25;

module dummy(){}

nudge = 0.01;

module ribbon(points, thickness=1, closed=false) {
    p = closed ? concat(points, [points[0]]) : points;
    
    union() {
        for (i=[1:len(p)-1]) {
            hull() {
                translate(p[i-1]) circle(d=thickness, $fn=8);
                translate(p[i]) circle(d=thickness, $fn=8);
            }
        }
    }
}

module jaw(toothHeight, toothWidth, toothSet, teethOffset) {
    translate([-handleLength,-jawThickness]) {
       translate([0,0,width]) rotate([-90,0,0]) 
        linear_extrude(height=jawThickness) 
        polygon([[jawLength+handleLength,width],[jawLength+handleLength,0],[0.25*width,0],[0,0.25*width],[0,0.75*width],[0.25*width,width]]);
         {
            if (toothHeight > 0) {
               n = floor((jawLength-teethOffset) / toothWidth);
               for (i=[0:n-1]) {
                   x = jawLength+handleLength - (i+1)*toothWidth;           
                   translate([0,-nudge])
                   linear_extrude(height=width)
                   polygon([[x,jawThickness],[x+toothWidth*toothSet,jawThickness+toothHeight],[x+toothWidth,jawThickness]]);
               } 
            }
        }
    }
}


circleAngle = 90.-restAngle/2.;

springPoints = [for (n=[circleAngle:1:360-circleAngle+1]) (spacing/2)*[cos(n),sin(n)]];
    
linear_extrude(height=width) {
    ribbon(springPoints, thickness=springThickness);
}

    translate(springPoints[len(springPoints)-1])    
    rotate([0,0,restAngle/2.]) jaw(bottomToothHeight, bottomToothWidth, bottomToothSet, bottomTeethOffset);
    translate(springPoints[0]) rotate([0,0,-restAngle/2.]) translate([0,0,width]) rotate([180,0,0]) jaw(topToothHeight, topToothWidth, topToothSet, topTeethOffset);
