rounded=3;
wall=1;
tolerance=0.4;
depth = 70;
drawerHeight = 14;
drawerWidth = 120;
compartmentHorizontalCount = 8;
compartmentDepthCount = 1;
cutLengthBottom = 10; // the cut is only valid if the compartmentDepthCount is 1
cutLengthTop = 20;
cutdrawerHeight = 12;
catchSize = 20;
catchLip = 2;
outerWall = 1.5;
drawerCount = 6;
tolerance = 0.4;
slideWidth = 6;
slideThickness = 1;
gridStripWidth = 3;
gridHoleWidth = 9;
gridAngle = 60;

drawer = 1; // [0:chest, 1:drawer]

module dummy() {}
nudge = 0.01;

module compartment(width, depth, drawerHeight) {
    render(convexity=2)
    difference() {
        cube([width,depth,drawerHeight]);
        hull() {
            translate([wall,wall,rounded+wall]) cube([width-2*wall,depth-2*wall,drawerHeight]);
            translate([0,wall,rounded+wall]) 
                rotate([-90,0,0]) {
                translate([wall+rounded,0,0]) cylinder(h=depth-2*wall,r=rounded,$fn=16);
                translate([width-wall-rounded,0,0]) cylinder(h=depth-2*wall,r=rounded,$fn=16);
                }
            }
    }
}

module drawerHull(inset=0,drawerHeight=drawerHeight) {
        hull() {
            translate([inset+rounded,depth-rounded-inset]) cylinder(h=drawerHeight+nudge,r=rounded,$fn=16);
    translate([drawerWidth-rounded-inset,depth-rounded-inset]) cylinder(h=drawerHeight,r=rounded,$fn=16);
    translate([inset,inset,0]) cube([rounded,rounded,drawerHeight]);
    translate([drawerWidth-inset-rounded,inset,0]) cube([rounded,rounded,drawerHeight]);
        }
}

module baseDrawer(count) {
compartmentWidth = (drawerWidth-wall)/compartmentHorizontalCount+wall;

    intersection() {
        union() {
            for (i=[0:count-1]) {
                translate([(compartmentWidth-wall)*i,0,0])
                compartment(compartmentWidth,depth,drawerHeight);
            }
        }
        drawerHull();
    }
    render(convexity=2)
    difference() {
        drawerHull();
        drawerHull(inset=wall,drawerHeight=drawerHeight+nudge);
    }
}

module drawer(compartmentHorizontalCount) {
compartmentWidth = (drawerWidth-wall)/compartmentHorizontalCount+wall;

    render(convexity=4)
    difference() {
        baseDrawer(compartmentHorizontalCount);
        if (compartmentDepthCount == 1) 
        translate([compartmentWidth/2,depth/2,drawerHeight-cutdrawerHeight+nudge]) 
        rotate([0,90,0]) linear_extrude(drawerHeight=drawerWidth-compartmentWidth) polygon([[-cutdrawerHeight,-cutLengthTop/2],[0,-cutLengthBottom/2],[0,cutLengthBottom/2],[-cutdrawerHeight,cutLengthTop/2]]);
    }
    render(convexity=2)
    translate([drawerWidth/2,0,0])
    difference() {
        cylinder(d=catchSize,h=wall+catchLip);
        translate([0,0,wall]) cylinder(d=catchSize-catchLip*2,h=catchLip+nudge);
        translate([-catchSize/2,0,0]) cube([catchSize,catchSize,catchSize]);
    }
    if (compartmentDepthCount > 1) {
        for (i=[0:compartmentDepthCount-2]) {
            translate([0,(depth-2*wall)/compartmentDepthCount*(1+i)+wall/2,0])
            cube([drawerWidth,wall,drawerHeight]);
        }
    }
}

chestWidth = drawerWidth+2*outerWall+2*tolerance;
drawerSpacing = drawerHeight+2*tolerance+slideThickness;
chestHeight = drawerSpacing*drawerCount+2*outerWall;
chestDepth = depth+tolerance+outerWall;

module strips(width,depth,thickness) {
    n = floor(1+width/(gridStripWidth+gridHoleWidth));
    for (i=[0:n]) {
        translate([i*(gridStripWidth+gridHoleWidth),0,0]) cube([gridStripWidth,depth,thickness]);
    }
}

module gridFace(width,depth,thickness) {
    stripLength = 1.5*(width+depth);
    render(convexity=5) {
        intersection() {
            union() {
                rotate([0,0,-gridAngle/2]) translate([-stripLength/2,-stripLength/2,0]) 
                strips(stripLength,stripLength,thickness);
                rotate([0,0,gridAngle/2]) translate([-stripLength/2,-stripLength/2,0]) 
                strips(stripLength,stripLength,thickness);
            }
            cube([width,depth,thickness]);
        }
        difference() {
            cube([width,depth,thickness]);
            translate([gridStripWidth,gridStripWidth,-nudge])
            cube([width-gridStripWidth*2,depth-gridStripWidth*2,thickness+2*nudge]);
        }
    }
}

module drawerSupport(bottom,top) {
    render(convexity=2)
    difference() {
        cube([chestWidth,chestDepth,slideThickness]);
        translate([slideWidth,-nudge,-nudge]) cube([chestWidth-2*slideWidth,chestDepth-slideWidth+nudge,slideThickness+2*nudge]);
    }
    if (!bottom) {
        translate([0,0,-slideWidth/2+slideThickness/2])
        cube([outerWall,chestDepth,slideWidth]);
        translate([chestWidth-outerWall,0,-slideWidth/2+slideThickness/2])
        cube([outerWall,chestDepth,slideWidth]);
    }
}

module chest(drawerCount) {
    render(convexity=8) {
        gridFace(chestWidth,chestDepth,outerWall);
        translate([0,0,chestHeight-outerWall]) cube([chestWidth,chestDepth,outerWall]);
        translate([outerWall,0,0]) rotate([0,-90,0])
        gridFace(chestHeight,chestDepth,outerWall);
        translate([chestWidth,0,0]) rotate([0,-90,0])
        gridFace(chestHeight,chestDepth,outerWall);
        for (i=[0:drawerCount-1]) {
            translate([0,0,outerWall+i*drawerSpacing]) drawerSupport(i==0);
        }
        for (i=[1:drawerCount-1]) {
            translate([0,chestDepth-outerWall,outerWall+i*drawerSpacing-slideWidth/2+slideThickness/2]) cube([chestWidth,outerWall,slideWidth]);
        }
            translate([0,chestDepth-outerWall,0]) cube([chestWidth,outerWall,slideWidth/2]);
            translate([0,chestDepth-outerWall,chestHeight-slideWidth/2]) cube([chestWidth,outerWall,slideWidth/2]);
    }
}

if (drawer) 
    drawer(compartmentHorizontalCount);
else
    rotate([-90,0,0])
    chest(drawerCount);
