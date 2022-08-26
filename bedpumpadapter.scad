wideDiameter = 19.6;
wideTaperPlus = 1.5;
wideTaperMinus = 1.5;
wideTaperLength = 15;

narrowDiameter = 7.43;
narrowTaperMinus = 0.7;
narrowTaperPlus = 0.7;
narrowTaperLength = 10;

jointLength = 20;

wall = 1.5;
wallTopAdjust = -0.5;

nudge = 0.001;
$fn = 64;

module taper(bottomDiameter, topDiameter, height, wall=wall, wallTopAdjust=0) {
    difference() {
        cylinder(d1=bottomDiameter,d2=topDiameter,h=height);
        translate([0,0,-nudge]) cylinder(d1=bottomDiameter-2*wall,d2=topDiameter-2*(wall+wallTopAdjust),h=height+2*nudge);
    }
}

taper(wideDiameter-wideTaperMinus, wideDiameter+wideTaperPlus, wideTaperLength);
translate([0,0,wideTaperLength-nudge]) taper(wideDiameter+wideTaperPlus,narrowDiameter+narrowTaperPlus, jointLength+2*nudge);
translate([0,0,wideTaperLength+jointLength]) taper(narrowDiameter+narrowTaperPlus, narrowDiameter-narrowTaperMinus, narrowTaperLength, wallTopAdjust=wallTopAdjust);
