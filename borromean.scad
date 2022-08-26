tolerance = 2;
width = 4;
height = 5;
length = 50;
breakSize = 0.25;

module ring(break=false) {
    render(convexity=2)
    difference() {
        cube([width*3+2*tolerance,length,height]);
        translate([width,width,-1])
        cube([width+2*tolerance,length-2*width,height+2]);
        if (break) {
            translate([width,-tolerance,-1])
            cube([breakSize,width+2*tolerance,height+2]);
        }
    }
}

translate([-2*tolerance-3*width-5,0,0])
ring();
ring();
translate([2*tolerance+3*width+5,0,0])
ring(break=true);