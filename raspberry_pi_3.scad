//
// raspberry pi model B+
//
// design by Egil Kvaleberg, 8 Aug 2015
// Raspberrypi 3 adapt by Guy Sheffer 28 Apr 2016
//
//https://www.thingiverse.com/thing:1525669
//
// CC-BY-3.0
//
// drawing of the B+ model, for referrence:
// https://www.raspberrypi.org/documentation/hardware/raspberrypi/mechanical/Raspberry-Pi-B-Plus-V1.2-Mechanical-Drawing.pdf
//
// notes:
// design origin is middle of PCB
//

part = "all"; // [ top, bottom, all, demo ]

have_plugrow = 0; // [ 1:true, 0:false ]
have_open_plugrow = 0; // [ 1:true, 0:false ]
have_camera = 0; // [ 1:true, 0:false ]
have_sdcard_support = 1; // [ 1:true, 0:false ]
have_leds = 1; // [ 1:true, 0:false ]
floor_extra = 5;
ceiling_extra = 4;
ceiling_holes = 0; // [1:true, 0:false ]
wings_width = 10;
wings_thickness = 1.5;
wings_screw_hole_diameter = 0;
have_ventilation = 1; // [1:true, 0:false]
ventilate_hole_width = 4;
ventilate_strip_width = 3;

/* [Hidden] */
mil2mm = 0.0254;

pcb = [85.0, 56.0, 1.5]; // main board
pcb2floor = 4.0 + floor_extra; // 3.5
pcb2roof = 17.0 + ceiling_extra; // 15.7

pcbmntdia = 2.75; // mounting holes
pcbmnt1dx = pcb[0]/2 - 3.5;  // 
pcbmnt1dy = 3.5 - pcb[1]/2;
pcbmnt2dx = pcb[0]/2 - 3.5 - 58.0; // 
pcbmnt2dy = pcb[1]/2 - 3.5;
pcbmnthead = 6.2; // countersunk
pcbmntthreads = 2.2;
breakaway = 0.3; // have hidden hole for screw, 0 for no extra pegs 

cardsy = 12.0; // card measures 11.0
cardsz = 3.1;
cardsx = 8.0; // size of internal platform
carddy = pcb[1]/2 - 28.0;
ethersy = 16.0; // ethernet contact width
ethersz = 13.5 + 0.5;
etherdy = pcb[1]/2 - 10.25;
usbsy = 13.5; // core
usbframe = 1.0; // frame
usbsz = 15.8 + 0.5;
usb1dy = pcb[1]/2 - 29.0;
usb2dy = pcb[1]/2 - 47.0;
powerpsx = 11.0; // power plug width 
powerpsz = 4.5; // plug height
powerssx = 8.0; // power socket width 
powerssz = 3.3; // socket height
powerdz = -1.7; // for plug 
powerdx = pcb[0]/2 - 10.6; // 
hdmisx = 15.2; // hdmi contact width
hdmisz = 6.2;
hdmipsx = 25.0; // typical plug
hdmipsz = 12.0;
hdmidx = pcb[0]/2 - 32.0;
audior = 7.0; // audio contact radius
audiodz = 6.0/2; // above pcb
audiodx = pcb[0]/2 -53.5;
leddx = pcb[0]/2 - 1.3;
led1dy = -8.9 + 2.4/2  + pcb[1]/2;
led2dy = -12.9 + 2.4/2 + pcb[1]/2 - 0.2;
leddia = 2.0;
// BUG: fine tune, maybe add slot out of box
plugrow1 = [pcb[0]/2 - 29.0 - mil2mm*100*11, 3.5 - pcb[1]/2, 0]; // coordinates D7 pin, mid

cam_box = 34.5;

frame_w = 2.5; // width of lip for frame 
snap_dia = 1.8; // snap lock ridge diameter
snap_len = 50.0; // snap lock length
tol = 0.5; // general tolerance

