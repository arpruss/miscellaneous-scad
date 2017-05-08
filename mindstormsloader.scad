sides = 5;
supportThickness = 3;
strutThickness = 2.5;
strutAngle = 45;
numberOfSegments = 2;
insideDiameter = 17.5;
crossTolerance = 0.25;

module dummy();

crossDiameter = 4.87;
crossArmThickness = 1.83;
crossLength = 7.72;
crossOffsetFromInside = 10.38;
crossAttachmentLength = 10;

inradius = insideDiameter / 2;

diameter = inradius * 2 / cos(180/sides);

sideLength = diameter * sin(180/sides);
echo(inradius);
segmentHeight = sideLength * tan(strutAngle);
totalHeight = numberOfSegments*segmentHeight;
echo(str("Height ",totalHeight,"mm"));
echo(str("Works for ",totalHeight/16.83," balls"));

nudge = 0.01;

module ring() {
    render(convexity=2)
    difference() {
        cylinder(d=diameter+2*supportThickness, h=supportThickness, $fn=sides);
        translate([0,0,-nudge]) cylinder(d=diameter, h=supportThickness+2*nudge, $fn=sides);
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
            rotate([0,90-strutAngle,0]) rotate([0,0,45]) cylinder(d=strutThickness, h=(sideLength*(diameter+strutThickness)/diameter)/cos(strutAngle), $fn=4);
        }
       cylinder(d=diameter+2*supportThickness, h=totalHeight, $fn=sides);
    }
}

module cross2d() {
    square([crossDiameter-2*crossTolerance,crossArmThickness-2*crossTolerance],center=true);
    square([crossArmThickness-2*crossTolerance,crossDiameter-2*crossTolerance],center=true);
}

module cross() {
    roundDiameter=crossDiameter+1;
    extraTransitionLength=1;
    transitionLength = roundDiameter/2-crossArmThickness/2;
    translate([inradius+crossOffsetFromInside,0,0]) 
    {
        linear_extrude(height=2,scale=1/0.75) scale(0.75) cross2d();
        translate([0,0,2-nudge])
        linear_extrude(height=crossLength+nudge-2+transitionLength) cross2d();
        translate([0,0,crossLength])
        cylinder(d1=crossArmThickness-crossTolerance*2,d2=roundDiameter,h=transitionLength+nudge);
        translate([0,0,crossLength+transitionLength])
        cylinder(d=roundDiameter,h=crossAttachmentLength+extraTransitionLength);
        translate([-(crossOffsetFromInside),-roundDiameter/2,crossLength+transitionLength+extraTransitionLength])
        cube([crossOffsetFromInside,roundDiameter,crossAttachmentLength]);
    }
    translate([inradius,-sideLength/2,crossLength+transitionLength+extraTransitionLength])
    cube([supportThickness*cos(180/sides) ,sideLength,crossAttachmentLength]);
}

module tube() {
    rotate([0,0,180/sides]) {
        ring();
        segments();
        translate([0,0,totalHeight-supportThickness]) ring();
        for(i=[0:sides-1]) translate((diameter/2+supportThickness/2)*[cos(i*360/sides),sin(i*360/sides),0]) cylinder(d=supportThickness,h=totalHeight,$fn=sides);
        }
}

tube();
cross();

