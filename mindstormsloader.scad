sides = 5;
supportThickness = 3;
strutThickness = 2.5;
strutAngle = 45;
numberOfSegments = 8;
insideDiameter = 17;

module dummy();

inradius = insideDiameter / 2;

diameter = inradius * 2 / cos(180/sides);

sideLength = diameter * sin(180/sides);
echo(inradius);
segmentHeight = sideLength * tan(strutAngle);
totalHeight = numberOfSegments*segmentHeight;

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

ring();
segments();
translate([0,0,totalHeight-supportThickness]) ring();
for(i=[0:sides-1]) translate((diameter/2+supportThickness/2)*[cos(i*360/sides),sin(i*360/sides),0]) cylinder(d=supportThickness,h=totalHeight,$fn=sides);