wall = 1.2; // general wall thickness
thinwall = 0.4;
corner_r = wall; // casing corner radius
corner2_r = wall+tol+wall; // corners of top casing
d = 0.01;

extra_y = 0; // extra space in y

module nut(af, h) { // af is 2*r
	cylinder(r=af/2/cos(30), h=h, $fn=6);
}

module c_cube(x, y, z) {
	translate([-x/2, -y/2, 0]) cube([x, y, z]);
}

module cr_cube(x, y, z, r) {
	hull() {
		for (dx=[-1,1]) for (dy=[-1,1]) translate([dx*(x/2-r), dy*(y/2-r), 0]) cylinder(r=r, h=z, $fn=20);
	}
}

module cr2_cube(x, y, z, r1, r2) {
	hull() {
		for (dx=[-1,1]) for (dy=[-1,1]) translate([dx*(x/2-r1), dy*(y/2-r1), 0]) cylinder(r1=r1, r2=r2, h=z, $fn=20);
	}
}

module bottom() {
        module pedestal(dx, dy, hg, dia) {
            translate([dx, dy, wall]) {
				cylinder(r = dia/2+wall, h = hg, $fs=0.2);
                // pegs through pcb mount holes
                if (breakaway > 0) translate([0, 0, hg]) 
                        cylinder(r = dia/2 - tol, h = pcb[2]+d, $fs=0.2);
            }
        }
	module snap2(ex, both) {
		if (both) translate([pcb[0]/2+tol+wall+ex, -snap_len/2, wall+pcb2floor+pcb[2]-frame_w/2]) rotate([-90, 0, 0]) cylinder(r=snap_dia/2, h=snap_len, $fs=0.3);
		if (both) translate([-snap_len/2, pcb[1]/2+tol+wall, wall+pcb2floor+pcb[2]-frame_w/2]) rotate([0, 90, 0]) cylinder(r=snap_dia/2, h=snap_len, $fs=0.3);
	}
    module plugs(extra) { 
        z0 = wall+pcb2floor+pcb[2];
        // card slot
        translate([pcb[0]/2 - cardsx/2, carddy, wall+pcb2floor+pcb[2]-cardsz-extra]) 
			c_cube(cardsx + 19.9, cardsy+2*extra, cardsz+2*extra);
        // power plug (near side)
        translate([powerdx, pcb[1]/2+2.1*wall, z0+powerdz-extra]) 
			c_cube(powerpsx+2*extra, 2*wall, powerpsz+2*extra+frame_w);
        // hdmi socket (near side)
        translate([hdmidx, pcb[1]/2+19.9/2-8.25/2, -extra-frame_w]) 
			c_cube(hdmipsx+2*extra, 8.25, hdmipsz+2*extra+frame_w);    
    }
    module plugs_add() { 
        z0 = wall+pcb2floor+pcb[2];
        // audio plug (near side)
        difference() /*/ color("green")*/ {
            translate([audiodx, pcb[1]/2 + 1.4*wall, z0-snap_dia/2-tol]) 
                c_cube(audior, 1.6*wall, audiodz+snap_dia);
            translate([audiodx, pcb[1]/2 + wall/2 - d, z0+audiodz]) 
                rotate([-90, 0, 0]) cylinder(r=audior/2+tol, h=1.8*wall+2*d, $fn=20);
        }
        // card slot
        if (have_sdcard_support) difference () {
            translate([pcb[0]/2 + tol + d - cardsx/2, carddy, 0]) 
                c_cube(cardsx, cardsy+2*tol+2*wall, wall+frame_w-tol);
            plugs(tol);
        }
    }

