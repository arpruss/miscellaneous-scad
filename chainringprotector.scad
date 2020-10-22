outerDiameter = 205;
outerInset = 10;
stickout = 5;
standoffLength = 5.5;
standoffDiameter = 6;
standoffConnectorMinimumHeight = 3;
screwHole = 3;
// clockwise
screwSpacings = [119.5,109.4,119.5,109.4]; 
crankGap = 40;
chamfer = 1;

flatWall = 2;
curvedWall = 2;

module dummy() {}

precision = 0.0001;

function sum(v,n=undef,soFar=0,pos=0) = pos >= (n==undef ? len(v) : n) ? soFar :
             sum(v,n=n,soFar=soFar+v[pos],pos=pos+1);

function totalAngle(radius) = sum([for(d=screwSpacings) d<=2*radius ? 2*asin(d/(2*radius)) : 1e100]);
    
function solveRadius(d1=precision,d2=sum(screwSpacings)) = 
    (d2-d1) <= precision ? (d1+d2)/2 :
    totalAngle((d1+d2)/2) >= 360 ? solveRadius(d1=(d1+d2)/2,d2=d2) : solveRadius(d1=d1,d2=(d1+d2)/2);    

standoffR = solveRadius();
standoffAngles = [for(s=screwSpacings) 2*asin(s/(2*standoffR))];
standoffAnglesCumulative = [for(i=[0:1:len(standoffAngles)-1]) sum(standoffAngles,i)];

echo("standoff radius",standoffR);

nudge = 0.01;

$fn = 128;

module hollowCylinder(id,od,height,arc=360) {
    linear_extrude(height=height) {
        intersection() {
            difference() {
                circle(d=od);
                circle(d=id);
            }
            if (arc<360) {
                polygon(concat([[0,0]], [for(i=[0:1:$fn]) let(angle=-arc/2+arc*i/$fn) (od+id)/4 * [cos(angle),sin(angle)]]));
            }
        }
}
}

d1 = outerDiameter-2*outerInset-2*curvedWall;
d2 = outerDiameter-2*outerInset;
d3 = outerDiameter;

module main() {
    hollowCylinder(d1,d3,flatWall);
    hollowCylinder(d1,d2,flatWall+stickout);
    translate([0,0,flatWall-nudge])
    rotate_extrude() {
        translate([d2/2-nudge,0]) polygon([[0,0],[chamfer,0],[0,chamfer]]);
    }
}

module standoffs() {
    // standoffAnglesCumulative is clockwise, but here we use it counterclockwise as we're working upside-down
    for(angle=standoffAnglesCumulative) rotate([0,0,angle]) {
        difference() {
            hull() 
            {
                translate([standoffR,0,0]) hollowCylinder(screwHole,standoffDiameter,standoffLength+flatWall+stickout);
                hollowCylinder(d1,d1+nudge,standoffConnectorMinimumHeight,arc=25);
            }
            translate([standoffR,0,-5]) cylinder(d=screwHole,h=standoffLength+flatWall+stickout+10);
        }
    }
}


difference() {
    union() {
        main();
        standoffs();
    }

/*    rotate([0,0,45]) 
    
    translate([0,-crankGap/2,flatWall]) cube([outerDiameter+1,crankGap,standoffLength+flatWall+stickout+10]);
    */
}