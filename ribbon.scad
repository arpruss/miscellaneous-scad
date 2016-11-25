
module ribbon(points, thickness=1, closed=false) {
    p = (closed && points[0] != points[len(points)-1]) ? concat(points, [points[0]]) : points;
    n = len(p);
    
    union() {
        xOffset = concat(p, [for (i=[0:n-1]) p[n-1-i]+[.002,0]]);
        offset(r=thickness/2, $fn=8) polygon(points=xOffset);
        yOffset = concat(p, [for (i=[0:n-1]) p[n-1-i]+[0,.002]]);
        offset(r=thickness/2, $fn=8) polygon(points=yOffset);
    }
}

pi = 3.1415926535897932;
function SIN(theta) = sin(theta * 180 / pi);
function COS(theta) = cos(theta * 180 / pi);
function TAN(theta) = tan(theta * 180 / pi);

color("red") linear_extrude(height=10)
 ribbon([for (theta=[0:0.1:2*pi]) [theta * 10 / (2*pi), SIN(theta) * 10 / (2*pi)]], thickness=3, height=10, closed=true);
color("blue") linear_extrude(height=10)
 ribbon([for (theta=[0:0.1:2*pi]) [theta * 10 / (2*pi), SIN(theta) * 10 / (2*pi)]], thickness=.1, height=10, closed=true);
ribbon([for (theta=[0:0.1:2*pi+.1]) [COS(theta)*10, SIN(3*theta) * 10]], thickness=.5);
    