height = 75;
pumpDiameter = 26;
pumpOpeningAngle = 100;
pumpWallThickness = 2;
tubeDiameter =  32; 
tubeOpeningAngle = 260;
tubeWallThickness = 4;

topHolderHeight = 45; 
cinch = 3.5;
topSlit = 4;
zipTieHoleHeight = 5.7;
zipTieHoleWidth = 3;
plasticSavingHoleHeightRatio = 0.72;

module dummy() {}

nudge = 0.01;
$fn = 72;

module cyl(id,wall,openingAngle,height) {
    difference() {
        rotate([0,0,openingAngle/2])
        rotate_extrude(angle=360-openingAngle) {
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

difference() {
    main();
    for (h=[ height * 0.2 , height * .8 - zipTieHoleHeight ])
    translate([-tubeWallThickness/2,0,h])
    cube([zipTieHoleWidth,100,zipTieHoleHeight], center=true);
    translate([0,-50,height])
    rotate([0,45,0]) cube(100);
    
}