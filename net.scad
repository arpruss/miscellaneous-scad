print_shim = false;

horizontal_spacing = 11.2;
vertical_spacing = 1.6;
tolerance = 0.7;
net_rim = 6;
net_thickness = 0.35;
layer_height = 0.35;
wall_thickness = 1;
wall_height = 12;
tab_size = 12;
base_thickness = 1.5;
base_width = 192;
base_height = 71.8;
corner_radius = 29.2;

catch_width = 8;
catch_height = 5;
catch_stickout = 1.25;
catch_from_top = 1;
catch_separation = 1.6;
catch_cutaway_start = 2;

shim_tolerance = 0.0;
shim_size = 4;

module dummy() {} // for customizer

width = base_width-tolerance*2;
height = base_height-tolerance*2;

xsize = width;
ysize = height;
nudge = 0.01;

module netRectangle() {
    render(convexity=12)
    linear_extrude(height=net_thickness*3) 
    for (i=[0:xsize/horizontal_spacing]) {
        translate([horizontal_spacing*i,0,0]) square([layer_height*3,ysize]);
    }

    render(convexity=12)
    translate([0,0,net_thickness-nudge])
    linear_extrude(height=net_thickness+nudge) 
    for (i=[0:ysize/vertical_spacing]) {
        translate([0,vertical_spacing*i,layer_height]) 
        square([xsize,net_thickness]);
    }
}

/*module oval(inset) {
   translate([height/2,height/2]) circle(d=height-2*inset);
   translate([width-height/2,height/2]) circle(d=height-2*inset);
   translate([height/2,inset]) square(size=[width-height,height-inset*2]);
}*/

module oval(inset) {
    for (i=[0:1]) {
        dx = (width-2*corner_radius-2*inset)*i;
        translate([dx+corner_radius+inset,corner_radius+inset]) circle(r=corner_radius, $fn=50);
        translate([dx+corner_radius+inset,height-corner_radius-inset]) circle(r=corner_radius, $fn=50);
        translate([dx+inset,corner_radius+inset]) square([corner_radius*2,height-2*inset-2*corner_radius]);
    }
    translate([corner_radius+inset,inset]) square([width-2*inset-2*corner_radius,height-2*inset]);
}

module netOval() {
    intersection() {
        netRectangle();
        translate([0,0,-nudge]) linear_extrude(height=wall_height) oval(net_rim-nudge);
    }
}

module base() {
    linear_extrude(height=base_thickness) difference() {
        oval(0);
        oval(net_rim);
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
        translate([0,height/2-catch_width/2-catch_separation,0]) catchCut();
        translate([0,height/2+catch_width/2,0]) catchCut();
        translate([width-3*wall_thickness-nudge,height/2-catch_width/2-catch_separation,0]) catchCut();
        translate([width-3*wall_thickness-nudge,height/2+catch_width/2,0]) catchCut();
    }
}

module filled() {
    linear_extrude(height=wall_height) oval(0);
}

module tab1() {
    rotate([-90,0,0]) linear_extrude(height=height) polygon(points=[[0,0],[0,tab_size],[tab_size,0]]);
}

module tabs() {
    inset=(sqrt(2)-1)*corner_radius/sqrt(2);
    render(convexity=10)
    intersection() 
    {
        filled();
        union() {
            rotate([0,0,45])
            translate([inset,-height/2,wall_height])
            tab1();
            translate([width,height-inset,0])
            rotate([0,0,180+45])
            translate([0,-height/2,wall_height])
            tab1();
        }
    }
}

/*
module topnet_rim() {
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
}*/

module catch() {
    b = catch_height/2;
    // b^2 + (r - catch_stickout)^2 = r^2
    // b^2 + r^2 + cs^2 - 2 r cs = r^2
    // b^2 + cs^2 = 2r cs
    // r = (b^2 + cs^2) / 2cs
    corner_radius = (b*b + catch_stickout*catch_stickout) / (2*catch_stickout);
    translate([0,0,catch_height/2+wall_height-catch_height-catch_from_top])
    rotate([90,0,0])
    intersection() {
    render(convexity=10)
        translate([corner_radius-catch_stickout,0,0]) cylinder(r=corner_radius, h=catch_width, $fn=16);
    render(convexity=10)
        translate([-corner_radius*2,-corner_radius,0]) cube([corner_radius*2, corner_radius*2, catch_width]); 
    }
}

module catches() {
    translate([0,height/2+catch_width/2,0])
    catch();
    translate([width,height/2-catch_width/2,0]) rotate([0,0,180]) catch();
}

if (print_shim) {
    intersection() {
        minkowski() 
        {
            linear_extrude(height=nudge) difference() {
                oval(wall_thickness+shim_tolerance);
                oval(wall_thickness+shim_tolerance+nudge);
            }
            cylinder(r1=shim_size, r2=0, h=shim_size);
        }
        render(convexity=10)
        translate([0,0,-nudge]) linear_extrude(height=shim_size+nudge*2) oval(wall_thickness+tolerance);
    }
}
else {
    netOval();
    base();
    sides();
    tabs();
    catches();
}
