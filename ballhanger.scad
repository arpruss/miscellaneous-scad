bottom_height = 1.75; // 7
diameter = 10; // 12
blobSize = 0; // 4;
holeWall = 1.75; // 4.5;
holeSize = 1.25;

$fn = 36;
intersection() {
    union() {
        cylinder(d=diameter,h=bottom_height);
        render(convexity=2)
        for (i=[0:36:360]) rotate([0,0,i]) translate([diameter/2,0,0]) cylinder(d=blobSize,h=bottom_height);
            
        render(convexity=2)
        translate([0,0,bottom_height])
        scale([1,1,1.25])
        rotate([0,90,0])
        translate([0,0,-holeWall/2])
        difference() {
            linear_extrude(height=holeWall) circle(d=holeSize*2+holeWall*2);
            translate([-0.25*holeWall,0,-50]) cylinder(d=holeSize*2,h=100);
        }
    }
    cylinder(d=100,h=100);
}