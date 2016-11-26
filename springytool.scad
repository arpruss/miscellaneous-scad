use <ribbon.scad>;

pi = 3.141592653589793;
width = 64.9;
height = 48;
edge_thickness = 3;
spring_thickness = 2.5;
base_thickness = 2;

tool_holder_thickness = 2.1;
tool_holder_inner_diameter = 16;
tool_holder_height = 15;

// if this is >0, the pen holes will need to be drilled through
mini_support_thickness = 0.4;

// M3
pen_screw_hole_diameter = 2.9;
pen_screw_nut_thickness = 2.3;
pen_screw_nut_width = 5.33;

//
base_screw_hole_diameter = 2.9;
base_screw_nut_thickness = 2.3;
base_screw_nut_width = 5.33;

triangle_thickness = base_screw_nut_thickness+base_thickness;

tool_screw_head_area = pen_screw_nut_width * 2 / sqrt(3)*1.1;
tool_screw_head_area_extra_thickness = 1;

tool_holder_width = tool_holder_inner_diameter+tool_holder_thickness*2;

clearance_factor = 1.75;

h2 = tool_holder_inner_diameter + 2 * tool_holder_thickness;
spring_width = h2 / sqrt(3)*1.5;

wavelength = (width - tool_holder_width)/2;

amplitude = wavelength / (2*pi);
dh = (2+clearance_factor)*amplitude;

nudge = 0.001;

module spring(wavelength, amplitude, thickness=spring_thickness, spring_points=20) {
    ribbon([for(i=[0:spring_points]) [wavelength*i/spring_points, amplitude*SIN(i*2*pi/spring_points)]], thickness=thickness);       
}

triangles = [
[[spring_thickness,amplitude],[wavelength*.75, dh], [spring_thickness, 2*dh-amplitude]],
[[width-spring_thickness,amplitude],[width-wavelength*.75, dh], [width-spring_thickness, 2*dh-amplitude]],
[[spring_thickness,height-amplitude+spring_thickness/2],[wavelength*.75, height-dh], [spring_thickness,height-( 2*dh-amplitude)]],
[[width-spring_thickness,height-amplitude+spring_thickness/2],[width-wavelength*.75, height-dh], [width-spring_thickness, height-(2*dh-amplitude)]]
];

function sumTo(v,n) = n<0 ? [for (i=[0:len(v[0])]) 0] : v[n]+sumTo(v,n-1);
function sum(v,n) = sumTo(v,len(v)-1);
function center(points) = sum(points)/len(points);

triangleCenters0 = [for (i=[0:len(triangles)-1]) center(triangles[i])];
triangleCenters = [for (i=[0:len(triangles)-1]) [for (j=[0:1]) round(triangleCenters0[i][j])]];
echo("triangle centers", triangleCenters);

module ribbon_base() {
    translate([spring_thickness/2,amplitude]) {
        spring(wavelength, -amplitude);
        translate([width - wavelength-spring_thickness,0]) spring(wavelength, amplitude);
    }

    translate([spring_thickness/2,height-amplitude,0]) {
        spring(wavelength, amplitude);
        translate([width - wavelength-spring_thickness,0]) spring(wavelength, -amplitude);
    }
    
    for (i=[0:3]) ribbon(triangles[i], closed=true, thickness=spring_thickness);

    polygon([[0,amplitude], [edge_thickness,amplitude-edge_thickness*.75], [edge_thickness,height-amplitude+edge_thickness*.75], [0,height-amplitude]]);
    
    polygon([[width,amplitude], [width-edge_thickness,amplitude-edge_thickness*.75], [width-edge_thickness,height-amplitude+edge_thickness*.75], [width,height-amplitude]]);
}

module base() {
    bottom = [[spring_thickness/2,height/2+nudge],[spring_thickness/2,amplitude],[wavelength*.75,dh],[wavelength*.75,tool_holder_height+1.25*amplitude],
    [width-wavelength*.75,tool_holder_height+1.25*amplitude],
    [width-wavelength*.75,dh],[width-spring_thickness/2,amplitude],[width-spring_thickness/2,height/2+nudge]];
    
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
 
 module outer_hexagon(h) {
    r = h / sqrt(3);
    points = [for(i=[0:5]) i == 4 ? [0,-r/2-r/2*sqrt(2)] : [r*cos(30+60*i),(i==0 || i==2) ? r : r*sin(30+60*i)]];
    polygon(points=points);
    translate([-tool_screw_head_area/2, -tool_screw_head_area_extra_thickness-r/2-r/2*sqrt(2)]) 
    square([tool_screw_head_area,tool_holder_thickness*sqrt(2)+tool_screw_head_area_extra_thickness]);
}
 
 module tool_holder() {
     h2 = tool_holder_inner_diameter+2*tool_holder_thickness;
     translate([width/2,0,0])
     rotate([-90,0,0])
     linear_extrude(height=tool_holder_height)
     translate([0, -h2  / sqrt(3)])
     render(convexity=2)
     difference() {
         outer_hexagon(h2);
         stretched_hexagon(tool_holder_inner_diameter);
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
 
 module tool_holder_with_holes() {
     h2 = tool_holder_inner_diameter+2*tool_holder_thickness;
     
     topZ = h2 / sqrt(3) * (1 + 1/2 + sqrt(2)/2 );

    render(convexity=10)
     difference() {
         tool_holder();
         
         translate([width/2,tool_holder_height/2,topZ-tool_holder_thickness*2]) cylinder(d=pen_screw_hole_diameter, h=tool_screw_head_area_extra_thickness+tool_holder_thickness*2+nudge, $fn=12);
         translate([width/2,tool_holder_height/2,topZ-tool_holder_thickness*sqrt(2)-tool_holder_thickness]) cylinder(d=(pen_screw_nut_width*2/sqrt(3)), h=pen_screw_nut_thickness+tool_holder_thickness, $fn=6);
         }
         if (mini_support_thickness>0) {
                      translate([width/2,tool_holder_height/2,topZ-tool_holder_thickness*sqrt(2)+pen_screw_nut_thickness])
         cylinder(d=pen_screw_hole_diameter+2*nudge, h=mini_support_thickness+nudge, $fn=12);
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
     
     tool_holder_with_holes();
     translate([0,height-tool_holder_height,0]) tool_holder_with_holes();
}
 
// projection(cut=true)
// translate([0,0,-10])
 full_holder();
 //base_holes();