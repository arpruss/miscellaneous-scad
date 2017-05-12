sides = 5;
supportThickness = 3;
strutThickness = 2.2;
strutAngle = 50;
numberOfSegments = 11;
insideDiameter = 17.5;
crossTolerance = 0.2;
addSupport = 1; // [1:yes, 0:no]
crossModuleOnly = 0; // [1:yes, 0:no]

module dummy();

crossDiameter = 4.87;
crossArmThickness = 1.83;
crossLength = 7.72;
crossOffsetFromInside = 10.38;
crossAttachmentLength = 10;
narrowingOfCross = 1;

inradius = insideDiameter / 2;

diameter = inradius * 2 / cos(180/sides);

sideLength = diameter * sin(180/sides);
segmentHeight = sideLength * tan(strutAngle);
totalHeight = numberOfSegments*segmentHeight;
echo(str("Height ",totalHeight,"mm"));
echo(str("Works for ",totalHeight/16.83," balls"));
cylDiameter = crossDiameter+crossTolerance*2+4;
crossHeight = 24;
nudge = 0.01;

module ring(h=supportThickness) {
    render(convexity=2)
    difference() {
        cylinder(d=diameter+2*supportThickness/cos(180/sides), h=h, $fn=sides);
        translate([0,0,-nudge]) cylinder(d=diameter, h=h+2*nudge, $fn=sides);
    }
}

module segments() {
    render(convexity=4)
    intersection() {
        for(j=[0:numberOfSegments-1])
        for(i=[0:sides-1]) {
            rotate([0,0,360/sides*i])
            translate([diameter/2+strutThickness/2,0,j*segmentHeight])
            rotate([0,0,180/sides+90])
            rotate([0,90-strutAngle,0]) 
            translate([-1.4*strutThickness/2,-strutThickness/2,-strutThickness*.05]) cube([strutThickness*1.4,strutThickness, strutThickness*.1+(sideLength*(diameter+strutThickness)/diameter)/cos(strutAngle)]);
        }
       ring(h=totalHeight);
    }
}

module cross2d(toleranceDirection=-1) {
    t = crossTolerance * toleranceDirection;
    square([crossDiameter+2*t,crossArmThickness+2*t],center=true);
    square([crossArmThickness+2*t,crossDiameter+2*t],center=true);
}

module crossFemale(inside=false) {
    if (inside) {
        translate([0,0,-nudge]) linear_extrude(height=crossHeight+1+nudge) cross2d(toleranceDirection=1);
        if (addSupport) 
        translate([0,0,8-0.5]) difference() {
            cylinder(h=0.5, d=cylDiameter+nudge,$fn=8);
            cylinder(h=0.5, d=crossDiameter);
        }
        else {
            cylinder(h=8, d=cylDiameter+nudge,$fn=8);
        }
    }
    else {
        cylinder(h=crossHeight+2.5,d=cylDiameter,$fn=8);
    }
}

module cross(connector=true) {
    render(convexity=5)
    difference() {
        union() {
            translate([inradius+crossOffsetFromInside,0,0]) crossFemale();
            if (connector) {
                translate([inradius,-sideLength/2,0]) cube([supportThickness+nudge,sideLength,crossHeight]);
                translate([inradius,-supportThickness*1.5/2,8]) cube([
crossOffsetFromInside,supportThickness*1.5,crossHeight-8]);
            }
                
        }
        translate([inradius+crossOffsetFromInside,0,0])crossFemale(inside=true);
    }
}

module tube() {
    rotate([0,0,180/sides]) {
        ring();
        segments();
        translate([0,0,totalHeight-supportThickness]) ring();
        for(i=[0:sides-1]) translate((diameter/2+supportThickness/2)*[cos(i*360/sides),sin(i*360/sides),0]) cylinder(d=supportThickness,h=totalHeight,$fn=sides);
        }
}

if (crossModuleOnly) {
    cross(connector=false);
}
else {
    tube();
    cross();

}