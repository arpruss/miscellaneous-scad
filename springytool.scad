use <ribbon.scad>;

pi = 3.141592653589793;
width = 64.9;
height = 72.575;
tool_holder_width = 20;
edge_thickness = 3;
spring_thickness = 2;
spring_width = 20;
base_thickness = 2;
triangle_thickness = 3;

clearance_factor = 1.75;

wavelength = width - tool_holder_width * 2-spring_thickness/2;
amplitude = wavelength / (2*pi);
dh = (2+clearance_factor)*amplitude;

module spring(wavelength, amplitude, thickness=spring_thickness, spring_points=20) {
    ribbon([for(i=[0:spring_points]) [wavelength*i/spring_points, amplitude*SIN(i*2*pi/spring_points)]], thickness=thickness);       
}

triangles = [
[[spring_thickness,amplitude],[wavelength*.75, dh], [spring_thickness, 2*dh-amplitude]],
[[width-spring_thickness,amplitude],[width-wavelength*.75, dh], [width-spring_thickness, 2*dh-amplitude]],
[[spring_thickness,height-amplitude+spring_thickness/2],[wavelength*.75, height-dh], [spring_thickness,height-( 2*dh-amplitude)]],
[[width-spring_thickness,height-amplitude+spring_thickness/2],[width-wavelength*.75, height-dh], [width-spring_thickness, height-(2*dh-amplitude)]]
];

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
    polygon([[spring_thickness/2,amplitude],[wavelength*.75,dh],[width-wavelength*.75,dh],[width-spring_thickness,amplitude], [width-spring_thickness,height-amplitude/2-spring_thickness/2], [width-wavelength*.75,height-dh], [wavelength*.75, height-dh], [spring_thickness/2, height-amplitude/2-spring_thickness/2]] );
}

linear_extrude(height=spring_width) ribbon_base();
linear_extrude(height=base_thickness) base();
linear_extrude(height=triangle_thickness) {
    for(i=[0:3]) polygon(triangles[i]);
 }