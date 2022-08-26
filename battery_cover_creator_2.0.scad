// This thing generates custom battery covers
//
// v2.0
//
// Licenced under Creative Commons: Attribution, Share-Alike
//		http://creativecommons.org/licenses/by-sa/3.0/
// For attribution you can direct people to the original file on thingiverse:
// 		http://www.thingiverse.com/thing:243269

// ================ variables

//CUSTOMIZER VARIABLES

/* [Basic] */

// how long the battery cover is.  (This dimension is in the clip-to-ears direction.)
length=57; // 10:200

// how wide the battery cover is
width=25; // 10:200

// how thick the battery cover is
thickness=0.5;  // 0.1:10

// radius for rounding over the corners of the battery cover
corner_radius=2;  // 0:10

// how thick the case plastic is
case_thickness=2;

// for generating support material.  Can be 0.
support_thickness=0.05;

/* [Ears] */

// how wide the ear tabs are
ear_width=6.4;  // 2:25

// how wide the ear tabs are
ear_length=6.5;  // 2:25

// how far apart the ear tabs are.  (To create one wide tab, just set this to 0.)
ear_spacing=0;  // 1:100

// How thick the case is where the ears attach.  Usually it should be the same as "thickness" on the "basic" tab
ear_case_thickness=1.75;  // 0.1:10

/* [Clip] */

// How wide the clip is
clip_width=10; // 5:50

// How deep the clip is (overhang)
clip_depth=2;

// How long the clip is
clip_length=5.8; // 5.8

// This is used for a side-engagement clip.  Most clips are this way now.  It measures how wide the small part of the clip is.
clip_width_sides=10;

// This is for a front-engagement clip.  If unused, set it to 0, otherwise, how long the catch will be (usually about 2-3mm)
clip_length_catch=0;

// How far the clip is in/out relative to the edge of the battery cover.
//clip_indent=0;  // -15:15

// This is how far down into the battery case the clip engages.  Usually it should be the same as "thickness" on the "basic" tab
clip_case_thickness=3.2;  // 0.1:10

// The thickness of the finger tab
tab_thickness=1;

/* [Gussets] */

// Which direction the support gussets go
gusset_orientation=0; // [0:clip_lengthwise,1:clip_widthwise]

// How thick the gussets are (set to 0 to turn off gussets)
gusset_thickness=0;

// How high the gussets are
gusset_height=0;

// How far apart the gussets are
gusset_spacing=0;

/* [Advanced] */

// Resolution
$fn=30;

/* [hidden] */

scoche=0.01;
halfscoche=scoche/2;

render(convexity=3)
cover(width,length,thickness,case_thickness,gusset_thickness,corner_radius,ear_width,ear_spacing,clip_width,clip_width_sides,clip_length,clip_length_catch,clip_case_thickness,ear_length,tab_thickness);

module clip(clip_width=15,clip_width_sides=10,clip_length=1,clip_case_thickness=5,clip_length_catch=3,tab_thickness=3) {
	top_r=2;
	top_r_x=3.6;
	top_r_y=10.4;
	inside_corner_x=5;
	overlap_tab_w=2;
	inside_void_d1=2;
	inside_void_d2=2;
	inside_void_x=3.6;
	
	rotate([90,0,0]){
		difference () {
			union(){ // the outside shape
				hull () {
					translate([0,0,0]) cylinder(r=1,h=clip_width); // outside radius
					translate([inside_corner_x-1/2,-1,0]) cube([1,1,clip_width]); // inside corner
					translate([top_r_x,top_r_y,0]) cylinder(r=top_r,h=clip_width); // top
					if(clip_length_catch>0){
						translate([-clip_length_catch+0.1,clip_case_thickness,0]) cylinder(r=0.1,h=clip_width); // add a front overhang
					}
				}
				translate([-overlap_tab_w,-1,0]) cube([overlap_tab_w,tab_thickness,clip_width]); // the overlap tab
			}
			union(){ 
				translate([inside_void_x,0,0]) hull() { // The inside void
					translate([0,10.4,-clip_width/2]) cylinder(r=inside_void_d1/2,h=clip_width*2);
					translate([-inside_void_d2/2,-tab_thickness-scoche,-clip_width/2]) cube([inside_void_d2,scoche,clip_width*2]);
				}
				// trim the tab overhang
				translate([-tab_thickness-clip_depth,0,-clip_width/2]) cube([clip_depth*2,clip_case_thickness-tab_thickness,clip_width*2]); // trim off outside
				// trim the tab width
				translate([-2-halfscoche,-2,-(clip_width-clip_width_sides)/2]) cube([5+scoche,clip_case_thickness,(clip_width-clip_width_sides)]); // trim off left side
				translate([-2-halfscoche,-2,clip_width-(clip_width-clip_width_sides)/2]) cube([5+scoche,clip_case_thickness,(clip_width-clip_width_sides)]); // trim off right side
			}
		}
	}
}

module cover(width=30,length=60,thickness=0.5,case_thickness=3.9,gusset_thickness=4.5,corner_radius=1,ear_width=7.5,ear_spacing=29,clip_width=15,clip_width_sides=10,clip_length=1,clip_length_catch=3,clip_case_thickness=5,ear_length=5.8,tab_thickness=3) {
	clip_thickness=1;
	difference(){
		// the base shape
		union(){
			// the face
			translate([-length/2,-width/2,0]) 
			minkowski(){
				cube([length,width,thickness]);
				if(corner_radius>0) cylinder(r=corner_radius,h=thickness);
			}
			// gussets
			translate([8.1,0,0]) cube([54.8,1.6,gusset_thickness]);
			translate([8.1,64.4,0]) cube([54.8,1.6,gusset_thickness]);
			
			difference(){// the ears
				union(){
					translate([(length-ear_length-thickness)/2,(ear_spacing/2)-(ear_width/2),0]) cube([ear_length+thickness,ear_width,case_thickness+thickness*2]);
					translate([(length-ear_length-thickness)/2,(-ear_spacing/2)+(-ear_width/2),0]) cube([ear_length+thickness,ear_width,case_thickness+thickness*2]);
				}	
				translate([(length-ear_length+thickness)/2,(ear_spacing/2)-(ear_width/2)+support_thickness,0]) cube([ear_length,ear_width-support_thickness*2,case_thickness]);
				translate([(length-ear_length+thickness)/2,(-ear_spacing/2)+(-ear_width/2)+support_thickness,0]) cube([ear_length,ear_width-support_thickness*2,case_thickness]);
			}
		}
		union(){
			// hole for clip
			translate([(-length/2)-corner_radius,-clip_width/2-1,-scoche]) cube([clip_length-clip_thickness,clip_width+2,thickness*2+scoche]); // the hole for the clip
			// cutout for ears
		}
	}
	// the clip itsself
	translate([(-length/2)-corner_radius,clip_width/2,1]) clip(clip_width,clip_width_sides,clip_length,clip_case_thickness,clip_length_catch,tab_thickness);
}