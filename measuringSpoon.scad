use <Bezier.scad>;
use <ribbon.scad>;

wall = 1.25;
base = 1.75;
heightToDiameterRatio = 0.75;
volumeML = 236.588/4; 
handleLength = 100;
handleAngle = 45;
handleHeight = 23;
label = "1/4 cup";
fontThickness = 0.75;
fontSize = 8;

module dummy() {}

id = pow(volumeML*1000/(PI/4)/heightToDiameterRatio,1/3);
ih = id*heightToDiameterRatio;
$fn = 128;

difference() {
    cylinder(d=id+2*wall,h=ih+base);
    translate([0,0,base]) cylinder(d=id,h=ih+base);
    translate([0,0,-.01]) linear_extrude(height=fontThickness) mirror([1,0,0]) text(label,halign="center",valign="center",size=fontSize);
}

r = id/2+wall/2;
path = [ r*[cos(handleAngle),sin(handleAngle)], POLAR(r*0.5,handleAngle-90), POLAR(handleLength/2,180), [handleLength,0]];

intersection() {
    linear_extrude(height=handleHeight) { 
        ribbon(Bezier(path),thickness=wall);
        mirror([0,1]) ribbon(Bezier(path),thickness=wall);
    }
    hull() {
        translate([handleLength-handleHeight/sqrt(2),0,handleHeight/2]) sphere(d=handleHeight*sqrt(2));
        cube([id+wall*2,id*wall*2,handleHeight*2],center=true);
        
    }
}