use <pointHull.scad>;

thickness = 1.75;
bottomThickness = 2.1;

tolerance = 0.15;
innerWidth = 75+2*tolerance;
outerWidth = innerWidth+2*thickness;
innerLength = 160.2+2*tolerance;
outerLength = innerLength+2*thickness;
topLip = 1.25;
extraHeight = 1;
innerHeight = 8.4+2*tolerance;
outerHeight = innerHeight+bottomThickness+topLip;
radius = 7;

nudge = 0.001;

module roundedSquare(dim,radius=5) {
    hull() {
        translate([radius,radius]) circle(r=radius);
        translate([dim[0]-radius,radius]) circle(r=radius);
        translate([radius,dim[1]-radius]) circle(r=radius);
        translate([dim[0]-radius,dim[1]-radius]) circle(r=radius);
    }
}

module lip() {
pointHull(
    [for (y=[radius,innerLength-radius]) 
        for (xz=[
                [0,innerHeight-topLip],
                [0,innerHeight],
                [topLip,innerHeight],
                [0,innerHeight+topLip]]) [xz[0]-nudge,y,xz[1]]]);
}

module lips() {
    lip();
    translate([innerWidth,0,0]) mirror([1,0,0]) lip();
}

module main() {
    difference() {
    translate([-thickness-tolerance,-thickness-tolerance,-bottomThickness]) 
        linear_extrude(height=outerHeight+extraHeight) roundedSquare([outerWidth,outerLength],radius=radius);

        translate([0,0,0]) 
            linear_extrude(height=outerHeight+10) roundedSquare([innerWidth,innerLength],radius=7);
        
       // #model();
    //    translate([0,0,5]) model();
    }

    lips();
}

difference() {
    main();
    translate([innerWidth-24,-7,0]) cube([18,15,7]);
    translate([innerWidth/2-15/2,-7,0]) cube([15,15,8]);
    translate([-7,85,0]) cube([15,30,outerHeight]);
    translate([innerWidth-1,102-15,0]) cube([15,38,outerHeight]);
    translate([innerWidth-34,107,0]) linear_extrude(height=10,center=true) roundedSquare([30,49,10]);
    for (y=[20,50,80,110,140]) 
        translate([0,y,0]) {
        translate([innerWidth/4,0,0]) cylinder(d=23,h=20,center=true);
            if (y<90)
        translate([innerWidth*3/4,0,0]) cylinder(d=23,h=20,center=true);
        }
}