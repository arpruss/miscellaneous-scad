// Nerf dart gun (c) 2011 Vik Olliver, GPLv3 applies
// Needs a couple of rubber bands, 3mm filament pivots and springs to work.

dart_len=75;
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

// Lined up to print
module pla() {
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
}

module abs() {
	translate([0,0,sear_thick/2]) {
		translate ([0,40,0]) rotate([90,0,0]) trigger();
		translate ([10,20,0]) rotate([90,0,90]) sear(0);
	}
}

render(convexity=12)
pla();
//abs();
