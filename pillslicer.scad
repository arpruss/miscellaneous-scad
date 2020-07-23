baseThickness = 3;
pillDiameters = [ 4, 6 ];
pillDepths = [ 2, 6 ];
miterHeight = 5;
miterWidth = 3;
miterSlit = 0.5;
spacing = 4;
tolerance = 0.1;

module dummy() {}

nudge = 0.001;

function sum(v,n=undef,pos=0,soFar=0) = pos>=(n==undef?len(v):n) ? soFar :
            sum(v,n=n,pos=pos+1,soFar=soFar+v[pos]);

n = len(pillDiameters);
maxDiameter = max(pillDiameters);
dx = spacing+maxDiameter/2;
length = (n+1)*dx;
depth = max(pillDepths);
height = baseThickness+depth;
width = max(pillDiameters)+2*spacing+2*miterWidth;

module solid() {
    cube([length,width,height]);
    for(y=[0,width-miterWidth]) translate([0,y,0]) cube([length,miterWidth,miterHeight+height]);
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
        translate([-miterSlit/2,-width,0]) cube([miterSlit,width*3,miterHeight+nudge+depth]);
    }
}
