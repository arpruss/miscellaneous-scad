// based on design from:
// http://www.instructables.com/id/Parametric-Chainmail-in-Fusion-360/?utm_source=newsletter&utm_medium=email

wireWidth = 2;
linkWidth = 20;
linkLength = 12;
linkHeight = 7;
spacing = 1.25;

nRows = 10;
nCols = 10;

module link() {
    cube([linkWidth,wireWidth,wireWidth]);
    translate([0,linkLength-wireWidth,0]) cube([linkWidth,wireWidth,wireWidth]);
    module topPart() {
        cube([wireWidth,wireWidth,linkHeight]);
        translate([0,linkLength-wireWidth,0]) 
        cube([wireWidth,wireWidth,linkHeight]);
        translate([0,0,linkHeight-wireWidth])
        cube([wireWidth,linkLength,wireWidth]);
    }
    topPart();
    translate([linkWidth-wireWidth,0,0])
    topPart();
}

module main() {
    for (i=[0:nCols-1]) {
        translate([i*(linkWidth+spacing),0,0]) {
            for(j=[0:nRows-1]) {
                translate([0,j*(linkLength+spacing),0]) link();
            }
        }
    }
}

main();
translate([linkWidth/2+spacing/2,linkLength/2+spacing/2,0]) main();