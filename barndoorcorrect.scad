headHeight = 3.4; // Thickness of spherical portion of bolt head
headWidth = 14.73; // Width of spherical portion of bolt head
minimumThickness = 1.5; // Minimum thickness of adjustment device
tolerance = 0.25; // We assume filament goes this far beyond its boundaries
initialStickout = 3.07; // The top of the bolt head sticks out this far past the horizontal plane through the hinge 
distanceFromHinge = 294.5; // Distance from the rotational center of the hinge to the bolt
threadPitch = 1.27; // in mm: 20 tpi = 1.27
rpm = 1; // Planned speed of bolt rotation
distanceToEnd = 35; // Distance from center of bolt to the end of the board
correctorWidth = 14;
maxTime = 120; // in minutes

module dummy() {}

animate = 0;
adjustedStickout = initialStickout+minimumThickness+tolerance;

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

module bump(t, attachments=false) {
    render(convexity=2)
    rotate(angle(t))
    translate([distanceFromHinge,-position(t)]) {
        if (attachments) {
            translate([-distanceFromHinge,position(t)]) square([distanceFromHinge,1]);
            translate([-headWidth*.9,0]) square([3,position(t)]);
        }
        head(sweepBack=!attachments);
    }
}

if (animate) {
    for (t=[0:1:$t*maxTime]) {
        bump(t, attachments=false);
    }
    bump($t*maxTime,attachments=true);
}
else {
    linear_extrude(height=correctorWidth)
    difference() {
        translate([-headWidth/3,0]) square([distanceToEnd+headWidth/3,distanceToEnd]);
        translate([-distanceFromHinge,minimumThickness])
        for (t=[0:.1:2*maxTime]) 
            bump(t, attachments=false);
    }
}

