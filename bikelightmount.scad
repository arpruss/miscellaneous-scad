//<params>
flashlightDiameter = 23.8;
flashlightGripLength = 28;
flashlightGripAngle = 242   ;
handlebarDiameter = 25; 
handlebarGripAngle = 150;
gripThickness = 2;
trimmedHull = 0; //[0:no,1:yes]
ziptieHoleThickness = 2;
ziptieHoleWidth = 5;
trimOffset = 8;
ziptieHoleWall = 1;
//</params>

module dummy() {}

$fn = 128;

heightFlash = flashlightGripLength;
heightHandle = 2*gripThickness + handlebarDiameter;
minHeight = min(heightFlash,heightHandle);

module grip(id=20,thickness=gripThickness,length=20,angle=180,insideOnly=false) {
    translate([-id/2,0,0]) 
    rotate([0,0,-angle/2])
    if (insideOnly)
        translate([0,0,-100]) cylinder(d=id,h=length+200);
    else 
        rotate_extrude(angle=angle) translate([id/2,0,0]) square([thickness,length]);
}

spacing = ziptieHoleThickness + 2*ziptieHoleWall;

handlebarGripLength = flashlightDiameter+gripThickness*2;

module pair(insideOnly=false) {
    grip(id=flashlightDiameter,length=flashlightGripLength,angle=flashlightGripAngle,insideOnly=insideOnly);

    translate([spacing,0,handlebarDiameter/2+gripThickness]) 
    translate([gripThickness,0,0]) 
    rotate([90,0,0]) 
    rotate([0,0,180]) 
    translate([0,0,-handlebarGripLength/2]) 
    grip(id=handlebarDiameter,length=handlebarGripLength,angle=180,insideOnly=insideOnly);
}

holeSpacing = (handlebarGripLength - 2 * ziptieHoleWidth) / 3;
holeLocation = holeSpacing / 2 + ziptieHoleWidth / 2;

module flashlightSnip() {
    translate([-flashlightDiameter/2,0,0])
    linear_extrude(height=flashlightGripLength*3,center=true) 
        polygon([ [0,0], 200*[cos(flashlightGripAngle/2),sin(flashlightGripAngle/2)], 200*[cos(flashlightGripAngle/2),-sin(flashlightGripAngle/2)] ]);
}

module trim() {
    translate([-flashlightDiameter-trimOffset,0,flashlightGripLength])  rotate([90,0,0]) cylinder(d=flashlightDiameter+2*gripThickness*2,h=200,$fn=4,center=true);
}

module main() {
    height=max(handlebarDiameter+2*gripThickness,flashlightGripLength);
    dx = handlebarDiameter/2 * cos((360-handlebarGripAngle)/2);
    difference() {
        union() {
            hull() intersection() {
                pair();
                if (trimmedHull) cube([200,200,minHeight*2],center=true);
            }
            pair();
        }
        pair(insideOnly=true);
        flashlightSnip();
        for (s=[-1,1]) translate([ziptieHoleThickness/2+ziptieHoleWall,holeLocation*s,height/2-.01]) cube([ziptieHoleThickness,ziptieHoleWidth,height+.05],center=true);
            trim();
        translate([dx+handlebarDiameter/2+spacing+gripThickness,-100,-1]) cube([200,200,200]);
    }
}

main();