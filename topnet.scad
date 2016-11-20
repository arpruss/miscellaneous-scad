horizontal_spacing = 11.2;
vertical_spacing = 1.6;
tolerance = 0;
net_rim = 10;

base_width = 270+net_rim*2;
base_height = 95+net_rim*2;

net_thickness = 0.35;
layer_height = 0.35;
wall_thickness = net_rim;
wall_height = 10;
base_thickness = 1.5;

corner_radius = 95./2-5;

module dummy() {} // for customizer

width = base_width-tolerance*2;
height = base_height-tolerance*2;

xsize = width;
ysize = height;
nudge = 0.01;

module netRectangle() {
    render(convexity=12)
    linear_extrude(height=net_thickness*3) 
    for (i=[0:xsize/2/horizontal_spacing]) {
        translate([width/2 - layer_height*3 - horizontal_spacing*i,0,0]) square([layer_height*3,ysize]);
    }

    render(convexity=12)
    translate([0,0,net_thickness-nudge])
    linear_extrude(height=net_thickness+nudge) 
    for (i=[0:ysize/vertical_spacing]) {
        translate([0,vertical_spacing*i,layer_height]) 
        square([xsize,net_thickness]);
    }
}


module oval(inset) {
    radius = (width-2*inset)/width*corner_radius;
    for (i=[0:1]) {
        dx = (width-2*radius-2*inset)*i;
        translate([dx+radius+inset,radius+inset]) circle(r=radius, $fn=50);
        translate([dx+radius+inset,height-radius-inset]) circle(r=radius, $fn=50);
        translate([dx+inset,radius+inset]) square([radius*2,height-2*inset-2*radius]);
    }
    translate([radius+inset,inset]) square([width-2*inset-2*radius,height-2*inset]);
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

module sides() {
    render(convexity=10)
    difference() {
        linear_extrude(height=wall_height) difference() {
            oval(0);
            oval(wall_thickness);
        }
    }
}

module filled() {
    linear_extrude(height=wall_height) oval(0);
}


module full() {
    netOval();
    base();
    sides();
}

module cut() {
    render(convexity=10)
    difference() {
        union() {
         translate([0,0,-nudge]) cube([width/2+nudge, height, wall_height+2*nudge]);
            translate([width/2, net_rim/3, 0]) cube([10, net_rim/3, wall_height+2*nudge]);
        }
        color("red") translate([width/2-10, height-net_rim+net_rim/3, -2*nudge]) cube([10+2*nudge, net_rim/3, wall_height+4*nudge]);
    }
}

intersection() {
full();
cut();
}