	module add() {
        if (have_ventilation) for (dx = [pcbmnt1dx,pcbmnt2dx]) for (dy = [pcbmnt1dy,pcbmnt2dy]) 
                pedestal(dx, dy, pcb2floor, pcbmntdia);
		difference() {
        hull () for (x = [-1, 1]) for (y = [-1, 1])
			translate([x*(pcb[0]/2+tol+wall-corner_r) + (x>0 ? extra_y : 0), y*(pcb[1]/2+tol+wall-corner_r), corner_r]) {
				sphere(r = corner_r, $fs=0.3);
				cylinder(r = corner_r, h = wall+pcb2floor+pcb[2]-corner_r, $fs=0.3);
		}
        
        if (have_ventilation) {
            translate([-pcb[0]/2+2*wall,50,wall]) rotate([90,0,0]) linear_extrude(height=100) ventilate(pcb[0]-4*wall,wall+pcb2floor+pcb[2]-corner_r-2*wall);
            
        }
        }
        
		snap2(0, true);
        rotate([0, 0, 180]) snap2(0, false);
	}
    
	module sub() {
        module pedestal_hole(dx, dy, hg, dia) {
            translate([dx, dy, breakaway]) {	
				cylinder(r = dia/2, h = wall+hg-2*breakaway, $fs=0.2);
				cylinder(r = 1.0/2, h = wall+hg+pcb[2]+d, $fs=0.2); // needed to 'expose' internal structure so it dows not get removed
				cylinder(r1 = pcbmnthead/2 - breakaway, r2 = 0, h = pcbmnthead/2 - breakaway, $fs=0.2); // countersunk head
		    }
        }
		difference () {
			// pcb itself
			translate([-(pcb[0]/2+tol), -(pcb[1]/2+tol), wall])
				cube([2*tol+pcb[0], 2*tol+pcb[1], pcb2floor+pcb[2]+d]);
			// less pcb mount pedestals 
            for (dx = [pcbmnt1dx,pcbmnt2dx]) for (dy = [pcbmnt1dy,pcbmnt2dy]) 
                pedestal(dx, dy, pcb2floor, pcbmntdia);
		}
		// hole for countersunk pcb mounting screws, hidden (can be broken away)
        for (dx = [pcbmnt1dx,pcbmnt2dx]) for (dy = [pcbmnt1dy,pcbmnt2dy]) 
            pedestal_hole(dx, dy, pcb2floor, pcbmntdia);
        plugs(tol);
	}
	difference () {
		add();
		sub();
	}
    plugs_add();
    
    //color("red") plugs(0);
    module wing() {
        l = pcb[0];
        
        linear_extrude(height=wings_thickness) {
                polygon([
                       [-l/2,0], [-l/2+wings_width,-wings_width], [l/2-wings_width,-wings_width],[l/2,0]]);
            }
        }
    if (wings_thickness>0 && wings_width>0) {
        for(a=[0,180]) rotate([0,0,a])
        translate([0,-pcb[1]/2])
        wing();
    }
}

module ventilate(w,h) {
    delta = ventilate_strip_width+ventilate_hole_width;
    for (x=[0:delta:w-ventilate_hole_width+0.001]) {
        translate([x,0])
            square([ventilate_hole_width,h]);
    }
}

