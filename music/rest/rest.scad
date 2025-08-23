use <roundedsquare.scad>;
use <laserTeeth.scad>;

//<params>
item = 7; // 0: laser back, 1: laser half back, 2: 3D print tray, 3: bottom clip, 4: top clip, 5: laser shelf, 6: laser half joints, 7: laser half shelf
flip = 1; //0:no, 1:yes

holeSpacing = 525;

height = 230;
rounding = 20;
innerRounding = 10;
bottomExtra = 10;
shelfThickness = 2.5;
shelfFront = 26;
shelfSupports = 3;
shelfExtraAngle = 8;

divider = 20;


wireSize = 4.85;
wireTolerance = .08;
clipMinimumPlastic = 1.75;
clipScrewDiameter = 3.9;
clipScrewLength = 12.5;
clipScrewOffset = 3;
clipScrewPlasticExtra = 0.5;
clipClosureSize = 1.5;
clipScrewWoodThickness = 0.5;

woodThickness = 6.1;
numTeeth = 8;
kerf = .1;
vmargin = 15;
stripHeight = 10;
bigHoles = 3;
//</params>

module dummy() {}

nudge = 0.01;

wireHoleV = wireSize+wireTolerance;
wireHoleH = wireSize+2*wireTolerance;
clipHeight = clipScrewDiameter+2*clipScrewOffset;
clipWidth = wireHoleH+2*clipScrewDiameter+2*clipScrewOffset+2*clipScrewPlasticExtra;

beyondHoles = clipWidth / 2;
hmargin = clipWidth;
width = holeSpacing+2*beyondHoles;

echo(width,height);


$fn = 128;

module back() {
    h = height-2*vmargin;
    //(h1+stripHeight) * bigHoles = h+stripHeight;
    h1 = (h+stripHeight)/bigHoles-stripHeight;
	difference() {
		hull() {
			translate([0,-bottomExtra]) square(10);
			translate([width-10,-bottomExtra]) square(10);
			translate([rounding,height-rounding]) circle(rounding);
			translate([width-rounding,height-rounding]) circle(rounding);
		}
        for (i=[0:bigHoles-1]) {
            translate([hmargin,vmargin+(h1+stripHeight)*i]) roundedSquare([width-2*hmargin,h1],radius=innerRounding);
        }
	}
    hull() {
        translate([hmargin,height-vmargin-stripHeight/2]) circle(d=stripHeight+.01);
        translate([width/2,vmargin-stripHeight/2]) circle(d=stripHeight+.01);
    }
    hull() {
        translate([width-hmargin,height-vmargin-stripHeight/2]) circle(d=stripHeight+.01);
        translate([width/2,vmargin-stripHeight/2]) circle(d=stripHeight+.01);
    }
}

module shelfHalf() {
    cube([width/2,bottomExtra+vmargin,shelfThickness]);
    hull() {
        translate([0,bottomExtra,0]) cube([width/2,shelfThickness,shelfFront]);
        translate([0,bottomExtra,0]) rotate([-shelfExtraAngle,0,0]) cube([width/2,shelfThickness,shelfFront]);
    }
        
    for (i=[0:shelfSupports-1])
        translate([(width/2-shelfThickness)/(shelfSupports-1)*i,0,0]) hull() {
            cube([shelfThickness,bottomExtra+shelfThickness,shelfThickness]);
            translate([0,bottomExtra,0]) cube([shelfThickness,shelfThickness,shelfFront]);
        }
}


module laserBack() {
    difference() {
        back();
        toothSockets(thickness=woodThickness,length=width,numTeeth=numTeeth,kerf=kerf);
    }
}

module clip(closed=false) {
    clipThickness = max(clipMinimumPlastic+wireHoleV, clipScrewWoodThickness+clipScrewLength-woodThickness);
    
    rotate([180,0,0]) 
    difference() {
        linear_extrude(height=clipThickness) {
            difference() {
                hull() {
                for(s=[-1,1]) translate([s*(wireHoleH/2+clipScrewDiameter/2+clipScrewPlasticExtra),0]) circle(r=clipScrewDiameter/2+clipScrewOffset);
                }
                for(s=[-1,1]) translate([s*(wireHoleH/2+clipScrewDiameter/2+clipScrewPlasticExtra),0]) circle(r=clipScrewDiameter/2);
                }
            }
        
        rotate([90,0,0]) translate([0,0,-clipHeight/2+(closed?clipClosureSize:-nudge)]) linear_extrude(height=3*clipThickness) hull() {
            translate([0,wireHoleV/2]) scale([wireHoleH/wireSize,wireHoleV/wireSize])  circle(d=wireSize);
            translate([-wireHoleH/2,-nudge]) square([wireHoleH,wireHoleV/2]);
        }
            
    }
    
}

module laserShelf() {
    square([width,shelfFront]);
    teeth(thickness=woodThickness,length=width,numTeeth=numTeeth,kerf=kerf);
}

mirror([flip?1:0,0]) {
    if (item == 0) {
        laserBack();
    }
    else if (item == 1) {
        intersection() {
            laserBack();
            translate([0,-bottomExtra]) square([width/2,height+bottomExtra]);
        }
        translate([width/2-divider/2,0]) square([divider/2,height]);
    }
    else if (item == 2) {
        shelfHalf();
    }
    else if (item == 3) {
        clip(closed=false);
    }
    else if (item == 4) {
        clip(closed=true);
    }
    else if (item == 5) {
        echo("ls");
            laserShelf();
    }
    else if (item == 6) {
    //    square([width/2,bottomExtra+vmargin]);
        //translate([0,bottomExtra+vmargin+5]) 
        square([height-vmargin*2,divider]);
        translate([0,-vmargin-5]) square([width/2,vmargin]);
    }
    else if (item == 7) {
        intersection(){
            translate([0,-50]) square([width/2,shelfFront+woodThickness+100]);
            translate([0,-bottomExtra-5-shelfFront]) laserShelf();
        }
    }
}