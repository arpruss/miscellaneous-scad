// Nerf dart gun ala SuperAmi (c) 2012 Jacob King, GPLv3 applies
// Based on: Nerf dart gun (c) 2011 Vik Olliver, GPLv3 applies
// Needs a couple of rubber bands, 3mm filament pivots and springs to work.

// The stop blocks serve as replacable wear points, as well as mounting points for rubber stoppers
stop_blocks=false;               // print firing pin stopping blocks

// I found I could only print the muzzle or main body on my Thing-O-Matic, otherwise space got too tight
// Besides it can be fun to use different colors on the same model.
print_main=true;
print_muzzle=false;              // print gun muzzle
print_gun=true;                 // print gun body

// I originally had a lot of failures printing the main gun, so this is a way to reduce the number of extra triggers and sears I ended up with.
print_trigger_and_sear = false;  // print the trigger and sear parts

// I recommend the mouse ears for the ABP of the Thing-O-Matic.
mouseears2=false;                // set to true to enable 1mm ears on the rubber band support pieces
earheight=0;                    // set to > 1 for the ear on the handle and to set the height of the ear


module ears() {
intersection() {
translate([70,0,0])
cylinder(earheight, 20, 20);
translate([50,-20,0])
cube([35, 40,5]);
}
if (mouseears2) {
	translate([0,20,0])
	cylinder(earheight, 7, 7);
	translate([0,-20,0])
	cylinder(earheight, 7, 7);
}
}

dart_len=65; // orginally 75
dart_rad=7.9;
barrel_wall=6;
vane_notch=barrel_wall-1;
barrel_dia=dart_rad*2+6;
barrel_base=6;
follower_len=28;
nozzle_len=32;
barrel_length=dart_len+follower_len+barrel_base+15;	// 15mm of actual barrel.
follower_vane_across=barrel_dia+2*barrel_wall;
follower_vane_width=5;
follower_vane_len=follower_len-9;

sear_tip_ht=3+barrel_wall;
sear_point_len=8;
sear_thick=8;
sear_arm=50;
sear_pivot_ht=31;
trigger_pivot_ht=66;
trigger_len=30;
grip_ht=45;
grip_len=65;
scale_width=3;
grip_width=barrel_dia-(2*scale_width);

module grip() difference() {
	translate([grip_len/2+barrel_dia/2,0,grip_ht/2]) {
		translate([-scale_width/2,0,0]) cube([grip_len-scale_width,grip_width,grip_ht],center=true);
		// Scales
		translate([-scale_width/2,grip_width/2,0]) scale([1,1,grip_ht/(scale_width*2)]) rotate([0,90,0]) cylinder(r=scale_width,h=grip_len-scale_width,center=true);
		translate([-scale_width/2,grip_width/-2,0]) scale([1,1,grip_ht/(scale_width*2)]) rotate([0,90,0]) cylinder(r=scale_width,h=grip_len-scale_width,center=true);
		// Base scale
		translate([grip_len/2-scale_width,0,0]) scale([1,1,grip_ht/(scale_width*2)]) rotate([90,0,0]) cylinder(r=scale_width,h=grip_width,center=true);
	}
	// Hole for sear spring
	translate([barrel_dia-8.5,0,-1]) rotate ([0,32,0]) cylinder(r=2.2,h=grip_ht*1.25);
	// Weight saving
	translate([grip_len/2+barrel_dia/2+5,0,-0.1]) cylinder(h=grip_ht-5,r=grip_width/2-3);
	translate([grip_len/2+barrel_dia/2+20,0,-0.1]) cylinder(h=grip_ht-5,r=grip_width/2-3);
	translate([grip_len*0.75+1,0,grip_ht/2]) rotate ([0,90,0]) scale([3,1,1]) cylinder(h=grip_len/2,r=grip_width/2-3);
}

module sear_pivot(stretch) {
	translate([barrel_dia*0.62+3.5,0,sear_pivot_ht]) rotate([90,0,0])
		cylinder (h=barrel_dia*2,r=2+stretch,center=true);
}

trigger_pivot_offset=barrel_dia*0.75;
module trigger_pivot(stretch) {
	translate([trigger_pivot_offset,0,trigger_pivot_ht])
		rotate([90,0,0])
			cylinder (h=barrel_dia*3,r=2+stretch,center=true);
}

module trigger_pivot_space(stretch) {
	translate([trigger_pivot_offset,0,trigger_pivot_ht])
		rotate([90,0,0])
			cylinder (h=sear_thick+1+stretch,r=7+stretch,center=true);
}

