xspacing = 8*1.4;
yspacing = 1.6;

outerwidth = 200;
outerheight = 100;
radius = 20;
rim = 10;

base_thickness = 1.5;
net_thickness = 0.35;
layer_height = 0.35;
xsize = outerwidth;
ysize = outerheight;
nudge = 0.01;
wall_thickness = 1;
wall_height = 15;
catch_size = 10;

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
    rotate([-90,0,0]) linear_extrude(height=outerheight) polygon(points=[[0,0],[0,catch_size],[catch_size,0]]);
}

module catches() {
    intersection() 
    {
        filled();
        union() {
            translate([0,0,wall_height])
            catch1();
            translate([outerwidth,outerheight,wall_height])
            rotate([0,0,180]) catch1();
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


netOval();
base();
sides();
catches();
topRim();
//netRectangle();