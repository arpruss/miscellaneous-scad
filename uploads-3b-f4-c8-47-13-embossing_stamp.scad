// preview[view:south, tilt:top]

/* [Global] */

// Load a 100x100 pixel image.(images will be stretched to fit) Simple, high contrast images work best. Make sure to click the Invert Colors checkbox!
image_file = "smile.dat"; // [image_surface:100x100]

// Where would you like the hinge in relation to your image?
hinge_placement = 1; // [1:top,2:left,3:bottom,4:right]

// What height would you like for the embossed area (mm)?
emboss_height = 1.5;

/* [Hidden] */
$fa = 6;
$fs = 1.5;
image_width = 40;
image_length = 40;
image_padding = 4;

handle_width = image_width + image_padding*2;
handle_length = 70;
handle_height = emboss_height+2.5;
nub = 3; // hinge size
tol = 0.4; // spacing between hinge pieces

assembly();

module assembly() {
    stamp_top(90*hinge_placement);
    stamp_bottom(90*hinge_placement);   
}

module stamp_top(rot=90) {
    translate([1,0,0])
    union() {
        difference () {
            translate([handle_length + nub + tol, -handle_width/2, 0])
                rotate([0,0,90]) handle();
            translate([handle_length-image_length/2+nub+tol,0,handle_height]) 
                rotate([0,180,rot]) plate();
        }
    
        // hinge
        translate([-1,handle_width/2-2*nub,handle_height]) hinge_m();
        mirror([0,1,0]) translate([-1,handle_width/2-2*nub,handle_height]) hinge_m();
        translate([-1,-nub,handle_height]) hinge_m();
        mirror([0,1,0]) translate([-1,-nub,handle_height]) hinge_m();
    }
}

module stamp_bottom(rot=90) {
    translate([-1,0,0])
    union() {
        translate([-handle_length + image_length/2-nub-tol,0,handle_height]) 
            rotate([0,0,-rot]) plate();
        mirror([1,0,0]) translate([handle_length + nub + tol, -handle_width/2, 0]) 
            rotate([0,0,90]) handle();
        
        // hinge
        translate([1,-nub-tol,handle_height]) hinge_f();
        mirror([0,1,0]) translate([1,-nub-tol,handle_height]) hinge_f();
    }
}

module handle() {
    difference() {
        hull() {
            cube([handle_width, handle_length, handle_height]);
            translate([image_padding,0,0]) cylinder(r=image_padding, h=handle_height);
            translate([handle_width-image_padding,0,0]) cylinder(r=image_padding, h=handle_height);
        }
        guide();
    }

}

module guide() {
    translate([image_padding,0,-.5]) 
    difference() {
        cube([image_width, image_length, 1]);
        translate([1,1,-0.5]) cube([image_width-2, image_length-2, 2]);
    }
}

module hinge_m() {
    difference () {
    	rotate([0,45,0]) union(){
            translate([0,0,-nub]) cube ([nub*3,nub*2, nub*2]);
            rotate([90,0,0]) {
                translate([0,0,-2*nub]) cylinder(r=nub,h=2*nub);
    		    cylinder(r1=nub,r2=0,h=nub);
            }
    	}
        translate([-nub,-nub/2,-handle_height-nub*5]) cube([nub*5, nub*3, nub*5]);
    }
}

module hinge_f() {
    len = handle_width/2 - 3*nub - 2*tol;
    
    difference() {
        rotate([90,-45,0]) 
        difference() {
            union() {
                cylinder(r=nub, h=len);
                translate([-3*nub,-nub,0]) cube([nub*3,nub*2,len]);
            }
            translate([0,0,-0.1]) cylinder(r1=nub+tol,r2=0,h=nub);
            translate([0,0,len-nub+0.1]) cylinder(r1=0,r2=nub+tol,h=nub);
        }
        translate([-nub*4,-len-nub/2,-handle_height-nub*5]) cube([nub*5, len+nub, nub*5]);
    }
}

module plate() {
    scale([(image_width)/100,(image_length)/100,emboss_height])
        surface(file=image_file, center=true, convexity=5);
}
