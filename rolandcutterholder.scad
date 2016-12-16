use <ribbon.scad>;


width = 64.9;
height = 48;

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

cutterDiameter = cutterDesiredDiameter + cutterTolerance;
collarDiameter = collarDesiredDiameter + cutterTolerance;
collarThickness = collarDesiredThickness + collarVerticalTolerance;

widthAroundCollar = 7;

screwHoleDiameter = 2.9;
screwNutThickness = 2.8; // 2.3?
screwNutDesiredWidth = 5.33;
nutTolerance = 0.15;
screwNutWidth = screwNutDesiredWidth + nutTolerance;

screwAreaExtraThickness = 2;

screwAreaThickness = max(baseThickness, screwNutThickness+screwAreaExtraThickness);

nudge = 0.01;

module base() {
    render(convexity=7)
    difference() {
        union() {
            linear_extrude(height=baseThickness+nudge)
            square([width,height]);
            for (i=[0:len(holes)-1]) {
                translate(holes[i]) linear_extrude(height=screwAreaThickness) circle(d=screwNutThickness*4, $fn=16);
            }
        }
        for (i=[0:len(holes)-1]) {
            translate(holes[i]) {
                translate([0,0,-nudge]) cylinder(h=screwAreaThickness+2*nudge, d=screwHoleDiameter, $fn=16);
                translate([0,0,screwAreaThickness-screwNutThickness]) cylinder(h=screwNutThickness+nudge,d=screwNutWidth*2/sqrt(3),$fn=6);
            }
        } 
    }
}

holderWidth = widthAroundCollar*2+collarDiameter;
holderHeight = spaceBelowCollar+collarThickness+spaceAboveCollar;
widthAroundCutter = (holderWidth-cutterDiameter)/2;

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

edgeThickness = 2.5; // must exceed springThickness
springThickness = 1;
triangle_wallThickness = 1.5;
baseThickness = 2;

wave_fraction = 0.5;

tool_holderThickness = 2;
tool_holder_innerDiameter = 16;
tool_holderHeight = 15;

// if this is >0, the pen holes will need to be drilled through
mini_supportThickness = 0.4;


// M3
pen_screwHoleDiameter = 2.9;
pen_screwNutThickness = 2.8;
pen_screwNutDesiredWidth = 5.33;

//

module dummy() {}

pen_screwNutWidth = pen_screwNutDesiredWidth + nutTolerance;
base_screwNutWidth = base_screwNutDesiredWidth + nutTolerance;

triangleThickness = base_screwNutThickness+baseThickness;

tool_screw_headAreaExtraThickness = 1+0.5;

tool_holderWidth = tool_holder_innerDiameter+tool_holderThickness*2;

clearance_factor = 1.75;

h2 = tool_holder_innerDiameter + 2 * tool_holderThickness;
springWidth = h2 / sqrt(3)*1.5;


tool_screw_headArea = min(tool_holderHeight, max(tool_holder_innerDiameter*0.75,pen_screwNutWidth+4));//pen_screwNutWidth * 2 / sqrt(3)*1.5;

pi = 3.1415926535897932;
spring_length = (width - tool_holderWidth)/2;
amplitude = spring_length / (2*pi);
dh = (2+clearance_factor)*amplitude;

nudge = 0.001;

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
    if (reverse) {
    ribbon([for(i=[0:spring_points]) [spring_length*i/spring_points, amplitude*SIN(2*pi*wave_fraction-i*2*pi/spring_points*wave_fraction)]], thickness=thickness);       
    }
    else{
    ribbon([for(i=[0:spring_points]) [spring_length*i/spring_points, amplitude*SIN(i*2*pi/spring_points*wave_fraction)]], thickness=thickness);       
    }
}

triangles = [
[[edgeThickness*0.6,amplitude],[spring_length*.75, dh], [edgeThickness*0.6, 2*dh-amplitude]],
[[width-edgeThickness*0.6,amplitude],[width-spring_length*.75, dh], [width-edgeThickness*0.6, 2*dh-amplitude]],
[[edgeThickness*0.6,height-amplitude],[spring_length*.75, height-dh], [edgeThickness*0.6,height-( 2*dh-amplitude)]],
[[width-edgeThickness*0.6,height-amplitude],[width-spring_length*.75, height-dh], [width-edgeThickness*0.6, height-(2*dh-amplitude)]]
];

function sumTo(v,n) = n<0 ? [for (i=[0:len(v[0])]) 0] : v[n]+sumTo(v,n-1);
function sum(v,n) = sumTo(v,len(v)-1);
function center(points) = sum(points)/len(points);

triangleCenters0 = [for (i=[0:len(triangles)-1]) center(triangles[i])];
triangleCenters = [for (i=[0:len(triangles)-1]) [for (j=[0:1]) round(triangleCenters0[i][j])]];
echo("triangle centers", triangleCenters);

module ribbon_base() {
    translate([springThickness/2,amplitude]) {
        spring(spring_length, -amplitude);
        translate([width - spring_length-springThickness,0]) spring(spring_length, -amplitude, reverse=true);
    }

    translate([springThickness/2,height-amplitude,0]) {
        spring(spring_length, amplitude);
        translate([width - spring_length-springThickness,0]) spring(spring_length, amplitude, reverse=true);
    }
    
