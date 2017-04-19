dovetailWidth = 13;
dovetailHeight = 3;
extraHeight = 3;
length = 51;
holeSpacing = 18;
holeDiameter = 4.5;

module dummy() {}

extraWidth = dovetailWidth - 2*dovetailHeight;

translate([0,0,extraHeight+dovetailHeight])
rotate([0,180,0])
render(convexity=2)
difference() {
rotate([90,0,0])
linear_extrude(height=length)
polygon([ [-extraWidth/2,0], [-extraWidth/2,extraHeight], [-extraWidth/2-dovetailHeight,extraHeight+dovetailHeight], [extraWidth/2+dovetailHeight,extraHeight+dovetailHeight], [extraWidth/2,extraHeight], [extraWidth/2,0]]);
translate([0,-length/2+holeSpacing/2,-1]) cylinder(d=holeDiameter,h=extraHeight+dovetailHeight+2);
translate([0,-length/2-holeSpacing/2,-1]) cylinder(d=holeDiameter,h=extraHeight+dovetailHeight+2);
}