// http://www.thingiverse.com/thing:1227374
// Customizable rack and pinion by rushman is licensed under the Creative Commons - Attribution license.
// by rushman, published Dec 26, 2015

use <MCAD/involute_gears.scad>

height = 4;

circular_pitch=180;
number_of_pinion_teeth=16; // [12:1:200]
pressure_angle = 28;

spacing_between_objects = 0; // [0:real, 5:apart]

function pitch_radius(number_of_teeth, circular_pitch) = (number_of_teeth * circular_pitch / 180) / 2;

function linear_tooth_size(number_of_teeth, circular_pitch) = 
    2*sin(360/number_of_teeth/2)*pitch_radius(number_of_teeth, circular_pitch);


module rack(circular_pitch, number_of_pinion_teeth, number_of_rack_teeth, height,
pressure_angle=28,
clearance=0.2) 

{
    pitch_diameter  =  number_of_pinion_teeth * circular_pitch / 180;
    pitch_radius = pitch_diameter/2;

    base_radius = pitch_radius*cos(pressure_angle);

    // Diametrial pitch: Number of teeth per unit length.
    pitch_diametrial = number_of_pinion_teeth / pitch_diameter;

    // Addendum: Radial distance from pitch circle to outside circle.
    addendum = 1/pitch_diametrial;

    //Outer Circle
    outer_radius = pitch_radius+addendum;

    // Dedendum: Radial distance from pitch circle to root diameter
    dedendum = addendum + clearance;

    root_radius = pitch_radius-dedendum;
    half_thick_angle = (360 / number_of_pinion_teeth) / 4;

    echo("pitch_radius", pitch_radius);
    echo("outer_radius", outer_radius);
    echo("pitch_diametrial", pitch_diametrial);
    echo("addendum", addendum);
    echo("dedendum", dedendum);

    O = 360/number_of_pinion_teeth;
    th=2*sin(O/2)*pitch_radius;
    rack_teeth=number_of_rack_teeth;
    echo("tooth_length", th);
    echo("rack_length", th*rack_teeth);

    union() {
        for (i=[0:rack_teeth]) {
            translate([0,i*th,0])
            linear_extrude(height)
            involute_gear_tooth(
                pitch_radius=pitch_radius,
                root_radius=root_radius,
                base_radius=base_radius,
                outer_radius=outer_radius,
                half_thick_angle=half_thick_angle,
                involute_facets=0);
        }
        cube([root_radius,th*rack_teeth, height]);
    }
}    


module pinion(circular_pitch, number_of_teeth, height, pressure_angle=28, clearance=0.2) {
    rotate([0,0,(number_of_teeth % 2 == 0) ? 180/number_of_teeth:0])
    gear(number_of_teeth=number_of_teeth,
            circular_pitch=circular_pitch,
            pressure_angle=pressure_angle,
            clearance = clearance,
            gear_thickness=height,
            rim_thickness=height,
            rim_width=5,
            hub_thickness=4,
            hub_diameter=4,
            bore_diameter=5,
            circles=0,
            backlash=0,
            twist=0,
            involute_facets=0,
            flat=false);
    
}

anim_phase = $t > 0.5 ? (1-$t) : $t;

th = linear_tooth_size(number_of_pinion_teeth, circular_pitch);

num_rack_teeth=ceil(number_of_pinion_teeth)/2;
translate([0,-th*number_of_pinion_teeth*anim_phase,0])
rack(circular_pitch, number_of_pinion_teeth, num_rack_teeth, height, pressure_angle);

translate([spacing_between_objects, 0, 0])
translate([pitch_radius(number_of_pinion_teeth, circular_pitch)*2,0,0])   
    rotate([0,0,anim_phase*360]) {
        color([0.3, 0.5, 0.8])
        pinion(circular_pitch, number_of_pinion_teeth, height, pressure_angle);
        
    }
$fs=0.5;


//ma=15;
//d=18;
//echo(cos(ma)*d);