include <mpcnctoolprofile.scad>;

//<params>
includeHolder = 1; // [0:no, 1:yes]
includeHolderAttachment = 1; // [0:no, 1:yes]
includeStrap = 1; // [0:no, 1:yes]
includeCap = 1; // [0:no, 1:yes]

width = 60; 

joiningScrewDiameter = 2.2;
joiningScrewDepth = 8;

mpcncProfileMinimumThickness = 5;

baseThickness = 3.5;
cutterDesiredDiameter = 11.5;
collarDesiredDiameter = 15.85;
collarDesiredThickness = 2;
spaceAboveCollar = 4.75;
spaceBelowCollar = 15;
collarToSpring = 23;

collarVerticalTolerance = 0.5;
cutterTolerance = 0.25;

widthAroundCollar = 7;

collarScrewHoleDiameter = 3.4;
collarScrewNutThickness = 2.8; 
collarScrewNutWidth = 5.33;
nutTolerance = 0.15;

mpcncToolMountDiameter = 6;
mpcncScrewHead = 9;

screwTolerance = 0.1;

pinDiameter = 2.93;

springThickness = 1;
springWidth = 17;

strapTightness = 1;
strapThickness = 1.5;
strapFlangeThickness = 2;

wave_fraction = 0.5;

springSupportThickness = 2;

capTaperStart = 9.75;
//</params>

module dummy() {}

cutterDiameter = cutterDesiredDiameter + cutterTolerance;
collarDiameter = collarDesiredDiameter + cutterTolerance;
collarThickness = collarDesiredThickness + collarVerticalTolerance;

pinAreaWidth = pinDiameter+springThickness;
holderWidth = widthAroundCollar*2+collarDiameter;
holderHeight = spaceBelowCollar+collarThickness+spaceAboveCollar;
widthAroundCutter = (holderWidth-cutterDiameter)/2;

springY = spaceBelowCollar + collarThickness + collarToSpring + springThickness/2 - springThickness/2;

height = springY - springThickness;

pi = 3.1415926535897932;
amplitude = springWidth / (2*pi);

nudge = 0.01;

module base() {
            linear_extrude(height=baseThickness+nudge)
            square([width,height]);
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
    translate([0,0,-100]) {
        cylinder(d=collarScrewHoleDiameter,h=holderHeight+    baseThickness+2*nudge+100,$fn=16);
        cylinder(d=(collarScrewNutWidth+nutTolerance)*2/sqrt(3),h=baseThickness+collarScrewNutThickness+nudge+100,$fn=6);
        cylinder(d=(collarScrewNutWidth+1)*2/sqrt(3),h=100+2*nudge,$fn=6);
    }
}

module baseWithHolder() {
    base();
    cutterHolder();
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

module springs(height=springBreadth,trianglesOnly=false) {
    triangle1 = [[springSupportThickness/2,springY-springX*.75], [springX,springY], [springSupportThickness/2,springY+springX*.75]];
    triangle2 = [for (i=[0:2]) [width-triangle1[i][0],triangle1[i][1]]];
    
    linear_extrude(height=height) {
        if (!trianglesOnly) {
            translate([springX,springY])
            spring(springWidth,amplitude);
            translate([width-springX-springWidth,springY])
            spring(springWidth,amplitude);
            translate([width/2-pinAreaWidth/2,springY])
            spring(pinAreaWidth,springThickness);
        }
        ribbon(triangle1,thickness=springSupportThickness,closed=true);
        ribbon(triangle2,thickness=springSupportThickness,closed=true);
    }
    linear_extrude(height=height) {
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
        translate([s*(cutterDiameter/2+0.5*widthAroundCutter),strapThickness-nudge,spaceBelowCollar*0.5]) rotate([-90,0,0]) rotate([0,0,22.5]) cylinder(d=collarScrewHoleDiameter,h=strapFlangeThickness+2*nudge,$fn=8);
    }
}
}

module mainCutterHolder(top=true,bottom=true) {    
    render(convexity=10) {
        difference() {
            union() {
                if (bottom)
                intersection() {
                    translate([width/2,0,nudge-mpcncProfileMinimumThickness])
                    rotate([-90,0,0])
                    linear_extrude(height=height+100) drawMPCNCToolProfile(minimumThickness=mpcncProfileMinimumThickness,base=width);
                    union() {
                        translate([0,0,-50]) {
                            cube([width,height+nudge,100]);
                            springs(height=50,trianglesOnly=true);
                        }
                    }
                    
                }
                if (top) {
                    baseWithHolder();
                    springs();
                }
            }
            translate([width-joiningScrewDiameter*1.5,mpcncFirstScrewHeight+mpcncScrewVerticalSpacing/2,-joiningScrewDepth]) cylinder(d=joiningScrewDiameter+2*screwTolerance,h=100,$fn=16);
            translate([joiningScrewDiameter*1.5,mpcncFirstScrewHeight+mpcncScrewVerticalSpacing/2,-joiningScrewDepth]) cylinder(d=joiningScrewDiameter+2*screwTolerance,h=100,$fn=16);
            translate([width/2-holderWidth/2+widthAroundCutter/2,spaceBelowCollar/2,-nudge]) screwAndNut();
                translate([width/2+holderWidth/2-widthAroundCutter/2,spaceBelowCollar/2,-nudge]) screwAndNut();
            translate([width/2,0,0])
            for (s=[0,1]) {
                mirror([s,0,0])
                for (y=[mpcncFirstScrewHeight,mpcncFirstScrewHeight+mpcncScrewVerticalSpacing]) {
                    translate([mpcncRightScrewCoordinates[0],y,-mpcncRightScrewCoordinates[1]-mpcncProfileMinimumThickness-nudge]) rotate([0,mpcncScrewInwardTiltAngle,0]) {
                        cylinder(d=mpcncScrewDiameter,h=100,$fn=16);
                        translate([0,0,mpcncRightScrewCoordinates[1]+mpcncProfileMinimumThickness+baseThickness-1]) cylinder(d=mpcncScrewHead,h=100,$fn=16);
                    }
                }
            }
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
    render(convexity=5)
    mainCutterHolder(top=true,bottom=false);
}

if (includeHolderAttachment) {
    translate([width+10,0,0]) 
    render(convexity=5)
    translate([width,0,0])
    rotate([0,180,0])
    mainCutterHolder(top=false,bottom=true);
}

if (includeStrap) {
    translate([width/2,-5,0]) rotate([0,0,180])
    strap();
}

if (includeCap) {
    translate([width,0,0]) 
    translate([0,-cutterDiameter/2-8,0]) cap();
}
