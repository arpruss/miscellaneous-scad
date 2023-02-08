module rotateToPath(path, index, closed=false) {
    function getAngle(v) = atan2(v[1],v[0])-90;

    if (index == len(path)-1 && ! closed) {
        rotate([0,0,getAngle(path[index-1]-path[index])]) children();
    }
    else {
        nextIndex = (index == len(path)-1) ? 0 : index + 1;
        rotate([0,0,getAngle(path[nextIndex]-path[index])]) children();
    }
}

module ribbon(points, thickness=1, closed=false, rotate=false) {
    p = closed ? concat(points, [points[0]]) : points;
    
    union() {
        for (i=[1:len(p)-1]) {
            hull() {
                translate(p[i-1]) 
                    if ($children==0)
                        circle(d=thickness, $fn=8);
                    else if (!rotate)
                        children();
                    else 
                        rotateToPath(points,i==0 ? len(points)-1 : i-1,closed=closed) children();
                translate(p[i]) 
                    if ($children==0)
                        circle(d=thickness, $fn=8);
                    else if (!rotate)
                        children();
                    else 
                        rotateToPath(points, i==len(points) ? 0 : i,closed=closed) children();
            }
        }
    }
}

pi = 3.1415926535897932;
function SIN(theta) = sin(theta * 180 / pi);
function COS(theta) = cos(theta * 180 / pi);
function TAN(theta) = tan(theta * 180 / pi);

//<skip>
color("red") linear_extrude(height=10)
 ribbon([for (theta=[0:0.1:2*pi]) [theta * 10 / (2*pi), SIN(theta) * 10 / (2*pi)]], thickness=2, closed=true);
color("blue") linear_extrude(height=10)
 ribbon([for (theta=[0:0.1:2*pi]) [theta * 10 / (2*pi), SIN(theta) * 10 / (2*pi)]], thickness=.1, closed=true);
ribbon([for (theta=[0:0.1:2*pi+.1]) [COS(theta)*10, SIN(3*theta) * 10]], thickness=.5);


translate([0,0,20]) ribbon([for (theta=[0:0.2:2*pi+.1]) [COS(theta)*10, SIN(theta) * 10]], rotate=true, closed=true) intersection() {
    sphere(r=2,$fn=16);
    translate([2,0,0]) cube([4,0.01,4],center=true);
    }
    

//</skip>
    