// Z base is top of pcb
module top() {
	module snap2(ex, both) {
		if (both) translate([pcb[0]/2+tol+wall+ex, -snap_len/2-tol, -frame_w/2]) rotate([-90, 0, 0]) cylinder(r=snap_dia/2, h=snap_len+2*tol, $fs=0.3);
		translate([-snap_len/2-tol, pcb[1]/2+tol+wall, -frame_w/2]) rotate([0, 90, 0]) cylinder(r=snap_dia/2, h=snap_len+2*tol, $fs=0.3);
	}
    module plugs(extra) { 
        module usb_plug(dy) {
            translate([-pcb[0]/2, dy, -extra-frame_w]) 
				c_cube(19.9, usbsy+2*extra, usbsz+2*extra+frame_w);
            translate([-pcb[0]/2 -19.9/2, dy, -extra-frame_w]) 
				c_cube(19.9, usbsy+2*usbframe+2*extra, usbsz+2*extra+frame_w+2*usbframe/2);
        }
        // card slot
        translate([pcb[0]/2, carddy, -cardsz-extra - 1.2]) // fudge 
			c_cube(19.9, cardsy+2*extra, cardsz+2*extra);
        // power socket (near side)
        translate([powerdx, pcb[1]/2, -extra-frame_w]) 
			c_cube(powerssx+2*extra, 19.9, powerssz+2*extra+frame_w);
        // room for power plug
        translate([powerdx, pcb[1]/2+9.9/2+wall*1.4, -extra-frame_w]) 
			c_cube(powerpsx+2*extra, 9.9, powerpsz+2*extra+frame_w);
       // ether plug 
        translate([-pcb[0]/2, etherdy, -extra-frame_w]) 
			c_cube(19.9, ethersy+2*extra, ethersz+2*extra+frame_w); // use half tol horizontally, seems to be enough
       // usb plugs
       usb_plug(usb1dy);
       usb_plug(usb2dy);
        // hdmi socket (near side)
        translate([hdmidx, pcb[1]/2, -extra-frame_w]) 
			c_cube(hdmisx+2*extra, 19.9, hdmisz+2*extra+frame_w);
        translate([hdmidx, pcb[1]/2+19.9/2-7.8/2, -extra-frame_w]) 
			c_cube(hdmipsx+2*extra, 7.8, hdmipsz+2*extra+frame_w);
        // audio plug (near side)
        translate([audiodx, pcb[1]/2 + 19.9/2, audiodz]) 
			rotate([90, 0, 0]) cylinder(r=audior/2+extra, h=19.9, $fn=20);
        translate([audiodx, pcb[1]/2, -extra-frame_w]) 
			c_cube(audior+2*extra, 19.9, audiodz+2*extra+frame_w);
        // camera opening
        if (have_camera) translate([-8.0, 0, pcb2roof - extra]) 
			c_cube(cam_box, cam_box, wall+2*extra);
    }

	module add() {
        difference() {
            hull () for (x = [-1, 1]) for (y = [-1, 1]) {
                translate([x*(pcb[0]/2+tol+wall-corner_r) + (x>0 ? extra_y : 0), y*(pcb[1]/2+tol+wall-corner_r), -frame_w]) 
                    cylinder(r = corner_r+tol+wall, h = d, $fs=0.3); // include frame
                translate([x*(pcb[0]/2+tol+wall-corner2_r) + (x>0 ? extra_y : 0), y*(pcb[1]/2+tol+wall-corner2_r), pcb2roof+wall-corner2_r]) 
                        sphere(r = corner2_r, $fs=0.3);	
            }
        if (have_ventilation) {
           w1 = pcbmnt1dx-pcbmnt2dx-pcbmntdia-4*wall;
           h1 = pcb2roof+wall-corner2_r+frame_w-12;
            translate([pcbmnt2dx+2*wall+pcbmntdia/2,50,-frame_w+12]) rotate([90,0,0]) linear_extrude(height=100) ventilate(w1,h1);
        }
        }
    
	}

