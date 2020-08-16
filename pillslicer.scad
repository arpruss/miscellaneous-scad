baseThickness = 3;
pillDiameters = [ 5.3, 7.5, 10.3 ];
pillDepths = [ 1.25, 1.75, 2.25 ];
miterHeight = 5;
miterWidth = 3;
razorThickness = 0.2;
spacing = 2;
razorTolerance = 0.05;
razorLength = 39;
razorHolderHeight = 12;
razorHolderOffset = 1;
razorHolderWidth = 1;
holderTolerance = 0.25;
tolerance = 0.1;

module dummy() {}

miterSlit = razorThickness + 2*razorTolerance;
nudge = 0.001;

function sum(v,n=undef,pos=0,soFar=0) = pos>=(n==undef?len(v):n) ? soFar :
            sum(v,n=n,pos=pos+1,soFar=soFar+v[pos]);

n = len(pillDiameters);
maxDiameter = max(pillDiameters);
dx = spacing+maxDiameter;
length = max((n+1)*dx,razorLength+2*holderTolerance+2*razorHolderWidth);
depth = max(pillDepths);
height = baseThickness+depth;
width = max(pillDiameters)+2*spacing+2*miterWidth;

module solid() {
    cube([length,width,height]);
    for(y=[0,width-miterWidth]) translate([0,y,0]) cube([length,miterWidth,miterHeight+height]);
    holder();
}

module adjCyl(d=10,h=10) {
    $fn = 32;
    cylinder(d1=d-h/2,d2=d,h=h/4);
    translate([0,0,h/4-nudge]) cylinder(d=d,h=3*h/4+nudge);
}

difference() {
    solid();
    for(i=[0:n-1]) translate([dx+i*dx,width/2,height-pillDepths[i]]) { 
adjCyl(d=pillDiameters[i]+tolerance,h=pillDepths[i]+nudge);
        translate([-miterSlit/2,-width-100,0]) cube([miterSlit,width*3+300,miterHeight+nudge+300]);
    }
}

module holder() {
    slit = razorThickness + holderTolerance;
    w = razorHolderOffset+razorHolderWidth+slit;
translate([0,-w+nudge,0])
difference() {
    cube([length,w,razorHolderHeight+razorHolderWidth]);
    translate([(length-(razorLength+2*tolerance))/2,razorHolderWidth,razorHolderWidth])
    cube([razorLength+2*holderTolerance,slit,razorHolderHeight+nudge]);
}
}
