width = 34;
height = 10.5;
minimumHeight = 3;
strip = 10; 
spacing = 28;

cube([width,spacing+2*strip,minimumHeight]);
cube([width,strip,height]);
translate([0,strip+spacing,0]) cube([width,strip,height]);
