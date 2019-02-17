module shrink(offset=1,$fn=12,range=400,dimension=3) {
    
    module c() {
        if (dimension<3) {
            square(size=2*range, center=true);
        }
        else {
            cube(size=2*range, center=true);
        }
    }

    render(convexity=12)    
    difference() {
        c();
        minkowski() {
            difference() {
                c();
                children();
            }
            if (dimension<3)
                circle(r=offset, $fn=$fn);
            else
                sphere(r=offset, $fn=$fn);
        }
    }
}

module hollow(offset=1,$fn=12,range=400,rounded=false,dimension=3) {
    render(convexity=24)
    difference() {
        children();
        if (rounded) {
            minkowski() {
                shrink(offset=offset*2,$fn=$fn,range=range,dimension=dimension) children();
                if(dimension<3) circle(r=offset,$fn=$fn);
                     else
                sphere(r=offset,$fn=$fn);
            }
        }
        else{
            shrink(offset=offset,$fn=$fn,range=range,dimension=dimension) children();
        }
    }
}

difference() {
    hollow(rounded=false) cube([10,10,10]);
    translate([0,0,9]) cube([10,10,1]);
}

translate([0,20,0]) linear_extrude(height=33) hollow(dimension=2,rounded=true,offset=2) square([12,50]);