module trigger() {
	difference () {
		translate ([barrel_dia/2+5,0,trigger_pivot_ht]) {
			translate([15,0,0]) {
				cube([trigger_len,sear_thick,10],center=true);
			}
			rotate([90,0,0]) cylinder(r=5,h=sear_thick,center=true);
			translate([13,0,-7]){
				rotate([90,0,0]) cylinder(r=5,h=sear_thick,center=true);
				rotate([0,6,0]) translate([0,0,5]) cube([10,sear_thick,10],center=true);
			}
		}
		translate ([barrel_dia/2+5,0,trigger_pivot_ht]) {
			// Finger curve
			translate([trigger_len*0.5,0,16]) rotate([90,0,0]) scale([1.5,1,1]) cylinder(r=15,h=sear_thick*1.5,center=true);	
			// Taper at end of trigger.
			translate ([trigger_len+6,0,-2]) rotate ([0,-40,0]) cube([trigger_len,sear_thick*2,16],center=true);
		}
	trigger_pivot(0.3);
	}
}

// The sear that holds the follower back.
sear_forelength=0.31*sear_arm;
module sear(swell) difference () {
	union () {
		translate ([sear_tip_ht/2+2,0,sear_point_len/2]) difference() {	// Sear tip
			cube([sear_tip_ht+swell,sear_thick+swell,sear_point_len+2*swell],center=true);
			// Clips slant on tip.
			translate([-(sear_tip_ht+swell)*0.5,0,(sear_point_len+swell)/2]) rotate ([0,-45,0])
				cube([sear_tip_ht,sear_thick+1+swell,sear_point_len],center=true);
		}
		translate ([sear_tip_ht*1.1+3,0,0]) rotate ([0,6,0]) translate([0,0,sear_arm/4]) {
			translate ([0,0,1]) cube([8+swell,sear_thick+swell,sear_arm/2+4],center=true);
			// Pivot centre.
			translate([1.0,0,sear_arm/2-6]) {
				// Pivot
				rotate([90,0,0]) cylinder(r=6+swell,h=sear_thick+swell*2,center=true);
				// Fore length
				translate([3,0,sear_forelength/2]) rotate([0,9,0]) {
					translate ([-1,0,0]) cube([8+swell,sear_thick+swell,sear_forelength],center=true);
					// Rounded end to engled off bit.
					translate([-1,0,sear_forelength/2]) rotate([90,0,0])
						cylinder(r=4+swell,h=sear_thick+swell*2,center=true);
				}
			}
		}
	}
	sear_pivot(0.3);
}

support_len=barrel_base+11;
module band_notch(thick) {
	difference() {
		union () {
			translate ([0,0,thick/2])
				cube([follower_vane_width,follower_vane_across,thick],center=true);
			// Supports
			translate ([0,(follower_vane_across+follower_vane_width)/2,1.5])
				cube([6.5,follower_vane_width+1.5,support_len],center=true);
			translate ([0,-(follower_vane_across+follower_vane_width)/2,1.5])
				cube([6.5,follower_vane_width+1.5,support_len],center=true);
		}
		translate([0,follower_vane_across/2-vane_notch+2,0])
			rotate ([45,0,0]) cube([follower_vane_width+5,vane_notch,vane_notch],center=true);
		translate([0,-(follower_vane_across/2-vane_notch+2),0])
			rotate ([45,0,0]) cube([follower_vane_width+5,vane_notch,vane_notch],center=true);
		translate([0,-(follower_vane_across/2),thick/2+support_len-1])
			rotate ([45,0,0]) cube([follower_vane_width+5,thick*2,thick],center=true);
		translate([0,(follower_vane_across/2),thick/2+support_len-1])
			rotate ([-45,0,0]) cube([follower_vane_width+5,thick*2,thick],center=true);
	}
}

module follower() {
	difference () {
		union() {
			translate([0,0,2]) cylinder(h=follower_len-3,r=dart_rad-0.95);
			translate([0,0,follower_len-1]) cylinder(h=1,r1=dart_rad-0.95,r2=dart_rad-1.95);
			cylinder(h=2,r2=dart_rad-0.95,r1=dart_rad-2.5);
			translate ([0,0,barrel_base+1]) band_notch(follower_vane_len);
		}
		translate([0,0,-1]) cylinder(r=2.0,h=follower_len+3);
	}
}

module nerf_dart() {
	cylinder(h=dart_len,r=dart_rad);
	translate ([0,0,dart_len+dart_rad/2]) {
		difference () {
			sphere(dart_rad);
			cylinder(h=dart_rad+1,r=dart_rad);
			translate([0,0,2]) sphere(dart_rad);
		}
	}
}

