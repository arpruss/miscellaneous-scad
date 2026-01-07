use <roundedSquare.scad>;
use <pointHull.scad>;

id = 35;
innerLength = 64;
holderThickness = 3.5;
pcbThickness = 1.22;
bottomPCBHolder = 2;
pcbTolerance = .25;
topPCBHolder = 10.5;
holderLeaveSpace = 17;
slit1 = 4;
slit2 = 2;
slitFromEnd = 10;
wall = 1.5;
slitLipInner = 1.5;
slitLipOuter = 3;
slitLipWall = 2;
capTolerance = .05;
corner =4;


$fn = 128;
od = id + 2 *wall;
slitLength = innerLength - slitFromEnd;

module cap(extra=0) {
   linear_extrude(height=wall+slitFromEnd)
   difference() {
       roundedSquare(od+capTolerance*2+2*wall,center=true,radius=corner);
       roundedSquare(od+capTolerance*2-extra,center=true,radius=corner);
   }
   linear_extrude(height=wall) roundedSquare(id+capTolerance*2+2*wall,center=true,radius=corner);
}

module body() {
   linear_extrude(height=innerLength+wall) difference() {
       roundedSquare(od,center=true,radius=corner);
       roundedSquare(id,center=true,radius=corner);
   }
   cap(wall/4+capTolerance);
}

module lip(slit) {
        for(y=[0,slit+slitLipWall]) 
    translate([id/2-slitLipInner,-slit/2-slitLipWall+y,0]) {
        cube([slitLipInner+wall+slitLipOuter,slitLipWall,innerLength-slitFromEnd+wall]);
    }
}

module slitBody() {
    difference() {
        body();
        translate([0,-slit1/2,wall]) cube([100,slit1,innerLength+1]);
        translate([-100,-slit2/2,wall]) cube([100,slit2,innerLength+1]);
    }
    lip(slit1);
    rotate([0,0,180]) lip(slit2);
}

nudge = .001;

module sharpCube(d,e1,e2) {
    b = [for(x=[0,d[0]]) for(y=[0,d[1]]) for(z=[0,d[2]]) 
       y==d[1] && z != 0 ? [x,y,z+e2] : 
       y==0 && z != 0? [x,y,z+e1]:[x,y,z]];
    pointHull(b);
}

module holder(height=10,upToInner=false) {
    pcb = pcbThickness + 2 * pcbTolerance;
    width = (id-holderLeaveSpace)/2;
    delta = upToInner ? 2*wall : 0;
    rotate([0,0,90]) 
    {
        for (r=[0,180]) rotate(r) for(y=[0,pcb+holderThickness])
            translate([-id/2-nudge+delta,-holderThickness-pcb/2+y]) sharpCube([width-delta, holderThickness, wall+height],y==0? holderThickness:0,y==0? 0:holderThickness);
    }
} 
slitBody();
holder(height=bottomPCBHolder);

translate([od+4*wall+slitLipOuter,0,0]) {
    cap();
    holder(height=topPCBHolder,upToInner=true);
}