    for (i=[0:3]) ribbon(triangles[i], closed=true, thickness=triangle_wallThickness);

    polygon([[0,amplitude], [edgeThickness,amplitude-edgeThickness*.75*0], [edgeThickness,height-amplitude+edgeThickness*.75*0], [0,height-amplitude]]);
    
    polygon([[width,amplitude], [width-edgeThickness,amplitude-edgeThickness*.75*0], [width-edgeThickness,height-amplitude+edgeThickness*.75*0], [width,height-amplitude]]);
}

module springy_base() {
    bottom = [[springThickness/2,height/2+nudge],[springThickness/2,amplitude],[spring_length*.75,dh],[spring_length*.75,tool_holderHeight+1.25*amplitude],
    [width-spring_length*.75,tool_holderHeight+1.25*amplitude],
    [width-spring_length*.75,dh],[width-springThickness/2,amplitude],[width-springThickness/2,height/2+nudge]];
    
    top = [for (i=[0:len(bottom)-1]) [width,height]-bottom[i]];
    
    union() {
        polygon(bottom);
        polygon(top);
    }
}

module stretched_hexagon(h) {
    r = h / sqrt(3);
    points = [for(i=[0:5]) i == 4 ? [0,-r/2-r/2*sqrt(2)] : [r*cos(30+60*i),r*sin(30+60*i)]];
    polygon(points=points);
}

//holder_inside_apex_multiplier = (0.75+0.75*1/sqrt(3)*1/sqrt(2))/sqrt(3);
holder_inside_apex_multiplier = 1/sqrt(2);
 
module holder_inside(h) {
    r = h / sqrt(3);
    p1 = [for(i=[0:2]) [r*cos(30+60*i),r*sin(30+60*i)]]; // angles 30->150
    p2 = [for(i=[180:5:180+45]) [h/2*cos(i),h/2*sin(i)]];
    p3 = [[0,-h * holder_inside_apex_multiplier]];
    p4 = [for(i=[-45:5:0]) [h/2*cos(i),h/2*sin(i)]];
    polygon(points=concat(concat(concat(p1,p2),p3),p4));
    
}
 
 module outer_hexagon(h) {
    r = h / sqrt(3);
    points = [for(i=[0:5]) i == 4 ? [0,-r/2-r/2*sqrt(2)] : [r*cos(30+60*i),(i==0 || i==2) ? r : r*sin(30+60*i)]];
    polygon(points=points);
}
 
 module tool_holder() {
     h2 = tool_holder_innerDiameter+2*tool_holderThickness;
     
     outsideTopZ = h2 / sqrt(3) * (1 + 1/2 + sqrt(2)/2 ) + 1.5;
     
     insideTopZ = h2 / sqrt(3)+holder_inside_apex_multiplier*tool_holder_innerDiameter;
     
     centerZ = h2 / sqrt(3);
    
     render(convexity=8) 
     difference() {
         union() {
             translate([width/2,0,0])
             rotate([-90,0,0])
             linear_extrude(height=tool_holderHeight)
             translate([0, -h2  / sqrt(3)]) 
                 outer_hexagon(h2);
    translate([width/2,tool_holderHeight/2,centerZ]) cylinder(d=tool_screw_headArea, h=outsideTopZ-centerZ, $fn=20); 
         }

         translate([width/2,-nudge,0])
         rotate([-90,0,0])
         linear_extrude(height=tool_holderHeight+2*nudge)
         translate([0, -h2  / sqrt(3)])
             holder_inside(tool_holder_innerDiameter);

         translate([width/2,tool_holderHeight/2,centerZ]) cylinder(d=pen_screwHoleDiameter, h=outsideTopZ-centerZ+nudge, $fn=16);
         translate([width/2,tool_holderHeight/2,centerZ]) cylinder(d=(pen_screwNutWidth*2/sqrt(3)), h=pen_screwNutThickness+(insideTopZ-centerZ), $fn=6);
     }
         if (mini_supportThickness>0) {
                      translate([width/2,tool_holderHeight/2,pen_screwNutThickness+insideTopZ])
         cylinder(d=pen_screwHoleDiameter+2*nudge, h=mini_supportThickness+nudge, $fn=12);
         }
 }

module base_holes() {
    render(convexity=10)
    union() {
        for (i=[0:len(triangleCenters)-1]) {
         translate(0,0,-nudge) linear_extrude(height=10+triangleThickness+2*nudge) translate(triangleCenters[i]) circle(d=base_screwHoleDiameter, $fn=12);
            translate([0,0,triangleThickness-base_screwNutThickness])
         linear_extrude(height=base_screwNutThickness+nudge) translate(triangleCenters[i]) circle(d=base_screwNutWidth*2/sqrt(3), $fn=6);
    }
}
}
 
module full_holder() {
    linear_extrude(height=springWidth) ribbon_base();
    difference() {
        union() {
            linear_extrude(height=baseThickness) base();
            linear_extrude(height=triangleThickness) {
                for(i=[0:3]) polygon(triangles[i]);
             }
         }
         base_holes();
     }
     
     tool_holder();
     translate([0,height-tool_holderHeight,0]) tool_holder();
}
 

baseWithHolder();