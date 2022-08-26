// 5/21/2011


use </Users/jag/dropbox/scad/MCAD/involute_gears.scad>

//default settings
// pitch=0.865;			//diametric pitch = teeth/diam
// gear_thickness=11;
// pilot_diam=23;

clearance=0.5;
backlash=0.45;
pressure_angle=28;
wall=1;
extra=0.01;
circle_precision=0.1;
addendum_adjustment=1.4;

//test();

//print_parts(part="cover", stages=1);	// part can be sun, intcarrier, finalcarrier, planet, housing or cover

//singleprint();
//multistage_assembly(stages=4);
//housing();
//sun();
//planet();
//carrier(final=false);
//cover();

module print_parts(ring_teeth=32, sun_teeth=8, stages=2, part="housing") // part can be sun, intcarrier, finalcarrier, planet, housing or cover
{
	ratio=pow(1/(1+ring_teeth/sun_teeth),stages);
	echo("Final Ratio:", 1/ratio);
	
	echo("BOM");
	echo("Housings:", 1);
	echo("Sun Gears:", 1);
	echo("Planet Gears:", 3*stages);
	echo("Intermediate Carriers:", stages-1);
	echo("Final Carriers:", 1);
	echo("Covers:", 1);
	

	if (part=="housing") {
		housing(teeth=ring_teeth, stages=stages);
	} else if (part=="sun") {
		sun(teeth=sun_teeth);
	} else if (part=="planet") {
		planet(teeth=(ring_teeth-sun_teeth)/2);
	} else if (part=="intcarrier") {
		carrier(final=false,teeth=sun_teeth);
	} else if (part=="finalcarrier") {
		carrier();
	} else if (part=="cover") {
		cover();
	}

}

module test() {
	ring_teeth=32;
	sun_teeth=8;
	motor_size=42;
	num_planets=3;
	pitch=0.865;
	
	ratio=1/(1+ring_teeth/sun_teeth);
	echo("Gear Ratio:", 1/ratio);

	planet_teeth=(ring_teeth-sun_teeth)/2;
	orbit_radius=((planet_teeth+sun_teeth)/pitch)/2;
	test_ring(teeth=ring_teeth);
	translate([motor_size/2+2.5,motor_size/2+10,0]) planet(teeth=sun_teeth, bearing_diam=0, bore=0);
	translate([motor_size+5,motor_size+5,0]) for (planetnum=[1:num_planets]) rotate([0,0,(360/num_planets)*(planetnum-0.5)]) translate([0,orbit_radius ,0]) rotate([0,0,0]) planet(bearing_diam=0, bore=0);
	//translate([0,motor_size+7,0]) carrier();
}


module multistage_assembly(num_planets=3, gear_height=12, gear_thickness=11, carrier_thickness=6, sun_teeth=8, planet_teeth=12, pitch=0.865, stages=2) {
	orbit_radius=((planet_teeth+sun_teeth)/pitch)/2;
	housing_thickness=gear_height+gear_thickness*stages+carrier_thickness*stages;

	sun();
	
	for (stagenum=[1:stages])
	{
		for (planetnum=[1:num_planets]) rotate([0,0,(360/num_planets)*(planetnum-1)]) translate([orbit_radius, 0 ,gear_height+(carrier_thickness+gear_thickness)*(stagenum-1)]) rotate([0,0,0]) planet();
		translate([0,0,gear_height+gear_thickness*stagenum+carrier_thickness*(stagenum-1)]) if (stagenum==stages) {
			carrier();
		} else {
			 carrier(final=false);
		}
	}
	%housing(stages=stages);
	%translate([0,0,housing_thickness]) cover();
	
}

module singleprint() {
	ring_teeth=32;
	sun_teeth=8;
	motor_size=42;
	num_planets=3;
	pitch=0.865;
	cover_thickness=8;

	ratio=1/(1+ring_teeth/sun_teeth);
	echo("Gear Ratio:", 1/ratio);

	planet_teeth=(ring_teeth-sun_teeth)/2;
	orbit_radius=((planet_teeth+sun_teeth)/pitch)/2;
	housing(housing_teeth=ring_teeth,pitch=pitch);
	translate([motor_size/2+2.5,motor_size/2+10,0]) sun(teeth=sun_teeth,pitch=pitch);
	translate([motor_size+5,motor_size+5,0]) for (planetnum=[1:num_planets]) rotate([0,0,(360/num_planets)*(planetnum-0.5)]) translate([0,orbit_radius ,0]) rotate([0,0,0]) planet(teeth=planet_teeth,pitch=pitch);
	translate([motor_size+5,0,cover_thickness]) rotate([0,180,0]) cover();
	translate([0,motor_size+7,0]) carrier();
}


