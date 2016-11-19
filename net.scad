xspacing = 8*1.4;
yspacing = 1.6;

tolerance = 0.7;

outerwidth = 192-tolerance*2;
outerheight = 71.8-tolerance*2;
radius = 28.5;
rim = 6;

catch_width = 11;
catch_height = 5;
catch_stickout = 1.5;
catch_from_top = 1;
catch_separation = 1.6;
catch_cutaway_start = 2;

base_thickness = 1.5;
net_thickness = 0.35;
layer_height = 0.35;
xsize = outerwidth;
ysize = outerheight;
nudge = 0.01;
wall_thickness = 1;
wall_height = 15;
tab_size = 12;

module netRectangle() {
    render(convexity=12)
    linear_extrude(height=net_thickness*3) 
    for (i=[0:xsize/xspacing]) {
        translate([xspacing*i,0,0]) square([layer_height*3,ysize]);
    }

    render(convexity=12)
    translate([0,0,net_thickness-nudge])
    linear_extrude(height=net_thickness+nudge) 
    for (i=[0:ysize/yspacing]) {
        translate([0,yspacing*i,layer_height]) 
        square([xsize,net_thickness]);
    }
}

/*module oval(inset) {
   translate([outerheight/2,outerheight/2]) circle(d=outerheight-2*inset);
   translate([outerwidth-outerheight/2,outerheight/2]) circle(d=outerheight-2*inset);
   translate([outerheight/2,inset]) square(size=[outerwidth-outerheight,outerheight-inset*2]);
}*/

module oval(inset) {
    for (i=[0:1]) {
        dx = (outerwidth-2*radius-2*inset)*i;
        translate([dx+radius+inset,radius+inset]) circle(r=radius);
        translate([dx+radius+inset,outerheight-radius-inset]) circle(r=radius);
        translate([dx+inset,radius+inset]) square([radius*2,outerheight-2*inset-2*radius]);
    }
    translate([radius+inset,inset]) square([outerwidth-2*inset-2*radius,outerheight-2*inset]);
}

module netOval() {
    intersection() {
        netRectangle();
        translate([0,0,-nudge]) linear_extrude(height=wall_height) oval(rim-nudge);
    }
}

module base() {
    linear_extrude(height=base_thickness) difference() {
        oval(0);
        oval(rim);
    }
}

module catchCut() {
    translate([0,0,base_thickness+catch_cutaway_start]) cube([wall_thickness*4, catch_separation, wall_height-(base_thickness+catch_cutaway_start)+nudge]);
}

module sides() {
    render(convexity=10)
    difference() {
        linear_extrude(height=wall_height) difference() {
            oval(0);
            oval(wall_thickness);
        }
        translate([0,outerheight/2-catch_width/2-catch_separation,0]) catchCut();
        translate([0,outerheight/2+catch_width/2,0]) catchCut();
        translate([outerwidth-3*wall_thickness-nudge,outerheight/2-catch_width/2-catch_separation,0]) catchCut();
        translate([outerwidth-3*wall_thickness-nudge,outerheight/2+catch_width/2,0]) catchCut();
    }
}

module filled() {
    linear_extrude(height=wall_height) oval(0);
}

module tab1() {
    rotate([-90,0,0]) linear_extrude(height=outerheight) polygon(points=[[0,0],[0,tab_size],[tab_size,0]]);
}

module tabs() {
    inset=(sqrt(2)-1)*radius/sqrt(2);
    render(convexity=10)
    intersection() 
    {
        filled();
        union() {
            rotate([0,0,45])
            translate([inset,-outerheight/2,wall_height])
            tab1();
            translate([outerwidth,outerheight-inset,0])
            rotate([0,0,180+45])
            translate([0,-outerheight/2,wall_height])
            tab1();
        }
    }
}

module topRim() {
    difference() {
        translate([0,0,wall_height-2])
        minkowski()
        {
            linear_extrude(height=0.01)
            difference() {
                oval(0);
                oval(1);
            }
            cylinder(h=2,r1=0,r2=2);
        }
        linear_extrude(height=wall_height+0.01+nudge) oval(0);
    }
}

module catch() {
    b = catch_height/2;
    // b^2 + (r - catch_stickout)^2 = r^2
    // b^2 + r^2 + cs^2 - 2 r cs = r^2
    // b^2 + cs^2 = 2r cs
    // r = (b^2 + cs^2) / 2cs
    radius = (b*b + catch_stickout*catch_stickout) / (2*catch_stickout);
    translate([0,0,catch_height/2+wall_height-catch_height-catch_from_top])
    rotate([90,0,0])
    intersection() {
    render(convexity=10)
        translate([radius-catch_stickout,0,0]) cylinder(r=radius, h=catch_width, $fn=16);
    render(convexity=10)
        translate([-radius*2,-radius,0]) cube([radius*2, radius*2, catch_width]); 
    }
}

module catches() {
    translate([0,outerheight/2+catch_width/2,0])
    catch();
    translate([outerwidth,outerheight/2-catch_width/2,0]) rotate([0,0,180]) catch();
}


netOval();
base();
sides();
tabs();
catches();
//topRim();
