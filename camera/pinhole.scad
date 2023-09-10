*mainCircle = 89;
filmWidth = 59;
filmLength = 61;
withHole = true;
tapeLength = 35;
tapeWidth = 8;
fingerHole = 15;

$fn = 128;

module filmPlane(hole=true) {
    difference() {
        circle(d=mainCircle);
        if (hole) {
            //hull() 
            {
                square([filmLength,filmWidth],center=true);
                square([filmLength+2*tapeWidth,tapeLength],center=true);
            }
        }
        for (y=[mainCircle/2,-mainCircle/2])
            translate([0,y]) circle(d=fingerHole);
    }
}

filmPlane(true);
translate([mainCircle+4,0]) 
filmPlane(false);