module multistage_assembly(num_planets=3, gear_height=12, gear_thickness=11, carrier_thickness=6, sun_teeth=8, planet_teeth=12, pitch=0.865, stages=2) {
	orbit_radius=((planet_teeth+sun_teeth)/pitch)/2;
	housing_thickness=gear_height+gear_thickness*stages+carrier_thickness*stages;

	sun();
	
	for (stagenum=[1:stages])
	{
		for (planetnum=[1:num_planets]) rotate([0,0,(360/num_planets)*(planetnum-1)]) translate([orbit_radius, 0 ,gear_height+(carrier_thickness+gear_thickness)*(stagenum-1)]) rotate([0,0,0]) planet();
		translate([0,0,gear_height+gear_thickness*stagenum+carrier_thickness*(stagenum-1)]) if (stagenum==stages) {
			carrier();
		} else {
			 carrier(final=false);
		}
	}
	%housing(stages=stages);
	%translate([0,0,housing_thickness]) cover();
	
}

module planet(teeth=12, pitch=0.865, gear_thickness=11, pressure_angle=pressure_angle, bearing_diam=7.4, bearing_thickness=2.75, bearing_spacing=2, bore=5, vertical_space=1.0) {
	intersection () {
		difference() {
				gear(number_of_teeth=teeth, diametral_pitch=pitch, hub_diameter=0, hub_thickness=gear_thickness-vertical_space, bore_diameter=bore, rim_thickness=gear_thickness-vertical_space, rim_width=0, gear_thickness=gear_thickness-vertical_space,clearance=clearance, backlash=backlash, pressure_angle=pressure_angle);
				translate([0,0,gear_thickness-bearing_thickness-vertical_space]) cylinder(r=bearing_diam/2, h=bearing_thickness+extra);
				translate([0,0,-extra]) cylinder(r=bearing_diam/2, h=gear_thickness-bearing_spacing-bearing_thickness-vertical_space);
				
		}
		cylinder(r1=(teeth/pitch)/2, r2=(teeth/pitch)/2+gear_thickness,h=gear_thickness+extra*2);
	}
}

module test_ring(motor_size=42, housing_teeth=32, pitch=0.865, pressure_angle=pressure_angle, wall=1, gear_thickness=11)
{
	total_height=gear_thickness;
	difference() {
		translate([0,0,total_height/2]) intersection() {
			cube([motor_size,motor_size,total_height], center=true);
			cylinder(r=sqrt(2*pow(motor_size/2,2))-3, h=total_height, center=true);
		}
		gear(number_of_teeth=housing_teeth, diametral_pitch=pitch, hub_diameter=0, bore_diameter=0, rim_thickness=total_height, gear_thickness=total_height,clearance=0, backlash=-backlash, pressure_angle=pressure_angle, addendum_adjustment=addendum_adjustment);
	}
}

module housing(motor_size=42, housing_teeth=32, pitch=0.865, pressure_angle=pressure_angle, wall=1, recess_depth=2, stages=1, gear_thickness=11, gear_height=12, pilot_diam=23, pilot_length=2, carrier_thickness=6, bolt_spacing=31, bolt_size=3.5) {
	total_height=gear_height+gear_thickness*stages+carrier_thickness*stages+recess_depth;
	ring_height=gear_thickness*stages+carrier_thickness*(stages-1);
	gear_diam=housing_teeth/pitch;

	echo("Housing height:",total_height);

	translate([0,0,total_height/2]) difference() {
		intersection() {
			cube([motor_size,motor_size,total_height], center=true);
			cylinder(r=sqrt(2*pow(motor_size/2,2))-3, h=total_height, center=true);
		}
		for (xnum=[-1,1]) for (ynum=[-1,1]) {
			translate([xnum*bolt_spacing/2,ynum*bolt_spacing/2,0]) {
				cylinder(r=bolt_size/2, h=total_height+extra, center=true, $fs=circle_precision);
				cylinder(r=3, h=total_height-10, center=true, $fn=6);
				translate([0,ynum*8,0]) cube([6,15,total_height-10], center=true);
			}
			
		}
		translate([0,0,-total_height/2-extra/2]) cylinder(r=pilot_diam/2,h=pilot_length, $fs=circle_precision);
		translate([0,0,-total_height/2-extra+pilot_length]) cylinder(r1=pilot_diam/2, r2=gear_diam/2-2,h=gear_height+extra*2-pilot_length, $fs=circle_precision);
		translate([0,0, total_height/2-recess_depth/2-carrier_thickness/2]) cylinder(r=motor_size/2-wall,h=carrier_thickness+recess_depth+extra, center=true, $fs=circle_precision);
		translate([0,0,gear_height-total_height/2]) gear(number_of_teeth=housing_teeth, diametral_pitch=pitch, hub_diameter=0, bore_diameter=0, rim_thickness=ring_height+extra, gear_thickness=ring_height+extra,clearance=0, backlash=-backlash, pressure_angle=pressure_angle, addendum_adjustment=addendum_adjustment);
	}
}

