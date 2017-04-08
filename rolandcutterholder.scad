width = 64.9;
cornerSnip = 5.7;

holes = [[7,13],[58,13],[7,35],[58,35]];

baseThickness = 3;
cutterDesiredDiameter = 11.5;
collarDesiredDiameter = 15.85;
collarDesiredThickness = 2;
spaceAboveCollar = 4.75;
spaceBelowCollar = 15;
collarToSpring = 23;

collarVerticalTolerance = 0.5;
cutterTolerance = 0.25;

widthAroundCollar = 7;

screwHoleDiameter = 2.9;
screwNutThickness = 2.8; // 2.3?
screwNutDesiredWidth = 5.33;
nutTolerance = 0.08;
pinDiameter = 2.93;

screwAreaExtraThickness = 2;
springThickness = 1;
springWidth = 17;

strapTightness = 1;
strapThickness = 1.5;
strapFlangeThickness = 2;

wave_fraction = 0.5;

springSupportThickness = 2;

capTaperStart = 2+7.75;

includeHolder = 1; // [0:no, 1:yes]
includeStrap = 1; // [0:no, 1:yes]
includeCap = 1; // [0:no, 1:yes]

module dummy() {}

cutterDiameter = cutterDesiredDiameter + cutterTolerance;
collarDiameter = collarDesiredDiameter + cutterTolerance;
collarThickness = collarDesiredThickness + collarVerticalTolerance;

pinAreaWidth = pinDiameter+springThickness;
screwNutWidth = screwNutDesiredWidth + 2*nutTolerance;
holderWidth = widthAroundCollar*2+collarDiameter;
holderHeight = spaceBelowCollar+collarThickness+spaceAboveCollar;
widthAroundCutter = (holderWidth-cutterDiameter)/2;

springY = spaceBelowCollar + collarThickness + collarToSpring + springThickness/2 - springThickness/2;

height = springY - springThickness;

pi = 3.1415926535897932;
amplitude = springWidth / (2*pi);


screwAreaThickness = max(baseThickness, screwNutThickness+screwAreaExtraThickness);

nudge = 0.01;

module base() {
            linear_extrude(height=baseThickness+nudge)
            square([width,height]);
            for (i=[0:len(holes)-1]) {
                translate(holes[i]) linear_extrude(height=screwAreaThickness) circle(d=screwNutThickness*4, $fn=16);
            }
}

module baseScrewHoles() {
    for (i=[0:len(holes)-1]) {
        translate(holes[i]) {
            translate([0,0,-nudge]) cylinder(h=screwAreaThickness+2*nudge+100, d=screwHoleDiameter, $fn=16);
            translate([0,0,screwAreaThickness-screwNutThickness]) cylinder(h=screwNutThickness+nudge+100,d=screwNutWidth*2/sqrt(3),$fn=6);
        }
    } 
}

module cutterHolder() {
    render(convexity=6)
    translate([width/2-holderWidth/2,0,baseThickness]) {
        difference() {
            linear_extrude(height=collarDiameter/2) square([holderWidth,holderHeight]);
            translate([holderWidth/2,0,collarDiameter/2]) rotate([-90,0,0]) translate([0,0,-nudge]) {
               cylinder(d=cutterDiameter, h=holderHeight+2*nudge);
               translate([0,0,spaceBelowCollar]) cylinder(d=collarDiameter, h=collarThickness);
            }
        }
    }
}

module screwAndNut() {
    cylinder(d=screwHoleDiameter,h=holderHeight+    baseThickness+2*nudge,$fn=16);
    cylinder(d=screwNutWidth*2/sqrt(3),h=baseThickness+screwNutThickness+nudge,$fn=6);
}

module baseWithHolder() {
    difference() {
        union() {
            base();
            cutterHolder();
        }
        translate([width/2-holderWidth/2+widthAroundCutter/2,spaceBelowCollar/2,-nudge]) screwAndNut();
            translate([width/2+holderWidth/2-widthAroundCutter/2,spaceBelowCollar/2,-nudge]) screwAndNut();
    }
}

module ribbon(points, thickness=1, closed=false) {
    p = closed ? concat(points, [points[0]]) : points;
    
    union() {
        for (i=[1:len(p)-1]) {
            hull() {
                translate(p[i-1]) circle(d=thickness, $fn=8);
                translate(p[i]) circle(d=thickness, $fn=8);
            }
        }
    }
}

function SIN(theta) = sin(theta * 180 / pi);
function COS(theta) = cos(theta * 180 / pi);
function TAN(theta) = tan(theta * 180 / pi);

