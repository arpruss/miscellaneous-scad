use <roundedSquare.scad>;
use <hershey.scad>;

//<params>
pcbPortTolerance = 2;
pcbLengthTolerance = 0.8;
pcbRailTolerance = 0.2;
tolerance = 0.35;
driveLength = 144.44;
driveWidth = 100.5;
driveHeight = 24.92;
driveScrewFromBase = 4.9;
driveScrewsFromFront = [ 21.1, 80.88, 110.82 ];
forPrinting = 1; // 0:no, 1:yes
includeBase = 0; // 0:no, 1:yes
includeMain = 1; // 0:no, 1:yes
includeLogo = 1; // 0:no, 1:yes
pcbWidth = 22.55;
pcbLength = 53.43;
pcbThickness = 1.6;
pcbPortThickness = 3;
pcbPortWidth = 7.55;
pcbBackLeaveFree = 10;
pcbOffset = 3.5;
pcbBaseToDrive = 31;
pcbPillarStickout = 4;
pcbPillarThickness = 4;
pcbRailStickout = 2;
pcbRailThickness = 1.65;
pcbHolderExtraHeight = 14;
driveScrewDiameter = 3.91;
baseScrewDiameterInner = 2;
baseScrewDiameterOuter = 3.5;
baseScrewOffset = 5;
radius = 8;
sideWall = 2;
backWall = 2;
frontWall = 2;
ventLength = 10;
ventHeight = 5;
numberOfRearVents = 4;
numberOfSideVents = 6;
guideWidth = 5;
footDiameter = 10;
footHeight = 3.5;
//</params>

nudge = 0.01;


height = max(pcbWidth+pcbRailTolerance*2+pcbRailThickness*2+2*sideWall+2*tolerance,driveHeight+2*tolerance+2*radius);
width = driveWidth+2*tolerance;
length = driveLength + pcbBaseToDrive + pcbThickness + pcbOffset + backWall;

module profile(width,height,radius=radius,hollow=true) {
    difference() {
        roundedSquare([width+2*sideWall,height+2*sideWall],radius=radius+sideWall,center=true, $fn=64);
        if (hollow) roundedSquare([width,height],radius=radius,center=true, $fn=64);
    }
}

innerWidth = width-2*tolerance-2*sideWall;
innerHeight = height-2*tolerance-2*sideWall;

module outer(hollow=false) {
    profile(width, height, hollow=hollow);
}

module inner(hollow=true) {
    profile(innerWidth, innerHeight, radius=radius-tolerance-sideWall, hollow=hollow);
}

module pcbRail(sign) {
    startDelta = radius;
    xStart = innerWidth/2+sideWall-startDelta-pcbLengthTolerance;
    railHeight = backWall+pcbOffset+pcbThickness+pcbRailStickout;
    translate([xStart,-sign*(pcbWidth/2+pcbRailTolerance),0])
    rotate([0,0,180]) 
    rotate([0,90,0])
    rotate([0,0,90])
    linear_extrude(height=pcbLength-radius)
    polygon([
        [0,0],[sign*pcbRailThickness,0],[sign*pcbRailThickness,railHeight],[-sign*pcbRailStickout,railHeight],[0,railHeight-pcbRailStickout],[0,backWall+pcbOffset],[-sign*pcbRailStickout,backWall+pcbOffset]]);
    translate([xStart+startDelta-pcbPillarThickness-pcbLength,pcbBackLeaveFree/2*sign-(1-sign)/2*(pcbWidth-pcbBackLeaveFree)/2,0]) 
    cube([pcbPillarThickness,(pcbWidth-pcbBackLeaveFree)/2,pcbPillarStickout+pcbOffset+backWall+pcbThickness]);
}

module portCutout() {
    z = backWall+pcbOffset+pcbThickness+pcbPortThickness/2;
    mirror([1,0,0]) translate([width/2,0,z]) cube([10,pcbPortWidth+pcbPortTolerance*2,pcbPortThickness+2*pcbPortTolerance],center=true);
}

