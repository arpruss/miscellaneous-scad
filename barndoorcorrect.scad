headHeight = 3.4; // Thickness of spherical portion of bolt head
headWidth = 14.73; // Width of spherical portion of bolt head
extraThickness = 1; // Extra thickness of adjustment device
tolerance = 0.2; // We assume filament goes this far beyond its boundaries; set to 0 for 2D cutting
initialStickout = 3.07; // The top of the bolt head sticks out this far past the horizontal plane through the hinge 
distanceFromHinge = 292; // Distance from the rotational center of the hinge to the bolt
threadPitch = 1.27; // in mm: 20 tpi = 1.27
rpm = 1; // Planned speed of bolt rotation
distanceToEnd = 35; // Distance from center of bolt to the end of the board
correctorWidth = 20;
extraGap = 2; // extra gap between boards at zero angle
maxTime = 120; // in minutes
dimensions = 3; // choose 2 or 3

module dummy() {}

animate = 0;
adjustedStickout = initialStickout+extraThickness+tolerance;

headRadius = (pow((headWidth/2),2)+headHeight*headHeight)/(2*headHeight);
siderealDay = 23.9344699;
skyDegPerMin = 360*(24/siderealDay)/24/60;

function position(t) = adjustedStickout+1.27*rpm*t;
initialAngle = asin(position(0)/distanceFromHinge);
function angle(t) = initialAngle+skyDegPerMin*t;

module head(sweepBack=false) {
    render()
    translate([0,headRadius]) {
        intersection() {
            circle(r=headRadius,$fn=72);
            translate([-headRadius,-3*headRadius+headHeight]) square(2*headRadius);
        }
        if (sweepBack) {
            translate([-headWidth/2,-headRadius+headHeight]) square([headWidth,distanceToEnd]);
        }
    }
}

module bump(t) {
    render(convexity=2)
    rotate(angle(t))
    translate([distanceFromHinge,-position(t)]) {
        head(sweepBack=true);
    }
}

module arm(t) {
    render(convexity=2)
    translate([0,-correctorWidth,-1])     cube([distanceFromHinge+distanceToEnd,correctorWidth,2]);
    rotate([0,-angle(t),0]) {
        translate([0,-correctorWidth,-1]) cube([distanceFromHinge+distanceToEnd,correctorWidth,2]);
        translate([distanceFromHinge,-correctorWidth/2,-position(t)]) {
            rotate_extrude() 
            {
                intersection() {
                    union() {
                        translate([-headWidth*.1,headHeight]) square([headWidth*.2,position(t)-headHeight]);
                        head();
                    }
                    translate([0,0]) square([headWidth,position(t)]);
                }
                
            }
        }
    }
}

module corrector() {
    maxAngle = angle(maxTime);
    p = position(maxTime);
    r1 = norm([distanceFromHinge,p]);
    theta = maxAngle-atan2(p,distanceFromHinge);
    maxHeight=r1 * sin(theta)+extraGap;
    module flat() {
        difference() {
            translate([-headWidth/3,0]) square([distanceToEnd+headWidth/3,maxHeight+extraGap]);
            translate([-distanceFromHinge,extraThickness+extraGap])
            for (t=[0:.1:2*maxTime]) 
                bump(t);
        }
    }
    if (dimensions==3) 
        linear_extrude(height=correctorWidth) flat();
    else
        flat();
}

/*
if (animate) {
    for (t=[0:1:$t*maxTime]) {
        bump(t, attachments=false);
    }
    bump($t*maxTime,attachments=true);
}
*/
if (animate) {
    translate([0,0,-extraThickness])
    rotate([90,0,0])
    translate([distanceFromHinge,0,0]) corrector();
    arm($t*60);
}
else {
    corrector();
}