module frame() {
	difference () {
		union() {
			translate([0,0,barrel_length-barrel_base-1]) rotate([0,180,0]) band_notch(nozzle_len);
			translate([0,0,barrel_length/2]) cube([barrel_dia,barrel_dia,barrel_length],center=true);
			// Domed top of barrel
			translate([-barrel_dia/2,0,0]) scale([0.3,1,1]) cylinder(h=barrel_length,r=barrel_dia/2);
			// Domed underside of barrel
			translate([barrel_dia/2,0,0]) scale([0.25,1,1]) cylinder(h=barrel_length,r=barrel_dia/2);
			// Sear pivot bracket
			translate ([barrel_dia/2-2.5,0,sear_pivot_ht-5]) {
				translate([-1,0,(barrel_length-50)/2+barrel_dia*0.4]) rotate([0,-10,0])
					cube([barrel_dia,barrel_dia,barrel_length-50],center=true);
				translate([0,0,barrel_dia/2]) rotate([0,45,0])
					cube([barrel_dia,barrel_dia,barrel_dia],center=true);
			}
			// Trigger pivot bracket
			translate ([barrel_dia/2,0,trigger_pivot_ht-11]) {
				translate([0,0,barrel_dia/2]) rotate([90,0,0])
					scale([1,1.3,1]) cylinder(r=barrel_dia/2,h=barrel_dia,center=true);
			}
			grip();
		} 
		translate([0,0,-1]) cylinder(h=barrel_length+2,r=dart_rad+1);
		translate([0,0,(barrel_length-nozzle_len)/2+barrel_base/2])
			cube([follower_vane_width+3,dart_rad*2+10,barrel_length-nozzle_len-barrel_base],center=true);
		// Slot for sear
		translate([10+barrel_dia*0.5,0,(grip_ht+sear_arm)/2-0.1]) cube([20,sear_thick+1.9,grip_ht+sear_arm],center=true);
		trigger_pivot_space(0);
	} 
}

// Mechanical lineup
module demo() {
	difference () {
	union () {
		trigger();
		translate([0,0,barrel_base+1]) sear(0);
		difference () {
			union () {
				frame();
				follower();
			}
			translate([0,0,barrel_base+1]) {
				sear(0.9);
				sear_pivot(0);
			}
			trigger_pivot(0);
		}
		
		translate ([0,0,follower_len+1]) nerf_dart();
	}
	translate([-50,0,-10]) cube([130,30,150]);
	}
}

site=5;
site2=1.25*site;
module site_bottom() {
	translate([-13-site,site/2,0])
	cube([site,site,2*site]);
	translate([-13-site,-1.5*site,0])
	cube([site,site,2*site]);
	translate([-13-site,site/2,site*2])
	polyhedron([[0,0,0], [site,0,0], [site,0,site*2], [0,site,0], [site,site,0], [site,site,2*site]],
		      [[0,2,1], [3,4,5], [0,3,2], [2,3,5],[1,2,4],[2,5,4],[0,1,3],[1,4,3]]);
	translate([-13-site,-1.5*site,site*2])
	polyhedron([[0,0,0], [site,0,0], [site,0,site*2], [0,site,0], [site,site,0], [site,site,2*site]],
		      [[0,2,1], [3,4,5], [0,3,2], [2,3,5],[1,2,4],[2,5,4],[0,1,3],[1,4,3]]);
}
thick=2.5;
wide=10;
module site_top() {
	translate([-13-site, -0.5*site, 90])
	cube([site2,site,4*site+4]);
	translate([-13-site,0.5*site, 90])
	rotate([180,0,0])
	polyhedron([[0,0,0], [site2,0,0], [site2,0,site*2], [0,site,0], [site2,site,0], [site2,site,2*site]],
		      [[0,2,1], [3,4,5], [0,3,2], [2,3,5],[1,2,4],[2,5,4],[0,1,3],[1,4,3]]);
	translate([13.5-thick,-wide/2, 85])
	cube([thick, wide, 10]);
	translate([0,-20,114-earheight])
	cylinder(earheight, 7,7);
	translate([0,20,114-earheight])
	cylinder(earheight, 7,7);
}

// Lined up to print
module print_me() {
	if (print_trigger_and_sear) {
		translate([0,0,sear_thick/2]) {
			translate ([0,40,0]) rotate([90,0,0]) trigger();
			translate ([10,20,0]) rotate([90,0,90]) sear(0);
		}
	}
    if (print_main) 
    difference () {
        union () {
            frame();
            follower();
        }
        translate([0,0,barrel_base+1]) {
            sear(1.5);
            sear_pivot(0);
        }
        trigger_pivot(0);
    }
    if (print_main) 
    site_bottom();
    if (earheight > 0) {
        ears();
    }
}

module block() {
	translate([0,0,3])
	cube([8,3,3]);
	cube([8,13,3]); 
}

module stop_block() {
	translate([35,-30,0])
	block();
	translate([35,-10,0])
	block();
}

module muzzle() {
	translate([0,0,114])
	rotate([0,180,0])
	union() {
		intersection() {
			print_me();
			translate([-20,-40, 94])
			cube([100,100,94]);
		}
		if (print_main) site_top();
	}
}

module rest_of_gun(){
	difference() {
		intersection() {
			print_me();
			translate([-20,-40, 0])
			cube([100,100,94]);
		}
		site_top();
	}
}

render(convexity=10)
translate([0,-30,0])
rotate([0,0,90])
union() {
if (print_muzzle) {
	if (print_gun) {
		translate([55,-45,0])
		muzzle();
	}
	else {
		translate([30,0,0])
		muzzle();
	}
}

if (print_gun) {
    render(convexity=10)
	rest_of_gun();
}
}
if (stop_blocks) {
    render(convexity=10)
	stop_block();
}
