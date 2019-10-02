height = 75;
pumpDiameter = 26;
pumpOpeningAngle = 100;
pumpWallThickness = 2;
tubeDiameter =  32; 
tubeOpeningAngle = 260;
// needs to be at least as large as than pumpWallThickness and zipTieHoleWidth
tubeWallThickness = 4;

topHolderHeight = 45; 
cinch = 3.5;
topSlit = 4;
zipTieHoleHeight = 5.7;
zipTieHoleWidth = 3;

module dummy() {}

nudge = 0.01;
$fn = 72;

module rotate_extrude_angle(angle,maxSize=1000) {
    if (angle>0)
    intersection() {
        rotate_extrude() {
            children();
        }
        linear_extrude(height=maxSize, center=true) {
            for(i=[0:7]) {
                a0 = i==0 ? 0 : angle*(i/8-0.5/8);
                a1 = angle*(i+1)/8;
                polygon(maxSize*[[0,0],[cos(a0),sin(a0)],[cos(a1),sin(a1)]]);
            }
        }
    }
}

module cyl(id,wall,openingAngle,height) {
    difference() {
        rotate([0,0,openingAngle/2])
        rotate_extrude_angle(angle=360-openingAngle) {
            translate([id/2,0]) square([wall,height]);
        }
        
    }
}

module main() {
    translate([(pumpDiameter-cinch)/2,0,0])
    cyl(pumpDiameter-cinch,pumpWallThickness,pumpOpeningAngle,height);
    translate([-tubeDiameter/2-tubeWallThickness,0,0])
    rotate([0,0,180]) cyl(tubeDiameter,tubeWallThickness,tubeOpeningAngle,height);
}

render(convexity=2)
difference() {
    main();
    for (h=[ height * 0.2 , height * .8 - zipTieHoleHeight ])
    translate([-tubeWallThickness/2,0,h])
    cube([zipTieHoleWidth,100,zipTieHoleHeight], center=true);
    translate([0,-50,height])
    rotate([0,45,0]) cube(100);
    
}