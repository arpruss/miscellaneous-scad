// Mutilated "OpenSCAD Herringbone Wade's Gears Script"
// (c) 2015, Frans-Willem Hardijzer
//
// Thanks to Christopher "ScribbleJ" Jansen for the inspiration and most of the calculations
// Thanks to Greg Frost for the "Involute Gears" script.
//
// Small mods by AndrewBCN, August 2015:
// - Changed some defaults.
// - Additional comments in the source code.
// - NEMA 17 stepper D-shaft support.

include <involute_gears.scad> 
//
/*************************\
 * General Configuration *
\*************************/

/* Set to 1 to render gears as cylinders instead,
 * Will speed up rendering for experimenting with decorations.
 */
debug = 0;

//cylinder radius for substracting the big gear
//actual gear radius is calculated later
outer_gear_radius=32;

clearance = .1;
distance_between_axles = 20;
/* Height of the actual gear teeth
 */
gear_height = 7; //Height of the actual gears

/* Gear "twist": how slanted the gears are.
 * A value of 1 means each tooth will slant up one additional tooth.
 */
teeth_twist = 0;

/* Chamfer gradient, tan(45) degrees works nicely.
 * Use -1 to disable chamferred edges.
 */
chamfer_gradient = -1;

/****************************\
 * Small gear configuration *
\****************************/

/* Number of teeth on the gear */
gear1_teeth = 12;

/* Height of the base (for the setscrew) */

/**************************\
 * Big gear configuration *
\**************************/
/* Number of teeth */
gear2_teeth = 41;
gear2_top_thickness=2;
gear2_height_mod = 1;

///#%translate([0,0,-10]) cylinder(d=40,h=10,$fn=64);
/********************\
 * Pre-calculations *
\********************/
//rough values for approximation
inner_gear_radius0=(outer_gear_radius)/(gear2_teeth/gear1_teeth);
circular_pitch0=360*(distance_between_axles+inner_gear_radius0)/(gear2_teeth);
echo("rough values:");
echo("pitch:",circular_pitch0,"inner gear r:",inner_gear_radius0);

//recursive approximation of inner gear radius and circular pitch, whatever it means
//there should be an easier way of doing this
function get_pitch(inner_gear_radius,circular_pitch,i=0) = 
((i>=20)||(abs(inner_gear_radius-gear1_teeth*(circular_pitch)/360) < 0.1)) ? 
circular_pitch :
360*(distance_between_axles+gear1_teeth*get_pitch(inner_gear_radius,circular_pitch,i+1)/360)/(gear2_teeth);
//dunno why this works
circular_pitch = get_pitch(inner_gear_radius0,circular_pitch0); 
inner_gear_radius=gear_radius(gear1_teeth, circular_pitch);
echo("actual values:");
echo("pitch:",circular_pitch,"inner gear r:",inner_gear_radius);
echo("outer gear radius:",gear_outer_radius(gear2_teeth, circular_pitch));

//default=360*distance_between_axles/(gear1_teeth+gear2_teeth);
/********************\
 * Helper functions *
\********************/
//Distance to overlap things that should be joined.
epsilon = 0.01;

function gear_radius(number_of_teeth, circular_pitch) = number_of_teeth * circular_pitch / 360;

function gear_outer_radius(number_of_teeth, circular_pitch) = gear_radius(number_of_teeth=number_of_teeth, circular_pitch=circular_pitch) + (circular_pitch/180);

function gear_inner_radius(number_of_teeth, circular_pitch) = gear_radius(number_of_teeth=number_of_teeth, circular_pitch=circular_pitch) - (circular_pitch/180);

module mirrordupe(p) {
    children();
    mirror(p) children();
}

module chamfered_herring_gear(height, chamfer_gradient, teeth_twist, number_of_teeth, circular_pitch) {
    radius = gear_radius(number_of_teeth=number_of_teeth, circular_pitch=circular_pitch);
    outer_radius = gear_outer_radius(number_of_teeth=number_of_teeth, circular_pitch=circular_pitch);
    twist = 360 * teeth_twist / number_of_teeth / 2;

    edge = (outer_radius - radius) / chamfer_gradient;
    intersection() {
        union() {
            if (debug == 1) {
                cylinder(h=height, r=outer_radius);
            } else {
                translate([0,0,height/2])
                    mirrordupe([0,0,1])
                        translate([0,0,-epsilon])
                            gear(
                                twist=twist,
                                number_of_teeth=number_of_teeth,
                                circular_pitch=circular_pitch,
                                gear_thickness = (height/2) + epsilon,
                                rim_thickness = (height/2) + epsilon,
                                hub_thickness = (height/2) + epsilon,
                                bore_diameter=0);
            }
        }
        //Cut edges
        union() {
            cylinder(h=edge + epsilon, r1=radius, r2=outer_radius + epsilon*chamfer_gradient);
            translate([0,0,edge])
                cylinder(h=height-2*edge, r=outer_radius);
            translate([0,0,height-edge-epsilon])
                cylinder(h=edge + epsilon, r2=radius, r1=outer_radius + epsilon*chamfer_gradient);
        }
    }
}

module hole(h,r,$fn=8,rot=0) {
    rotate([0,0,rot * (180/$fn)])
        cylinder(h=h, r=r / cos(180 / $fn), $fn=$fn);
}

module gear1() {
    //Variables
    radius = gear_radius(gear1_teeth, circular_pitch);
//    inner_radius = gear_inner_radius(gear1_teeth, circular_pitch);
    outer_radius = gear_outer_radius(gear1_teeth, circular_pitch);
    base_chamfer = (outer_radius - radius) / chamfer_gradient;
    //negative teeth twis
	chamfered_herring_gear(height = gear_height, chamfer_gradient = chamfer_gradient, teeth_twist=-teeth_twist,number_of_teeth=gear1_teeth, circular_pitch=circular_pitch);    
}

module gear2() {
    radius = gear_radius(gear2_teeth, circular_pitch);
//    inner_radius = gear_inner_radius(gear2_teeth, circular_pitch);
    outer_radius = gear_outer_radius(gear2_teeth, circular_pitch);
    inner_chamfer_radius = (outer_radius - radius);
    inner_chamfer = inner_chamfer_radius / chamfer_gradient;
   
    difference() {
        translate([0,0,epsilon]) cylinder(d=(outer_gear_radius)*2,h=gear_height+gear2_height_mod+gear2_top_thickness,$fn=128);
        chamfered_herring_gear(height = gear_height+gear2_height_mod, chamfer_gradient = chamfer_gradient,teeth_twist=-teeth_twist, number_of_teeth=gear2_teeth, circular_pitch=circular_pitch);
    }
}

module gears()
{
X=gear_radius(gear2_teeth, circular_pitch)-
gear_radius(gear1_teeth, circular_pitch)-clearance;
//Big gear (gear 2)
    gear2();
    //#%translate([0,0,-50]) cylinder(d=1,h=100,$fn=16);
//Small gear (gear 1)
    translate([distance_between_axles-clearance,0,0]) {
    //#%translate([0,0,-50]) cylinder(d=0.5,h=100,$fn=16);
        gear1();
}
}

gears();