pcbHolderHeight = pcbOffset+pcbThickness+backWall + pcbHolderExtraHeight;

module bottomScrews(d) {
    $fn = 20;
    translate([0,0,pcbHolderHeight-baseScrewOffset]) {
        rotate([0,-90,0]) 
        cylinder(d=d,center=false,h=max(width,length)+10);
        rotate([0,0,90])
        rotate([0,90,0]) 
        cylinder(d=d,center=true,h=max(width,length)+10);
    }
}

module sideVent() {
    translate([width/2,height/2,0]) rotate([0,0,45]) cube([20, ventHeight, ventLength],center=true);
}

module sideVents() {
    for (i=[0:numberOfSideVents-1])
        translate([0,0,length/(numberOfSideVents+1)*(i+1)]) sideVent();
}

module bottomVents() {
    for (i=[0:numberOfRearVents-1])
        translate([-innerWidth/2+innerWidth/(numberOfRearVents+1)*(i+1),0,0]) square([ventLength,ventHeight],center=true);
}

module pcbHolder() {
    difference() {
        union() {
            linear_extrude(height=backWall) difference() {
                inner(hollow=false);
                bottomVents();
            }
            
            linear_extrude(height=pcbHolderHeight) difference() {
                inner(hollow=true);
                translate([innerWidth/2+sideWall/2,0]) square([radius*1.5+sideWall,pcbWidth+pcbRailThickness*2+pcbRailTolerance*2],center=true);
            }
            pcbRail(1);
            pcbRail(-1);
        }
        bottomScrews(baseScrewDiameterInner);
        sideVents();
        mirror([1,0,0]) sideVents();
    }
}

module driveScrews() {
    for (h=driveScrewsFromFront) translate([0,-driveHeight/2+driveScrewFromBase,length-h]) rotate([0,90,0]) cylinder(h=width*4,d=driveScrewDiameter,$fn=20,center=true);
}

module guide() {
    intersection() {
        translate([tolerance+nudge+driveWidth/2-guideWidth,-height/2,pcbHolderHeight]) cube([guideWidth,(height-driveHeight)/2-tolerance,length-pcbHolderHeight]);
        linear_extrude(height=length+nudge) outer(hollow=false);
    }
}

module frontWallProfile() {
    difference() {
        outer(hollow=false);
        square([driveWidth+2*tolerance,driveHeight+2*tolerance],center=true);
    }
}

module frontWall() {
    translate([0,0,length-frontWall]) linear_extrude(height=frontWall) frontWallProfile();
}

footOffset = footDiameter*1.5;

module foot() {
    translate([0,-height/2-footHeight+nudge,0]) 
    rotate([90,0,0])
    cylinder(d2=footDiameter,d1=footDiameter+2*footHeight,h=footHeight+nudge);
}

module feet() {
    translate([(driveWidth/2-footOffset),0,footOffset]) foot();
    translate([-(driveWidth/2-footOffset),0,footOffset]) foot();
    translate([(driveWidth/2-footOffset),0,length-footOffset]) foot();
    translate([-(driveWidth/2-footOffset),0,length-footOffset]) foot();
}

module label() {
    if (includeLogo)
    rotate([0,0,90])
drawHersheyText("GreaseWeazle", font="SerifItalic", valign="center", halign="center", size=14.5,extraSpacing=-1.5) cylinder(d1=4,d2=1,h=2,$fn=16);
}

module shell() {
        difference() {
            linear_extrude(height=length) outer(hollow=true);
            mirror([1,0,0]) bottomScrews(baseScrewDiameterOuter);
            portCutout();
            sideVents();
            driveScrews();
            mirror([1,0,0]) sideVents();
            
        }
        guide();
        mirror([1,0,0]) guide();
        frontWall();
        feet();
        translate([0,height/2+sideWall-nudge,length/2]) rotate([-90,0,0]) label();
}

if (includeBase) pcbHolder();

if (includeMain)    {
    translate([0,height+2*sideWall+5,0]) if (forPrinting) {
           translate([0,0,length])
        rotate([180,0,0]) 
     shell();
    }
    else shell();
    }