	module sub() { 
		module plugrow_frame(xy, start, pins) {
			frmheight = 3.0;
            echo((pcb[1]/2+xy[1]));
			if (have_open_plugrow) translate([xy[0]+(start+(pins-1)/2)*2.56, xy[1]-(pcb[1]/2+xy[1]-2.56)/2, 1.0]) 
				c_cube(pins*2.56+2*tol+2*wall, (pcb[1]/2+xy[1]-2.56)+2*2.56+2*tol+2*wall, pcb2roof-1.0);
            else translate([xy[0]+(start+(pins-1)/2)*2.56, xy[1], frmheight]) 
				c_cube(pins*2.56+2*tol+2*wall, 2*2.56+2*tol+2*wall, pcb2roof-frmheight);
            
       }
		module plugrow_hole(xy, start, pins) {
            if (have_open_plugrow) translate([xy[0]+(start+(pins-1)/2)*2.56, xy[1]-9.9/2, -frame_w-d]) 
				c_cube(pins*2.56+2*tol, 2*2.56+2*tol+9.9, pcb2roof+wall+pcb[0]+frame_w);
			else translate([xy[0]+(start+(pins-1)/2)*2.56, xy[1], 0]) 
				c_cube(pins*2.56+2*tol, 2*2.56+2*tol, pcb2roof+wall);
        }
        module led_frame(dy) {
			frmheight = 2.0;
			translate([leddx, dy, frmheight]) 
				cylinder(r=leddia/2+wall, h=pcb2roof+d-frmheight, $fn=16);
        }
        module led_hole(dy) {
			translate([leddx, dy, 0]) 
				cylinder(r=leddia/2-d, h=pcb2roof+wall+d, $fn=16);
            
        }
		// room for bottom case within frame 
		hull () for (x = [-1, 1]) for (y = [-1, 1])
			translate([x*(pcb[0]/2+tol+wall-corner_r) + (x>0 ? extra_y : 0), y*(pcb[1]/2+tol+wall-corner_r), -frame_w-d]) 
                cylinder(r = corner_r+tol, h = d+frame_w, $fs=0.3); 
		// snap lock
		snap2(0, true);
		rotate([0, 0, 180]) snap2(0, false);
		difference() { 
			// room for pcb
			translate([0, 0, -d]) cr_cube(2*tol+pcb[0], 2*tol+pcb[1], d+pcb2roof, 1.0);
			union () { // subtract from pcb:
				// plug rows
				if (have_plugrow || have_open_plugrow) 
					plugrow_frame(plugrow1, 0, 20);
                // leds
				if (have_leds) {
					led_frame(led1dy);
                    led_frame(led2dy);
                }
                // strengthing frame around usb and ether
                translate([-pcb[0]/2, 0, tol]) 
				c_cube(19.9-2*d, pcb[1]+2*tol+2*d, usbsz+2*tol+frame_w);
                
                // pegs
                for (dx = [pcbmnt1dx,pcbmnt2dx]) for (dy = [pcbmnt1dy,pcbmnt2dy]) translate([dx, dy, 0]) {
                    cylinder(r1 = pcbmntdia/2 +wall, r2 = pcbmntdia/2 +2.5*wall, h = pcb2roof, $fs=0.2);
                }   
			}

		}
        // hole for usb, ether and power
        plugs(tol);
		// plug rows
		if (have_plugrow || have_open_plugrow) 
			plugrow_hole(plugrow1, 0, 20);
        // leds
		if (have_leds) {
			led_hole(led1dy);
            led_hole(led2dy);
        }
        // peg holes
        for (dx = [pcbmnt1dx,pcbmnt2dx]) for (dy = [pcbmnt1dy,pcbmnt2dy]) translate([dx, dy, 0]) {
            translate([0, 0, -d]) cylinder(r = pcbmntthreads/2, h = pcb2roof, $fs=0.2); // hole
        }
        if (have_ventilation) {
            x0 = -pcb[0]/2+19.9/2; // pcbmnt2dx+pcbmntdia/2 +2*wall;
            y0 = pcbmnt1dy+pcbmntdia/2 +3*wall;
            x1 = pcbmnt1dx-pcbmntdia/2 -2*wall;
            y1 = pcbmnt2dy-pcbmntdia/2 -2*wall;
            translate([x0,y0,-100]) linear_extrude(height=200) ventilate(x1-x0,y1-y0);
        }
	}
	difference () {
		add();
		sub();
	}
    
    if (part == "demo") 
        color("red") plugs(0); 
} 


//

if (part=="demo") { bottom(); translate([0, 0, wall+pcb2floor+pcb[2]]) top(); }
if (part=="bottom" || part=="all") translate([0, -35-wings_width, 0]) bottom();
if (part=="top" || part=="all") translate([-0, 35, pcb2roof+tol+wall]) rotate([180,0,0]) top();

	