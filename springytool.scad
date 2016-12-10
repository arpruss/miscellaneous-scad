use <ribbon.scad>;

width = 64.9;
height = 48;
edge_thickness = 2.5; // must exceed spring_thickness
spring_thickness = 1;
triangle_wall_thickness = 1.5;
base_thickness = 2;

wave_fraction = 0.5;

tool_holder_thickness = 2;
tool_holder_inner_diameter = 16;
tool_holder_height = 15;

// if this is >0, the pen holes will need to be drilled through
mini_support_thickness = 0.4;

nut_tolerance = 0.3;

// M3
pen_screw_hole_diameter = 2.9;
pen_screw_nut_thickness = 2.8;
pen_screw_nut_desired_width = 5.33;

//
base_screw_hole_diameter = 2.9;
base_screw_nut_thickness = 2.8; // 2.3?
base_screw_nut_desired_width = 5.33;

module dummy() {}

pen_screw_nut_width = pen_screw_nut_desired_width + nut_tolerance;
base_screw_nut_width = base_screw_nut_desired_width + nut_tolerance;

triangle_thickness = base_screw_nut_thickness+base_thickness;

tool_screw_head_area_extra_thickness = 1+0.5;

tool_holder_width = tool_holder_inner_diameter+tool_holder_thickness*2;

clearance_factor = 1.75;

h2 = tool_holder_inner_diameter + 2 * tool_holder_thickness;
spring_width = h2 / sqrt(3)*1.5;


tool_screw_head_area = min(tool_holder_height, max(tool_holder_inner_diameter*0.75,pen_screw_nut_width+4));//pen_screw_nut_width * 2 / sqrt(3)*1.5;

pi = 3.1415926535897932;
spring_length = (width - tool_holder_width)/2;
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

module spring(spring_length, amplitude, thickness=spring_thickness, spring_points=20, reverse=false) {
    if (reverse) {
    ribbon([for(i=[0:spring_points]) [spring_length*i/spring_points, amplitude*SIN(2*pi*wave_fraction-i*2*pi/spring_points*wave_fraction)]], thickness=thickness);       
    }
    else{
    ribbon([for(i=[0:spring_points]) [spring_length*i/spring_points, amplitude*SIN(i*2*pi/spring_points*wave_fraction)]], thickness=thickness);       
    }
}

triangles = [
[[edge_thickness*0.6,amplitude],[spring_length*.75, dh], [edge_thickness*0.6, 2*dh-amplitude]],
[[width-edge_thickness*0.6,amplitude],[width-spring_length*.75, dh], [width-edge_thickness*0.6, 2*dh-amplitude]],
[[edge_thickness*0.6,height-amplitude],[spring_length*.75, height-dh], [edge_thickness*0.6,height-( 2*dh-amplitude)]],
[[width-edge_thickness*0.6,height-amplitude],[width-spring_length*.75, height-dh], [width-edge_thickness*0.6, height-(2*dh-amplitude)]]
];

function sumTo(v,n) = n<0 ? [for (i=[0:len(v[0])]) 0] : v[n]+sumTo(v,n-1);
function sum(v,n) = sumTo(v,len(v)-1);
function center(points) = sum(points)/len(points);

triangleCenters0 = [for (i=[0:len(triangles)-1]) center(triangles[i])];
triangleCenters = [for (i=[0:len(triangles)-1]) [for (j=[0:1]) round(triangleCenters0[i][j])]];
echo("triangle centers", triangleCenters);

module ribbon_base() {
    translate([spring_thickness/2,amplitude]) {
        spring(spring_length, -amplitude);
        translate([width - spring_length-spring_thickness,0]) spring(spring_length, -amplitude, reverse=true);
    }

    translate([spring_thickness/2,height-amplitude,0]) {
        spring(spring_length, amplitude);
        translate([width - spring_length-spring_thickness,0]) spring(spring_length, amplitude, reverse=true);
    }
    
    for (i=[0:3]) ribbon(triangles[i], closed=true, thickness=triangle_wall_thickness);

    polygon([[0,amplitude], [edge_thickness,amplitude-edge_thickness*.75*0], [edge_thickness,height-amplitude+edge_thickness*.75*0], [0,height-amplitude]]);
    
    polygon([[width,amplitude], [width-edge_thickness,amplitude-edge_thickness*.75*0], [width-edge_thickness,height-amplitude+edge_thickness*.75*0], [width,height-amplitude]]);
}

module base() {
    bottom = [[spring_thickness/2,height/2+nudge],[spring_thickness/2,amplitude],[spring_length*.75,dh],[spring_length*.75,tool_holder_height+1.25*amplitude],
    [width-spring_length*.75,tool_holder_height+1.25*amplitude],
    [width-spring_length*.75,dh],[width-spring_thickness/2,amplitude],[width-spring_thickness/2,height/2+nudge]];
    
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
     h2 = tool_holder_inner_diameter+2*tool_holder_thickness;
     
     outsideTopZ = h2 / sqrt(3) * (1 + 1/2 + sqrt(2)/2 ) + 1.5;
     
     insideTopZ = h2 / sqrt(3)+holder_inside_apex_multiplier*tool_holder_inner_diameter;
     
     centerZ = h2 / sqrt(3);
    
     render(convexity=8) 
     difference() {
         union() {
             translate([width/2,0,0])
             rotate([-90,0,0])
             linear_extrude(height=tool_holder_height)
             translate([0, -h2  / sqrt(3)]) 
                 outer_hexagon(h2);
    translate([width/2,tool_holder_height/2,centerZ]) cylinder(d=tool_screw_head_area, h=outsideTopZ-centerZ, $fn=20); 
         }

         translate([width/2,-nudge,0])
         rotate([-90,0,0])
         linear_extrude(height=tool_holder_height+2*nudge)
         translate([0, -h2  / sqrt(3)])
             holder_inside(tool_holder_inner_diameter);

         translate([width/2,tool_holder_height/2,centerZ]) cylinder(d=pen_screw_hole_diameter, h=outsideTopZ-centerZ+nudge, $fn=16);
         translate([width/2,tool_holder_height/2,centerZ]) cylinder(d=(pen_screw_nut_width*2/sqrt(3)), h=pen_screw_nut_thickness+(insideTopZ-centerZ), $fn=6);
     }
         if (mini_support_thickness>0) {
                      translate([width/2,tool_holder_height/2,pen_screw_nut_thickness+insideTopZ])
         cylinder(d=pen_screw_hole_diameter+2*nudge, h=mini_support_thickness+nudge, $fn=12);
         }
 }

module base_holes() {
    render(convexity=10)
    union() {
        for (i=[0:len(triangleCenters)-1]) {
         translate(0,0,-nudge) linear_extrude(height=10+triangle_thickness+2*nudge) translate(triangleCenters[i]) circle(d=base_screw_hole_diameter, $fn=12);
            translate([0,0,triangle_thickness-base_screw_nut_thickness])
         linear_extrude(height=base_screw_nut_thickness+nudge) translate(triangleCenters[i]) circle(d=base_screw_nut_width*2/sqrt(3), $fn=6);
    }
}
}
 
module full_holder() {
    linear_extrude(height=spring_width) ribbon_base();
    difference() {
        union() {
            linear_extrude(height=base_thickness) base();
            linear_extrude(height=triangle_thickness) {
                for(i=[0:3]) polygon(triangles[i]);
             }
         }
         base_holes();
     }
     
     tool_holder();
     translate([0,height-tool_holder_height,0]) tool_holder();
}
 
// projection(cut=true)
// translate([0,0,-10])
 full_holder();
 //base_holes();