/*
Name: OpenSCAD model of a ramps box
Author: Jons Collasius from Germany/Hamburg
Modified: Alexander Pruss

License: CC BY-NC-SA 3.0
License URL: https://creativecommons.org/licenses/by-nc-sa/3.0/
*/

cylinderfn = 0.2;
wall_width = 1.75;

ventilationHole = 22;
bigHoleDiameter = 10.5;
bigHoleStickout = 8;
bigHoleZ = 39;
bigHoleY = 60;
ramps_xtra = 0;
ramps_x = 60.50;	
ramps_y = 101.62+9; // +9mm for lcd "smart adapter"
ramps_z = 44.5;
ramps_z_spacing = 5;
ramps_doubleopening = true;
ramps_makefanhole = true;
ramps_doubleopening_z_from_pcb_bottom = 27;
m3_r	 = 0; //3.2/2;
m3_nut_r	= (6.08+0.2)/2;
m3_nut_hight	= 2.4+0.5;

metallscrew_r = 0; // 2.8/2;

fan_r = 60/2;
fan_screws_r = 4.4/2;
fan_offset_screws = 50/2;

nudge = 0.01;

rampsbox();

//translate([0,0,ramps_z+wall_width*2]) rampslid();

module rampslid() {
	difference() {
		cnccube(x=ramps_x+ramps_xtra*2, y=ramps_y+ramps_xtra*2, z=0, r=m3_r+wall_width, w=wall_width);
		if (ramps_doubleopening && ramps_makefanhole) {
			translate([ramps_x/2+ramps_xtra,ramps_xtra+60.45-fan_r/2,-1])
			fancuts(r_fan=fan_r, r_screws=fan_screws_r, offset_screws=fan_offset_screws, h=wall_width+2);
		}
	}
}

module rampsbox() {
	difference() {
		union() {
			cnccube(x=ramps_x+ramps_xtra*2, y=ramps_y+ramps_xtra*2, z=ramps_z, r=m3_r+wall_width, w=wall_width);
			translate([ramps_xtra,ramps_xtra,0]) rampsmount(r=metallscrew_r+wall_width, h=ramps_z_spacing+wall_width);
    d = bigHoleDiameter+2*wall_width;
    x = -bigHoleStickout-metallscrew_r*2-wall_width;
    translate([x,bigHoleY-d/2,bigHoleZ-d/2]) cube([bigHoleStickout,d,d+nudge]);
    translate([x,bigHoleY,bigHoleZ]) rotate([0,90,0]) cylinder(d=d,h=bigHoleStickout);
    translate([x+bigHoleStickout,bigHoleY+d/2,bigHoleZ-d/2+nudge]) 
            rotate([90,0,0])
            linear_extrude(height=d) polygon([[0,0],[-bigHoleStickout,0],[0,-bigHoleStickout]]);
		}
		translate([ramps_xtra,ramps_xtra,-1]) rampsmount(r=metallscrew_r, h=ramps_z_spacing+wall_width+2);

		if (ramps_doubleopening == false && ramps_makefanhole) {
			translate([ramps_x/2+ramps_xtra,ramps_y+ramps_xtra*2,ramps_z/2+wall_width]) rotate([-90,0,0]) fancuts(r_fan=fan_r, r_screws=fan_screws_r, offset_screws=fan_offset_screws, h=(m3_r+wall_width)*2);
		}
		translate([ramps_xtra,ramps_xtra,wall_width+ramps_z_spacing]) rampscuts();
	}
}

module rampscuts() {
	translate([0,0,0]) cube([ramps_x,ramps_y,1.5]);
	translate([8.26,-ramps_xtra-m3_r*2-wall_width*2-1,0.5]) cube([14.11,ramps_xtra+m3_r*2+wall_width*2+2,ramps_z]);
	translate([0,-ramps_xtra-m3_r*2-wall_width*2-1,14]) cube([ramps_x,ramps_xtra+m3_r*2+wall_width*2+2,ramps_z]);
    // this starts in the reset hole position
    for (i=[0:2]) 
	translate([i==1?10:-10,31.77+7.33/2+i*(ventilationHole+5),14.4+7.33/2]) rotate([0,90,0]) cylinder(d=ventilationHole,h=300);
    translate([-50,bigHoleY,bigHoleZ-(wall_width+ramps_z_spacing)]) rotate([0,90,0]) cylinder(d=bigHoleDiameter,h=51);
	if (ramps_doubleopening) {
		translate([1.35,ramps_y+ramps_xtra-1,ramps_doubleopening_z_from_pcb_bottom]) cube([ramps_x-1.35*2,ramps_xtra+m3_r*2+wall_width*2+2,ramps_z]);	
	}
}

module rampsmount(r=1.6, h=10) {
	translate([2.64,15.16,0]) fncylinder(r=r, h=h); // bottom left
	translate([50.85,13.92,0]) fncylinder(r=r, h=h); // bottom right
	translate([17.73,65.9,0]) fncylinder(r=r, h=h); // center left
	translate([45.64,65.9,0]) fncylinder(r=r, h=h); // center right
	translate([2.5,90.07,0]) fncylinder(r=r, h=h); // top left
	translate([50.85,96.39,0]) fncylinder(r=r, h=h); // top right
}

module fancuts(r_fan=60/2, r_screws=4.3/2, offset_screws=50/2, h=20) {
	translate([0,0,0]) fncylinder(r=r_fan, h=h);
	for(i = [0 : 3]) {
		rotate([0,0,90*i]) translate([offset_screws,offset_screws,0]) fncylinder(r=r_screws, h=h);
	}
}

module cnccube(x=10, y=10, z=10, r=1.5, w=2) {
	difference() {
		union() {
			translate([-r*1.5,-r*1.5,0]) cube([x+r*3,y+r*3,z+wall_width]);
			translate([-r,-r,0]) fncylinder(r=r, h=z+wall_width);
			translate([-r,y+r,0]) fncylinder(r=r, h=z+wall_width);
			translate([x+r,-r,0]) fncylinder(r=r, h=z+wall_width);
			translate([x+r,y+r,0]) fncylinder(r=r, h=z+wall_width);
		}
		difference() {
			translate([-r*1.5+w,-r*1.5+w,w]) cube([x+r*3-w*2,y+r*3-w*2,z+wall_width]);
			translate([-r,-r,0]) fncylinder(r=r, h=z+wall_width);
			translate([-r,y+r,0]) fncylinder(r=r, h=z+wall_width);
			translate([x+r,-r,0]) fncylinder(r=r, h=z+wall_width);
			translate([x+r,y+r,0]) fncylinder(r=r, h=z+wall_width);
		}
		translate([-r,-r,z+wall_width-30]) fncylinder(r=metallscrew_r, h=31);
		translate([-r,y+r,z+wall_width-30]) fncylinder(r=metallscrew_r, h=31);
		translate([x+r,-r,z+wall_width-30]) fncylinder(r=metallscrew_r, h=31);
		translate([x+r,y+r,z+wall_width-30]) fncylinder(r=metallscrew_r, h=31);
	}
}

module fncylinder(r,h){
	cylinder(r=r,h=h,$fn=2*r*3.14/cylinderfn);
}
