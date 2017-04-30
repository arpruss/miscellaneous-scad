distance = 294.5;
headHeight = 3.4;
headWidth = 14.73;
initialStickout = 3.07;
distanceFromHinge = 294.5;
threadPitch = 1.27; // in mm: 20 tpi = 1.27;
rpm = 1;
maxTime = 120; // in minutes

module dummy() {}

headRadius = (pow((headWidth/2),2)+headHeight*headHeight)/(2*headHeight);
siderealDay = 23.9344699;
skyDegPerMin = 360*(24/siderealDay)/24/60;

function position(t) = initialStickout+1.27*rpm*t;
initialAngle = asin(position(0)/distanceFromHinge);
function angle(t) = initialAngle+skyDegPerMin*t;

module head() {
    render()
    translate([0,headRadius])
    intersection() {
        circle(r=headRadius,$fn=60);
        translate([-headRadius,-3*headRadius+headHeight]) square(2*headRadius);
    }
}

module bump(t, attachments=false) {
    render(convexity=2)
    rotate(angle(t))
    translate([distanceFromHinge,-position(t)]) {
        if (attachments) {
            translate([-distanceFromHinge,position(t)]) square([distanceFromHinge,1]);
            translate([-1.5,0]) square([3,position(t)]);
        }
        head();
    }
}

//hull()
for (t=[0:1:$t*maxTime]) {
    bump(t, attachments=false);
}

color("red")
bump($t*maxTime,attachments=true);
//}
