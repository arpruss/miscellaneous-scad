use <Bezier.scad>;

//<params>
numberOfDrawerCompartmentsHorizontally = 6;
numberOfDrawerCompartmentsInDepth = 2;

// You can subdivide the drawer into two types of compartments by setting the right side width ratio to something bigger than zero.
rightSideWidthRatio = 0;
rightSideNumberOfDrawerCompartmentsHorizontally = 2;
rightSideNumberOfDrawerCompartmentsInDepth = 2;

numberOfDrawersInChest = 7;

generate = 1; // [0:chest, 1:drawer]

// Thickness 
outerWall = 0.75;
// Thickness of main drawer walls and dividers running forward and back
drawerWall=0.45; 
// Thickness of divider walls running horizontally
dividerWall=0.45; 
drawerWidth = 136;
drawerDepth = 70; 
drawerHeight = 16;
roundedCornerRadius=3.5;

tolerance=0.75;

// Divider walls between full-depth compartments can have a cut in them to make it easier to put things in and take them out. Set cut height to zero to disable.
cutHeight = 13.5; 
cutLengthAtTop = 16;
cutLengthAtBottom = 8; 
cutSmoothingSize = 5;

handleSize = 20;
handleLip = 3;
// Set to zero to have a handle with no floor.
handleFloorThickness = 0;

slideWidth = 6;
slideThickness = 1;

// Three of the walls are made in a grid pattern to save plastic. If you want them solid, set the grid hole width to zero.
gridHoleWidth = 9;
gridStripWidth = 3;
gridAngle = 60;

numberOfRearCrossbars = 2; // [0:0, 1:1, 2:2]

//</params>

module dummy() {}
nudge = 0.01;

module compartment(width, drawerDepth, drawerHeight,drawerWall=drawerWall) {
    render(convexity=2)
    difference() {
        cube([width,drawerDepth,drawerHeight]);
        hull() {
            translate([drawerWall,drawerWall,roundedCornerRadius+drawerWall]) cube([width-2*drawerWall,drawerDepth-2*drawerWall,drawerHeight]);
            translate([0,drawerWall,roundedCornerRadius+drawerWall]) 
                rotate([-90,0,0]) {
                translate([drawerWall+roundedCornerRadius,0,0]) cylinder(h=drawerDepth-2*drawerWall,r=roundedCornerRadius,$fn=24);
                translate([width-drawerWall-roundedCornerRadius,0,0]) cylinder(h=drawerDepth-2*drawerWall,r=roundedCornerRadius,$fn=24);
                }
            }
    }
}

module drawerHull(drawerWidth,inset=0,drawerHeight=drawerHeight,roundOnLeft=true,roundOnRight=true) {
    
    module post(roundPost) {
       if (roundPost) 
           cylinder(h=drawerHeight+nudge,r=roundedCornerRadius,$fn=24);
       else 
           translate([-roundedCornerRadius,-roundedCornerRadius,0]) cube([roundedCornerRadius*2,roundedCornerRadius*2,drawerHeight+nudge]);
    }
    
        hull() {
            translate([inset+roundedCornerRadius,drawerDepth-roundedCornerRadius-inset])
            post(roundOnLeft);
    translate([drawerWidth-roundedCornerRadius-inset,drawerDepth-roundedCornerRadius-inset]) post(roundOnRight);
    translate([inset,inset,0]) cube([roundedCornerRadius,roundedCornerRadius,drawerHeight]);
    translate([drawerWidth-inset-roundedCornerRadius,inset,0]) cube([roundedCornerRadius,roundedCornerRadius,drawerHeight]);
        }
}

module baseDrawer(numberOfDrawerCompartmentsHorizontally, drawerWidth, roundOnLeft=true, roundOnRight=true, drawerWall=drawerWall) {
    compartmentWidth = (drawerWidth-drawerWall)/numberOfDrawerCompartmentsHorizontally+drawerWall;

    intersection() {
        union() {
            for (i=[0:numberOfDrawerCompartmentsHorizontally-1]) {
                translate([(compartmentWidth-drawerWall)*i,0,0])
                compartment(compartmentWidth,drawerDepth,drawerHeight, drawerWall=drawerWall);
            }
        }
        drawerHull(drawerWidth,roundOnLeft=roundOnLeft,roundOnRight=roundOnRight);
    }
    render(convexity=2)
    difference() {
        drawerHull(drawerWidth,roundOnLeft=roundOnLeft,roundOnRight=roundOnRight);
        drawerHull(drawerWidth,roundOnLeft=roundOnLeft,roundOnRight=roundOnRight,inset=drawerWall,drawerHeight=drawerHeight+nudge);
    }
}

module cut() {
 //polygon([[-cutHeight,-cutLengthAtTop/2],[0,-cutLengthAtBottom/2],[0,cutLengthAtBottom/2],[-cutHeight,cutLengthAtTop/2]]);
    polygon(Bezier([ [-cutHeight,-cutLengthAtTop/2-cutSmoothingSize],OFFSET([0,cutSmoothingSize]), OFFSET([0,-cutSmoothingSize]),
    [nudge,-cutLengthAtBottom/2], 
    OFFSET([0,0]), 
    OFFSET([0,0]), 
    [nudge,0], REPEAT_MIRRORED([0,1])
    ]));
             
}

