xspacing = 3*1.4;
yspacing = 1.6;

outerwidth = 200;
outerheight = 100;
radius = 20;
rim = 5;

base_thickness = 1.5;
net_thickness = 0.5;
net_offset = 0.4;
xsize = outerwidth;
ysize = outerheight;
nudge = 0.01;
wall_thickness = 1;
wall_height = 20;
catch_size = 10;

module netRectangle() {
    for (i=[0:xsize/xspacing]) {
        translate([xspacing*i,0]) square([net_thickness,ysize]);
    }

    for (i=[0:ysize/yspacing]) {
        translate([0,yspacing*i]) square([xsize,net_thickness]);
    }
}

module oval(inset) {
   translate([outerheight/2,outerheight/2]) circle(d=outerheight-2*inset);
   translate([outerwidth-outerheight/2,outerheight/2]) circle(d=outerheight-2*inset);
   translate([outerheight/2,inset]) square(size=[outerwidth-outerheight,outerheight-inset*2]);
}

module betterOval(inset) {
    translate([radius+inset,radius+inset]) circle(r=radius);
    translate([radius+inset,outerheight-radius-inset]) circle(r=radius);
    translate([inset,radius+inset])
    square([radius*2,outerheight-2*inset-2*radius]);
}

module netOval() {
    intersection() {
        netRectangle();
        oval(rim-nudge);
    }
}

module net() {
    translate([0,0,net_offset]) linear_extrude(height=net_thickness) netOval();
}  

module base() {
    linear_extrude(height=base_thickness) difference() {
        oval(0);
        oval(rim);
    }
}

module sides() {
    linear_extrude(height=wall_height) difference() {
        oval(0);
        oval(wall_thickness);
    }
}

module filled() {
    linear_extrude(height=wall_height) oval(0);
}

module catch1() {
    rotate([-90,0,0]) linear_extrude(height=4*catch_size) polygon(points=[[0,0],[0,catch_size],[catch_size,0]]);
}

module catches() {
    intersection() 
    {
        filled();
        union() {
            translate([0,outerheight/2-catch_size*2,wall_height])
            catch1();
            translate([outerwidth,outerheight/2+catch_size*2,wall_height])
            rotate([0,0,180]) catch1();
        }
    }
}

//net();
//base();
//sides();
//catches();
betterOval(0);