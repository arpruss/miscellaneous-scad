includeLid = false;
includeBox = true;

snapSpacing = 26;
pcbLength = 33.77;
pcbThickness = 1.53;

offsetFromBase = 3.75;
offsetFromTop = 10;
wall = 1.75;
bottomHeight = 15;
lidTolerance = 0.4;

outDiameter = 1.6;
inDiameter = 4.2;

sides = 8;
size = 46;
outAngle = 90;

snapWidth = 12;
snapThickness = 1.5;
snapStickout = 1.25;
extraThickness = 3;
extraHeight = 2;

screwDiameter = 1.8;
screwOuterDiameter = 3;
screwPostWall = 1.5;

module snap(snapStickout=snapStickout,baseExtra=0,heightExtra=0) {
    height = wall + offsetFromBase + 2 * snapStickout;
    
    translate([0,snapWidth/2,0])
    rotate([90,0,0])
    linear_extrude(height=snapWidth)
    polygon([[-snapThickness-baseExtra,0],[0,0],[0,wall+offsetFromBase-snapStickout],[snapStickout,wall+offsetFromBase],[0,wall+offsetFromBase],[0,wall+offsetFromBase+pcbThickness],[snapStickout,wall+offsetFromBase+pcbThickness+snapStickout],[0,wall+offsetFromBase+pcbThickness+2*snapStickout],[0,wall+offsetFromBase+pcbThickness+2*snapStickout+heightExtra],[-snapThickness,wall+offsetFromBase+pcbThickness+2*snapStickout+heightExtra]]);
}

diameter = size / cos(180/sides);
adjWall = wall / cos(180/sides);
angle = 90+360/sides/2;

module box(height) {
    rotate(angle) {
    cylinder(d=diameter+adjWall*2,h=wall,$fn=sides);
    linear_extrude(height=height) {
        difference() {
            circle(d=diameter+adjWall*2,$fn=sides);
            circle(d=diameter,$fn=sides);
        }
    }
}
}

module hole(d) {
    l = size / 2;
    translate([0,size/2,bottomHeight-d/2-wall])
    rotate([90,0,0]) {
    translate([0,0,-l]) cylinder(d=d,h=2*l,$fn=36);
    translate([0,d/2+0.5+wall/2,0]) cube([d,d+wall+1,2*l],center=true);
    }
}

spd = screwDiameter+2*screwPostWall;
screwX = size/2-spd/2;

module bottom() {
    difference() {
        box(bottomHeight);
        rotate([0,0,outAngle/2]) hole(outDiameter);
        rotate([0,0,-outAngle/2]) hole(outDiameter);
        rotate([0,0,180]) hole(inDiameter);
    }
    translate([-snapSpacing/2,0,0]) snap();
    translate([snapSpacing/2,0,0]) rotate([0,0,180]) snap();
    translate([0,pcbLength/2,0]) rotate([0,0,-90]) snap(0,extraThickness,extraHeight);
    translate([0,-pcbLength/2,0]) rotate([0,0,90]) snap(0,extraThickness,extraHeight);
    for (angle=[0,180]) 
        rotate([0,0,angle]) {
        translate([screwX,0,0])
        linear_extrude(bottomHeight-wall) difference() {
            circle(d=spd,$fn=36);
            circle(d=screwDiameter,$fn=36);
        }
    }
}

module lid() {
    linear_extrude(height=wall)
    difference() {
        rotate(angle) circle(d=diameter-lidTolerance,$fn=sides);
        for (angle=[0,180]) 
            rotate(angle) {
            translate([screwX,0])
                circle(d=screwOuterDiameter,$fn=36);
        }
    }    
}

if (includeBox) bottom();
if (includeLid) translate([diameter+10,0,0]) lid();