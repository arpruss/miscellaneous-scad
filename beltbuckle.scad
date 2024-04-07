use <paths.scad>;
use <Bezier.scad>;

//<params>
width = 40;
thickThickness = 8;
thinThickness = 6;
tongueLength = 42;
tongueWidth = 5.5;
tongueThickness = 4.5;
tongueAttenuation = 0.7;
looseTolerance = 0.5;
tightTolerance = 0.3;
tongueInset = 3;
tongueLock = 2.75;
//</params>

maxHeight = (thickThickness/2*sqrt(2)+thickThickness)/2;

module shape(width) {
    h = sqrt(2)*maxHeight/2;

    intersection() {
        translate([0,0,width/2/sqrt(2)]) sphere(d=width,$fn=16);
        cylinder(h=maxHeight,d=4*width,$fn=3);
    }
}

w = width + thickThickness;
tw = tongueWidth + 2 * looseTolerance;
tw0 = tongueWidth;// + 2 * tightTolerance;
w0 = tw0 + (thickThickness-thinThickness)*2 + 2*tightTolerance;
l = tongueLength + thickThickness;

module main() {
    difference() {
        tracePath([ [0,-w0/2], [0,-w/2], [l,-w/2], [l,w/2], [0,w/2], [0,w0/2]],closed=false) shape(thickThickness);
        translate([l-thickThickness/2,-tw/2,maxHeight-tongueInset]) cube([thickThickness+2,tw,maxHeight]);
    }
    tracePath([ [0,-w0/2], [0,w0/2] ],closed=false) shape(thinThickness);
}

module tongueShape(thickness) {
    intersection() {
        hull() {
            translate([0,0,thickness/2/sqrt(2)]) sphere(d=thickness);
            translate([0,0,tongueWidth-thickness/2/sqrt(2)]) sphere(d=thickness,$fn=16);
        }
        cylinder(d=thickness*4,h=tongueWidth,$fn=3);
    }
}

function pathLengths(path,current=[0]) =
    len(path)<=len(current) ? current :
    let(n=len(current))
    pathLengths(path,current=concat(current,[current[n-1]+
        norm(path[n]-path[n-1])]));

module tongue() {
    h = thinThickness + tightTolerance*2 + tongueThickness/2;
    h1 = h + (thickThickness-thinThickness)/2;
    dx = thinThickness/2;
    l1 = l + thickThickness/2-tongueThickness/2; 
    bez = [ [l1,0], LINE(), LINE(), [l1-thickThickness,0], POLAR(h*.8,180), POLAR(h*.8,0), [l1*.5,-h*.3], SYMMETRIC(), POLAR(h*.8,0), [0,0],
        POLAR(h*.7,180), POLAR(h*.7,180),
        [0,-h1], POLAR(h*.5,0), POLAR(h*.5,180), [h*1.1,-h1+tongueLock] ];
    
    path = Bezier(bez);
    
    lengths = pathLengths(path);
    for (i=[0:len(path)-2]) {
        length = lengths[i+1];
        attenuate = length < l ? 1 :
            length >= l + h1 ? tongueAttenuation :
            let(t=(length-l)/h1) (1-t)*1+t*tongueAttenuation;
        hull() {
            translate(path[i]) tongueShape(tongueThickness*attenuate);
            translate(path[i+1]) tongueShape(tongueThickness*attenuate);
        }
    }
    
    //BezierVisualize(bez);
    //tracePath(Bezier(bez),closed=false) tongueShape();
}


//

//translate([0,tongueWidth/2,0]) 

translate([0,w/2+thickThickness*2+tongueThickness,0]) rotate([0,0,0]) tongue();
main();