lensBaseDiameter = 66;
lensThreadLinearLength = 36.64;
lensThreadLinearLengthToDetent = 30.28;
lensThreadHeight = 1.19;
lensThreadWidth = 1.5;
lensSpaceBelowThread = 1.5;
detentWidth = 1.3;
detentDepth = 1;
endStopLinearLength = 5;
angularTolerance = 15;

outerDiameter = 74;
height = 5;

zTolerance = 0.25;
xyTolerance = 0.5;

function linearToAngular(l,r=lensBaseDiameter/2) = 
    2*asin(l/(2*r));
    
nudge = 0.01;

module hollowCylinder(d1=10,d2=20,h=10) {
    render(convexity=2) 
    difference() {
        cylinder(d=d2,h=h);
        translate([0,0,-nudge]) cylinder(d=d1,h=h+2*nudge);
    }
}
    
module arc(angle=180,d=undef,r=10,width=1,outward=true,center=true,chamferLowerEnd=false) {
    r0 = d==undef ? r : d/2;
    r1 = outward ? r0 : r0-width;
    r2 = outward ? r0+width : r0;
    adjR2 = 4*r2;
    angle0 = center ? -angle/2 : 0;
    render(convexity=2)
    difference() {
        intersection() {
            difference() {
                circle(r=r2);
                circle(r=r1);
            }
            if (angle<360)
               polygon(concat([[0,0]], adjR2*[for(i=[0:3]) [cos(angle*i/3+angle0),sin(angle*i/3+angle0)]]));
        }
        if(chamferLowerEnd) {
            rotate(angle0) translate([r1,0]) circle(r=width,$fn=4);
        }
    }
}

module base() {
    d1 = lensBaseDiameter+2*lensThreadHeight+2*xyTolerance;
    arcAngle = 180-linearToAngular(lensThreadLinearLength)-angularTolerance;
    endStopAngle = linearToAngular(endStopLinearLength);

    module detent() {
        polygon([[d1/2-detentDepth,0],[d1/2,-detentWidth/2],[d1/2,detentWidth/2]]);
    }

    hollowCylinder(d2=outerDiameter,d1=d1, h=height);
    
    for (rot=[0:180:180]) rotate([0,0,rot]) {
        linear_extrude(height=lensSpaceBelowThread-zTolerance) {
            {
                arc(angle=arcAngle,d=d1+nudge,width=nudge+lensThreadHeight, center=false,outward=false,chamferLowerEnd=true);
            }
        }
        linear_extrude(height=lensSpaceBelowThread+lensThreadHeight) {
            rotate(arcAngle-endStopAngle)
            arc(angle=endStopAngle,d=d1+nudge,width=nudge+lensThreadHeight, center=false, outward=false);
            rotate(arcAngle-endStopAngle-linearToAngular(lensThreadLinearLengthToDetent)) detent();            
        }
    }
}

$fn = 64;
base();