module cover(thickness=8, motor_size=42, bolt_spacing=31, bolt_size=3, bearing_diam=17, bearing_thickness=6, output_hole_diam=9.5, stickout=1, bolt_relief_depth=4, bolt_relief_ID=25, bolt_relief_OD=35) {
	difference() {
		intersection() {
			union() {
				translate([0,0,thickness/2+stickout/2]) cube([motor_size,motor_size,thickness-stickout],center=true);
				cylinder(r=motor_size/2-wall,h=stickout+extra, $fs=circle_precision);
			}
			cylinder(r=sqrt(2*pow(motor_size/2,2))-3, h=thickness);
		}
		translate([0,0,-extra/2]) difference() {
			cylinder(r=bolt_relief_OD/2, h=bolt_relief_depth);
			translate([0,0,-extra/2]) cylinder(r=bolt_relief_ID/2, h=bolt_relief_depth+extra);
		}
		translate([0,0,-extra/2]) cylinder(r=output_hole_diam/2,h=thickness+extra);
		translate([0,0,-extra]) cylinder(r=bearing_diam/2, h=bearing_thickness+extra);

		for (xnum=[-1,1]) for (ynum=[-1,1])
			translate([xnum*bolt_spacing/2,ynum*bolt_spacing/2,-extra/2]) cylinder(r=bolt_size/2, h=thickness+extra, $fs=circle_precision);

	}

}

module sun(pitch=0.865, teeth=8, gear_thickness=11, gear_height=11, bore_diam=5, , hub_diam=20, clearance=0.2, backlash=0.2, pressure_angle=pressure_angle, nut_size=6, nut_thickness=2.75, screw_diam=3) {
	 difference() {
		translate([0,0,gear_height+gear_thickness]) rotate([0,180,0]) gear(number_of_teeth=teeth, diametral_pitch=pitch, hub_diameter=hub_diam, hub_thickness=gear_height+gear_thickness, bore_diameter=bore_diam, rim_thickness=gear_thickness, rim_width=0, gear_thickness=gear_thickness,clearance=clearance, backlash=backlash, pressure_angle=pressure_angle);
		cylinder(r=bore_diam/2,h=gear_height+gear_thickness, $fs=circle_precision);		// cut out bore for motor shaft
		translate([0,0,(nut_size*1.15)/2]) rotate([0,90,0]) cylinder(r=screw_diam/2,h=hub_diam+extra, center=true, $fs=circle_precision);		//cut hole for set screws
			for (num=[0:1]) rotate([0,0,180*num]) translate([(-hub_diam+bore_diam)/2,-nut_size/2,0]) cube([nut_thickness,nut_size,nut_size*1.15]);			// cut pocket for set screw nuts
	}
}

module carrier(thickness=6,num_planets=3, planet_teeth=12, sun_teeth=8, pitch=0.865, nut_diam=10, nut_thickness=2.75, planet_bolt_diam=3, output_diam=6, output_head_size=10, head_height=4.5, final=true, teeth=8, gear_thickness=11, pitch=0.865, pressure_angle=pressure_angle) 
{
	orbit_radius=((planet_teeth+sun_teeth)/pitch)/2;

	difference() {
		union() {
			cylinder(r=orbit_radius+nut_diam/2+1,h=thickness, $fs=circle_precision);
			if (!final) {
				translate([0,0,thickness]) gear(number_of_teeth=teeth, diametral_pitch=pitch, hub_diameter=0, hub_thickness=gear_thickness, bore_diameter=0, rim_thickness=gear_thickness, rim_width=0, gear_thickness=gear_thickness,clearance=clearance, backlash=backlash, pressure_angle=pressure_angle);
			}
		}
		for (planetnum=[1:num_planets]) 
			rotate([0,0,(360/num_planets)*(planetnum-1)])
				translate([orbit_radius,0,-extra/2]) {
					cylinder(r=planet_bolt_diam/2,h=thickness+extra, $fs=circle_precision);
					translate([0,0,thickness-nut_thickness]) cylinder(r=nut_diam/2, h=nut_thickness+extra);
				}
		if (final) {
			translate([0,0,-extra/2]) cylinder(r=output_head_size/2*1.15, h=head_height+extra, $fn=6);
		}
		translate([0,0,-extra/2]) cylinder(r=output_diam/2, h=thickness+gear_thickness+extra, $fs=circle_precision);
	}
}