module handle() {
    render(convexity=2)
    translate([drawerWidth/2,0,0])
    difference() {
        cylinder(d=handleSize,h=handleFloorThickness+handleLip);
        translate([0,0,handleFloorThickness-nudge]) cylinder(d=handleSize-handleLip*2,h=handleLip+2*nudge);
        translate([-handleSize/2,0,0]) cube([handleSize,handleSize,handleSize]);
    }
}

module drawer(numberOfDrawerCompartmentsHorizontally, numberOfDrawerCompartmentsInDepth, drawerWidth, roundOnLeft=true, roundOnRight=true, drawerWall=drawerWall) {
    
    compartmentWidth = (drawerWidth-drawerWall)/numberOfDrawerCompartmentsHorizontally+drawerWall;
    
    render(convexity=4)
    difference() {
        baseDrawer(numberOfDrawerCompartmentsHorizontally, drawerWidth, roundOnLeft=roundOnLeft, roundOnRight=roundOnRight, drawerWall=drawerWall);
        if (numberOfDrawerCompartmentsInDepth == 1) 
        translate([compartmentWidth/2,drawerDepth/2,drawerHeight-cutHeight+nudge]) 
        rotate([0,90,0]) linear_extrude(height=drawerWidth-compartmentWidth) cut();
    }
    if (numberOfDrawerCompartmentsInDepth > 1) {
        for (i=[0:numberOfDrawerCompartmentsInDepth-2]) {
            translate([0,drawerWall+(drawerDepth-2*drawerWall)/numberOfDrawerCompartmentsInDepth*(1+i)-dividerWall/2,0])
            cube([drawerWidth,dividerWall,drawerHeight]);
        }
    }
}

chestWidth = drawerWidth+2*outerWall+2*tolerance;
drawerSpacing = drawerHeight+2*tolerance+slideThickness;
chestHeight = drawerSpacing*numberOfDrawersInChest+2*outerWall;
chestDepth = drawerDepth+tolerance+outerWall;

module strips(width,drawerDepth) {
    n = floor(1+width/(gridStripWidth+gridHoleWidth));
    for (i=[0:n]) {
        translate([i*(gridStripWidth+gridHoleWidth),0,0]) square([gridStripWidth,drawerDepth]);
    }
}

module gridFace(width,drawerDepth) {
    stripLength = 1.5*(width+drawerDepth);
    intersection() {
        union() {
            rotate(-gridAngle/2) translate([-stripLength/2,-stripLength/2]) 
            strips(stripLength,stripLength);
            rotate(gridAngle/2) translate([-stripLength/2,-stripLength/2]) 
            strips(stripLength,stripLength);
        }
        square([width,drawerDepth]);
    }
    difference() {
        square([width,drawerDepth]);
        translate([gridStripWidth,gridStripWidth])
        square([width-gridStripWidth*2,drawerDepth-gridStripWidth*2]);
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

module chest(numberOfDrawersInChest) {
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
        for (i=[0:numberOfDrawersInChest-1]) {
            translate([0,0,outerWall+i*drawerSpacing]) drawerSupport(i==0);
        }
        for (i=[1:numberOfDrawersInChest-1]) {
            translate([0,chestDepth-outerWall,outerWall+i*drawerSpacing-slideWidth/2+slideThickness/2]) cube([chestWidth,outerWall,slideWidth]);
        }
            translate([0,chestDepth-outerWall,0]) cube([chestWidth,outerWall,slideWidth/2]);
            translate([0,chestDepth-outerWall,chestHeight-slideWidth/2]) cube([chestWidth,outerWall,slideWidth/2]);
    }
    if (numberOfRearCrossbars > 0) {
        angle = atan2(chestHeight,chestWidth);
        translate([0,chestDepth,0])
        rotate([90,0,0])
        linear_extrude(height=outerWall)
        intersection() {
            union() {
                rotate(angle)
                translate([-0.5*(chestHeight+chestDepth),0]) square([2*(chestHeight+chestDepth),slideWidth]);
                if (numberOfRearCrossbars > 1) 
                translate([0,chestHeight])
                rotate(-angle)
                translate([-0.5*(chestHeight+chestDepth),0]) square([2*(chestHeight+chestDepth),slideWidth]);
            }
            square([chestWidth,chestHeight]);
        }
    }
}

module fullDrawer() {
    handle();
    if (rightSideWidthRatio>0) {
        leftWidth = drawerWidth * (1-rightSideWidthRatio) + drawerWall/2;
        rightWidth = drawerWidth * rightSideWidthRatio + drawerWall/2;
        drawer(numberOfDrawerCompartmentsHorizontally, numberOfDrawerCompartmentsInDepth, leftWidth, roundOnRight=false);
        translate([leftWidth-drawerWall,0,0])
            drawer(rightSideNumberOfDrawerCompartmentsHorizontally, rightSideNumberOfDrawerCompartmentsInDepth, rightWidth, roundOnLeft=false);
    }
    else {
        drawer(numberOfDrawerCompartmentsHorizontally, numberOfDrawerCompartmentsInDepth, drawerWidth);
    }
    
    if (outerWall > drawerWall) 
        drawer(1,1,drawerWidth,drawerWall=outerWall);
}

if (generate == 1) {
    fullDrawer();
}
else
    rotate([-90,0,0])
    chest(numberOfDrawersInChest);
