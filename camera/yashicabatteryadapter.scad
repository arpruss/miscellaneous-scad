batteryDiameter = 11.6;
diodeDiameter = 2.58;
diodeSlotLength = 8.6;
batterySlotDiameter = 13.4;
tolerance = 0.1;
baseThickness = 2.2;
lip = 3.8;


$fn = 64;
difference() {
    cylinder(d=batterySlotDiameter - 2*tolerance,h=lip+baseThickness);
    translate([0,0,baseThickness-0.001]) cylinder(d=batteryDiameter + 2*tolerance,h=lip+1);
    cube([diodeSlotLength,diodeDiameter+2*tolerance,diodeDiameter*4], center=true);
}