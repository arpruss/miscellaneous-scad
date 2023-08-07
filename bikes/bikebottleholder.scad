output = 0; // [0:Everything, 1:Bottom holder, 2:Top holder, 3:Joining strip]
joiningStripWidth = 25; 
joiningStripMinimumThickness = 1.5;
joiningStripHeight = 123; 
bottleDiameter = 66; 
bottomWallThickness = 1.7;
bottomHolderHeight = 45; 
topWallThickness = 2.25; 
topHolderHeight = 45; 
topHolderCinch = 6.5;
topSlit = 4;
bikeTubeDiameter =  35; //38.5; 
zipTieHoleHeight = 5.5;
zipTieHoleWidth = 2.5;
zipTieHeightAdjust = -8;
joiningStripHolderWidth = 3;
joiningStripHolderExtraThickness = 1;
tolerance = 0.4;
plasticSavingHoleHeightRatio = 0.65;
boltHoleDiameter = 6.2;
boltHoleCountersinkDiameter = 10;
boltHoleCountersinkDepth = 1.2;
boltHoleSpacing = 64;

module dummy() {}

nudge = 0.01;
$fn = 72;

boltHoleFromEnd = (joiningStripHeight - boltHoleSpacing) / 2;

joiningStripMaximumThickness = joiningStripMinimumThickness + bikeTubeDiameter/2 - sqrt(pow(bikeTubeDiameter/2,2)-pow(joiningStripWidth/2,2));

module joiningStrip() {
    difference() {
        translate([-joiningStripWidth/2,0,0]) cube([joiningStripWidth,joiningStripHeight,joiningStripMinimumThickness+bikeTubeDiameter*0.49]);
        translate([0,0,bikeTubeDiameter/2+joiningStripMinimumThickness]) rotate([90,0,0]) cylinder(d=bikeTubeDiameter,h=joiningStripHeight*3,center=true);
        for (s=[-1,1]) 
     translate([0,joiningStripHeight/2+s*(-joiningStripHeight/2+boltHoleFromEnd),0]) cylinder(d=boltHoleDiameter,h=20,center=true,$fn=12);
    }
        
}

module holder(bottleDiameter,wallThickness,height,baseThickness) {
    od = bottleDiameter+wallThickness*2;
    id = bottleDiameter;
    t = joiningStripMaximumThickness+joiningStripHolderExtraThickness;
    s = plasticSavingHoleHeightRatio * min(id,height);
    difference() {
        union() {
            translate([0,-joiningStripWidth/2-tolerance-joiningStripHolderWidth,0]) cube([od/2+t,joiningStripWidth+2*tolerance+joiningStripHolderWidth*2,height]);
            cylinder(h=height,d=od);
        }
        translate([0,0,baseThickness-nudge]) cylinder(h=height+2*nudge,d=id);
     translate([od/2+joiningStripHolderExtraThickness,-joiningStripWidth/2-tolerance,-nudge]) cube([t+nudge,joiningStripWidth+2*tolerance,height+2*nudge]);
        for (z=[height/3+zipTieHeightAdjust,height*2/3+zipTieHeightAdjust]) {
            translate([(id/2+(od/2+joiningStripHolderExtraThickness))/2-zipTieHoleWidth/2,-od/2,z-zipTieHoleHeight/2]) cube([zipTieHoleWidth,od,zipTieHoleHeight]);
        }
        if (baseThickness > 0) {
            translate([0,0,height/2]) rotate([90,0,0]) cylinder(d=s,h=2*od,$fn=4,center=true);
            translate([0,0,height/2]) rotate([0,-90,0]) cylinder(d=s,h=od,$fn=4);
            cylinder(d=s,h=height*2,$fn=4,center=true);
        }
        else {
            if (topSlit > 0)
            translate([-od/2-nudge,-topSlit/2,-nudge]) cube([od/2,topSlit,height+2*nudge]);
            translate([0,0,height]) rotate([0,-90,0]) cylinder(d=topSlit*4,h=od,$fn=4);
            rotate([0,-90,0]) cylinder(d=topSlit*4,h=od,$fn=4);
        }
        if (boltHoleDiameter) {
            translate([bottleDiameter/2+wallThickness,0,boltHoleFromEnd]) rotate([0,90,0]) cylinder(d=boltHoleDiameter,h=20,center=true);
            translate([bottleDiameter/2+boltHoleCountersinkDepth-10,0,boltHoleFromEnd]) rotate([0,90,0]) cylinder(d=boltHoleCountersinkDiameter,h=10,center=false);
        }
    }
}

render(convexity=2)
if (output == 0) {
    translate([0,-(5+bottleDiameter/2),0]) holder(bottleDiameter,bottomWallThickness,bottomHolderHeight,bottomWallThickness);
    translate([0,5+bottleDiameter/2,0]) holder(bottleDiameter-topHolderCinch,topWallThickness,topHolderHeight,0);
    translate([-bottleDiameter/2-10-joiningStripWidth/2,-joiningStripHeight/2,0]) joiningStrip();
}
else if (output == 1) {
    holder(bottleDiameter,bottomWallThickness,bottomHolderHeight,bottomWallThickness);
}
else if (output == 2) {
    holder(bottleDiameter-topHolderCinch,topWallThickness,topHolderHeight,0);
}
else if (output == 3) {
    rotate([0,0,-45]) joiningStrip();
}