module spring(spring_length, amplitude, thickness=springThickness, spring_points=20, reverse=false) {
    render(convexity=4)
    if (reverse) {
    ribbon([for(i=[0:spring_points]) [spring_length*i/spring_points, amplitude*SIN(2*pi*wave_fraction-i*2*pi/spring_points*wave_fraction)]], thickness=thickness);       
    }
    else{
    ribbon([for(i=[0:spring_points]) [spring_length*i/spring_points, amplitude*SIN(i*2*pi/spring_points*wave_fraction)]], thickness=thickness);       
    }
}

springX = width/2-pinAreaWidth/2-springWidth;
echo(springY);
springBreadth = 2*baseThickness+collarDiameter;

module springs() {
    triangle1 = [[springSupportThickness/2,springY-springX*.75], [springX,springY], [springSupportThickness/2,springY+springX*.75]];
    triangle2 = [for (i=[0:2]) [width-triangle1[i][0],triangle1[i][1]]];
    
    echo(springWidth);
    echo(amplitude);
    linear_extrude(height=springBreadth) {
        translate([springX,springY])
        spring(springWidth,amplitude);
        translate([width-springX-springWidth,springY])
        spring(springWidth,amplitude);
        translate([width/2-pinAreaWidth/2,springY])
        spring(pinAreaWidth,springThickness);
        ribbon(triangle1,thickness=springSupportThickness,closed=true);
        ribbon(triangle2,thickness=springSupportThickness,closed=true);
    }
    linear_extrude(height=springBreadth) {
        polygon(points=triangle1);
        polygon(points=triangle2);
    }
}

module strap() {
    outerDiameter = cutterDiameter+2*strapTightness+2*strapThickness;
    render(convexity=5)
    translate([0,-strapThickness,0])
    difference() {
        union() {
            cylinder(d=outerDiameter, h=spaceBelowCollar);
            translate([-widthAroundCollar-collarDiameter/2,strapThickness,0]) cube([widthAroundCollar*2+collarDiameter,strapFlangeThickness,spaceBelowCollar]);
        }
        translate([0,0,-nudge]) {
            cylinder(d=cutterDiameter+2*strapTightness, h=spaceBelowCollar+2*nudge);
            translate([0,-outerDiameter/2+strapThickness,spaceBelowCollar/2]) cube([outerDiameter+2*nudge,outerDiameter,spaceBelowCollar+4*nudge], center=true);
        }
   
    for (s=[-1:2:1]) {
        translate([s*(cutterDiameter/2+0.5*widthAroundCutter),strapThickness-nudge,spaceBelowCollar*0.5]) rotate([-90,0,0]) rotate([0,0,22.5]) cylinder(d=screwHoleDiameter,h=strapFlangeThickness+2*nudge,$fn=8);
    }
}
}

module mainCutterHolder() {
    render(convexity=10) {
        difference() {
            union() {
                baseWithHolder();
                springs();
            }
            baseScrewHoles();
            translate([-nudge,-nudge,-nudge]) linear_extrude(height=baseThickness+2*nudge) polygon([[0,0],[cornerSnip+nudge,0],[0,cornerSnip+nudge]]);
            translate([width+nudge,-nudge,-nudge]) linear_extrude(height=baseThickness+2*nudge) polygon([[0,0],[-cornerSnip-nudge,0],[0,cornerSnip+nudge]]);
            
        }
        
    }
}

module spike(diameter,cylinderHeight,finalDiameter=0,ratio=0.75) {
    cylinder(h=cylinderHeight+nudge,d=diameter);
    translate([0,0,cylinderHeight]) cylinder(h=diameter/2/ratio,d1=diameter,d2=finalDiameter);
}

module ring(inner,outer,height) {
    render(convexity=3)
    difference() {
        cylinder(h=height,d=outer);
        translate([0,0,-nudge]) cylinder(h=height+2*nudge,d=inner);
    }
}

module cap() {
    render(convexity=8)
    difference() {
        union() {
            difference() {
                spike(cutterDesiredDiameter+4,capTaperStart+1,finalDiameter=3);
                translate([0,0,-nudge]) spike(cutterDesiredDiameter+2,capTaperStart+1);
            }
            ring(cutterDesiredDiameter,cutterDesiredDiameter+3,1);
        }
        translate([-cutterDesiredDiameter/2-2,-1.5/2,0]) cube([cutterDesiredDiameter+4,1.5,capTaperStart*0.7]);
    }
}

if (includeHolder) {
    mainCutterHolder();
}

if (includeStrap) {
    translate([width/2,-5,0]) rotate([0,0,180])
    strap();
}

if (includeCap) {
    translate([0,-cutterDiameter/2-8,0]) cap();
}
