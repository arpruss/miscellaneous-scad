// A replacement plate for Manfrotto 501PL quick release compatible heads
// by Nirav Patel <http://eclecti.cc>
//
// Available under the CC BY license

//<params>
channel = 5.5; // Width of the channel in the middle
height = 11; // height of the plate (>=11 mm recommended)
extraHeight = 2.75; 
length = 90; // Length of the plate (90 mm is the stock one)
wall = 3; // Thickness of walls
sideTolerance = 0.2;
//</params>

nudge = 0.01;
height1 = height+extraHeight;

module tapered() polyhedron(points = [[-4.75-sideTolerance,0,0], [0,0,9], [0,0,0], [-4.75+sideTolerance,length,0], [0,length,9], [0,length,0]],
        faces = [[0,1,2], [0,4,1], [0,3,4], [0,5,3], [0,2,5], [3,5,4], [2,1,4], [2,4,5]]);

rotate([180,0,0]) // flipped for printability
difference() {
    union() {
        difference() {
            cube([42.0,length,height1]); // the bulk of the box
            translate([3,0,0]) cube([39,length,3.9]);      // removes the base area
            // hollow out what we can to make it use less plastic
            //translate([wall,wall,0]) cube([42/2-2*wall-8,length-2*wall, height1-wall]);
            //translate([wall+42/2+8,wall,0]) cube([42/2-2*wall-8,length-2*wall, height1-wall]);
        }
        // the tapered side bits
        tapered();
        translate([42,0,0]) mirror([1,0,0]) tapered();
        // the stop to keep it from falling out the front
        translate([0,42,0]) cube([11,4,height1]);
        translate([0,length-wall,0]) cube([37,wall,height1]);
        // the triangle piece that the quickrelease interfaces with
        polyhedron(points = [[42,42,0], [42,0,0], [37,42,0], [42,42,height1], [42,0,height1], [37,42,height1]],
            faces = [[0,2,1],[0,1,3],[1,4,3],[2,4,1],[2,5,4],[0,3,5],[0,5,2],[5,3,4]]);
    }

    // the channel for the camera mount screw
    translate([21,15,0]) cylinder(h=height1,r=channel/2);
    translate([21-channel/2,15,0]) cube([channel,length-30,height1]);
    translate([21-8,15,0]) cube([16,length-30,5]);
    translate([21,15,0]) cylinder(h=5,r=8);
    translate([21,length-15,0]) cylinder(h=5,r=8);
    translate([21,length-15,0]) cylinder(h=height1, r=channel);
    if (extraHeight>0) 
        translate([21-channel,9,height])
            cube([2*channel,length-30+5.5/2+3,extraHeight+nudge]);
}
