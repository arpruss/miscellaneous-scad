use <Bezier.scad>;

//<params>
rounded=3.5;
wall=0.75;
tolerance=0.5*10;
depth = 70;
drawerHeight = 16;
drawerWidth = 136;
compartmentHorizontalCount = 5;
compartmentDepthCount = 2;
cutLengthBottom = 8; // the cut is only valid if the compartmentDepthCount is 1
cutLengthTop = 16;
cutSmoothingSize = 5;
cutHeight = 13.5;
catchSize = 20;
catchLip = 2;
outerWall = 1.3;
drawerCount = 6;
slideWidth = 6;
slideThickness = 1;
gridStripWidth = 3;
gridHoleWidth = 9;
gridAngle = 60;
rearCrossbars = 2;

drawer = 0; // [0:chest, 1:drawer]
//</params>

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
                translate([wall+rounded,0,0]) cylinder(h=depth-2*wall,r=rounded,$fn=24);
                translate([width-wall-rounded,0,0]) cylinder(h=depth-2*wall,r=rounded,$fn=24);
                }
            }
    }
}

module drawerHull(inset=0,drawerHeight=drawerHeight) {
        hull() {
            translate([inset+rounded,depth-rounded-inset]) cylinder(h=drawerHeight+nudge,r=rounded,$fn=24);
    translate([drawerWidth-rounded-inset,depth-rounded-inset]) cylinder(h=drawerHeight,r=rounded,$fn=24);
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

module cut() {
 //polygon([[-cutHeight,-cutLengthTop/2],[0,-cutLengthBottom/2],[0,cutLengthBottom/2],[-cutHeight,cutLengthTop/2]]);
    polygon(Bezier([ [-cutHeight,-cutLengthTop/2-cutSmoothingSize],OFFSET([0,cutSmoothingSize]), OFFSET([0,-cutSmoothingSize]),
    [nudge,-cutLengthBottom/2], 
    OFFSET([0,0]), 
    OFFSET([0,0]), 
    [nudge,0], REPEAT_MIRRORED([0,1])
    ]));
             
}

module drawer(compartmentHorizontalCount) {
compartmentWidth = (drawerWidth-wall)/compartmentHorizontalCount+wall;

    render(convexity=4)
    difference() {
        baseDrawer(compartmentHorizontalCount);
        if (compartmentDepthCount == 1) 
        translate([compartmentWidth/2,depth/2,drawerHeight-cutHeight+nudge]) 
        rotate([0,90,0]) linear_extrude(height=drawerWidth-compartmentWidth) cut();
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
echo(drawerSpacing);
chestHeight = drawerSpacing*drawerCount+2*outerWall;
chestDepth = depth+tolerance+outerWall;

module strips(width,depth) {
    n = floor(1+width/(gridStripWidth+gridHoleWidth));
    for (i=[0:n]) {
        translate([i*(gridStripWidth+gridHoleWidth),0,0]) square([gridStripWidth,depth]);
    }
}

module gridFace(width,depth) {
    stripLength = 1.5*(width+depth);
    intersection() {
        union() {
            rotate(-gridAngle/2) translate([-stripLength/2,-stripLength/2]) 
            strips(stripLength,stripLength);
            rotate(gridAngle/2) translate([-stripLength/2,-stripLength/2]) 
            strips(stripLength,stripLength);
        }
        square([width,depth]);
    }
    difference() {
        square([width,depth]);
        translate([gridStripWidth,gridStripWidth])
        square([width-gridStripWidth*2,depth-gridStripWidth*2]);
    }
}

module drawerSupport(bottom,top) {
    cube([slideWidth,chestDepth,slideThickness]);
    translate([chestWidth-slideWidth,0,0]) cube([slideWidth,chestDepth,slideThickness]);
    translate([0,chestDepth-slideWidth,0]) cube([chestWidth,slideWidth,slideThickness*2/3]);

    if (!bottom) {
        translate([0,0,-slideWidth/2+slideThickness/2])
        cube([outerWall,chestDepth,slideWidth]);
        translate([chestWidth-outerWall,0,-slideWidth/2+slideThickness/2])
        cube([outerWall,chestDepth,slideWidth]);
    }
}

module chest(drawerCount) {
    render(convexity=8) {
        linear_extrude(height=outerWall)
        gridFace(chestWidth,chestDepth);
        translate([0,0,chestHeight-outerWall]) cube([chestWidth,chestDepth,outerWall]);
        translate([outerWall,0,0]) rotate([0,-90,0])
        linear_extrude(height=outerWall)
        gridFace(chestHeight,chestDepth);
        translate([chestWidth,0,0]) rotate([0,-90,0])
        linear_extrude(height=outerWall)
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
    if (rearCrossbars > 0) {
        angle = atan2(chestHeight,chestWidth);
        translate([0,chestDepth,0])
        rotate([90,0,0])
        linear_extrude(height=outerWall)
        intersection() {
            union() {
                rotate(angle)
                translate([-0.5*(chestHeight+chestDepth),0]) square([2*(chestHeight+chestDepth),slideWidth]);
                if (rearCrossbars > 1) 
                translate([0,chestHeight])
                rotate(-angle)
                translate([-0.5*(chestHeight+chestDepth),0]) square([2*(chestHeight+chestDepth),slideWidth]);
            }
            square([chestWidth,chestHeight]);
        }
    }
}

if (drawer) 
    drawer(compartmentHorizontalCount);
else
    //rotate([-90,0,0])
    chest(drawerCount);
