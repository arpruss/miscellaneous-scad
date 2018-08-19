strapWidth = 25; 
strapMinimumThickness = 1.5;
strapHeight = 123; 
bottleDiameter = 64; 
bottomWallThickness = 1.25;
bottomHolderHeight = 45; 
topWallThickness = 1.75;
topHolderHeight = 45; 
topHolderCinch = 6;
topSlit = 4;
bikeTubeDiameter = 46; 
zipTieHoleHeight = 4;
zipTieHoleWidth = 2;
strapHolderWidth = 3;
strapHolderExtraThickness = 1;
tolerance = 0.2;
plasticSavingHoleHeightRatio = 0.72;

module dummy() {}

nudge = 0.01;
$fn = 72;

strapMaximumThickness = strapMinimumThickness + bikeTubeDiameter/2 - sqrt(pow(bikeTubeDiameter/2,2)-pow(strapWidth/2,2));

module strap() {
    difference() {
        translate([-strapWidth/2,0,0]) cube([strapWidth,strapHeight,strapMinimumThickness+bikeTubeDiameter*0.49]);
        translate([0,0,bikeTubeDiameter/2+strapMinimumThickness]) rotate([90,0,0]) cylinder(d=bikeTubeDiameter,h=strapHeight*3,center=true);
    }
        
}

module holder(bottleDiameter,wallThickness,height,baseThickness) {
    od = bottleDiameter+wallThickness*2;
    id = bottleDiameter;
    t = strapMaximumThickness+strapHolderExtraThickness;
    s = plasticSavingHoleHeightRatio * min(id,height);
    difference() {
        union() {
            translate([0,-strapWidth/2-tolerance-strapHolderWidth,0]) cube([od/2+t,strapWidth+2*tolerance+strapHolderWidth*2,height]);
            cylinder(h=height,d=od);
        }
        translate([0,0,baseThickness-nudge]) cylinder(h=height+2*nudge,d=id);
     translate([od/2+strapHolderExtraThickness,-strapWidth/2-tolerance,-nudge]) cube([t+nudge,strapWidth+2*tolerance,height+2*nudge]);
        for (z=[height/3,height*2/3]) {
            translate([(id/2+(od/2+strapHolderExtraThickness))/2-zipTieHoleWidth/2,-od/2,z-zipTieHoleHeight/2]) cube([zipTieHoleWidth,od,zipTieHoleHeight]);
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
    }
}

translate([0,-(5+bottleDiameter/2),0]) holder(bottleDiameter,bottomWallThickness,bottomHolderHeight,bottomWallThickness);
translate([0,5+bottleDiameter/2,0]) holder(bottleDiameter-topHolderCinch,topWallThickness,topHolderHeight,0);
translate([-bottleDiameter/2-10-strapWidth/2,-strapHeight/2,0]) strap();