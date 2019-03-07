use <Bezier.scad>;

//<params>
width = 15;
spacing = 20;
restAngle = 15;
jawLength = 20;
handleLength = 25;
jawThickness = 2.5;
bottomTeethOffset = 1;
bottomToothHeight = 0;
bottomToothWidth = 1.5;
// 0.5 for symmetric teeth
bottomToothSet = 0.2; 
topTeethOffset = 1;
topToothHeight = 0;
// 0.5 for symmetric teeth
topToothWidth = 1.5;
topToothSet = 0.3; 
springThickness = 1.5;
poleScrewHoleDiameter = 3;
//</params>

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

module jaw(toothHeight, toothWidth, toothSet, teethOffset, holes=true) {

    jawProfile = [
        [jawLength+handleLength,-width/2],
        SHARP(),
        SHARP(),
        [0.25*width,-width/2],
        POLAR(0.15*width,135),
        POLAR(0.25*width,-90),
        [0,0],
        REPEAT_MIRRORED([0,-1])]; 

    translate([-handleLength,-jawThickness]) {

       translate([0,0,width]) rotate([-90,0,0]) 
        linear_extrude(height=jawThickness) 
        difference() {
            translate([0,width/2])
            polygon(Bezier(jawProfile));
            if (holes) {
                translate([width*0.5-width*0.2,width*0.3])
                circle(d=poleScrewHoleDiameter,$fn=16);
                translate([width*0.5+width*0.2,width-width*0.3])
                circle(d=poleScrewHoleDiameter,$fn=16);
            }
        }
        
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
    rotate([0,0,restAngle/2.]) jaw(bottomToothHeight, bottomToothWidth, bottomToothSet, bottomTeethOffset, holes=false);
    translate(springPoints[0]) rotate([0,0,-restAngle/2.]) translate([0,0,width]) rotate([180,0,0]) jaw(topToothHeight, topToothWidth, topToothSet, topTeethOffset, holes=true);
