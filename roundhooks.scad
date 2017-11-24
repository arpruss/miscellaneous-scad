use <tubemesh.scad>;

//<params>
ring1InnerDiameter = 256;
ring1Angle = 90;
hook1Width = 3;
hook1Height = 6;
underlay1Width = 5;
ring2InnerDiameter = 154.4;
ring2Angle = 90;
hook2Width = 3;
hook2Height = 6;
underlay2Width = 5;
ring3InnerDiameter = 30;
ring3Angle = 110;
hook3Width = 6;
hook3Height = 16;
underlay3Width = 5;
ring4InnerDiameter = 0;
ring4Angle = 45;
hook4Width = 3;
hook4Height = 8;
underlay4Width = 5;

hookAngle = 65;
baseThickness = 1;
basePieceWidth = 10;

nailHoleDiameter = 2.2;
nailHoleAngle = 70;
//</params>

module dummy(){}

nudge = 0.001;

$fn = 32;

rings = [ 
[ring1InnerDiameter, ring1Angle, hook1Width, hook1Height,underlay1Width],
[ring2InnerDiameter, ring2Angle, hook2Width, hook2Height,underlay2Width],
[ring3InnerDiameter, ring3Angle, hook3Width, hook3Height,underlay3Width],
[ring4InnerDiameter, ring4Angle, hook4Width, hook4Height,underlay4Width] ];

module hook(diameter,angle,width,height,underlayWidth,zOffset=0) {
    if (diameter) {
        r = diameter/2;
        rOffset = height*tan(90-hookAngle);
        b1 = arcPoints(r=r-width,start=90-angle/2,end=90+angle/2);
        b2 = arcPoints(r=r,start=90+angle/2,end=90-angle/2);
        bottomSection = concat(b1,b2);
        topSection = concat(arcPoints(r=r-width+rOffset,start=90-angle/2,end=90+angle/2),arcPoints(r=r+rOffset,start=90+angle/2,end=90-angle/2));
        translate([0,0,zOffset]) morphExtrude(bottomSection,topSection,height);
        if (zOffset>0) {
            b3 = arcPoints(r=r+underlayWidth,start=90+angle/2,end=90-angle/2);
            widerBottom = concat(b1,b3);
            linear_extrude(height=zOffset+nudge) polygon(widerBottom);
        }
    }
}

module join(r1,angle1a,angle1b, r2,angle2a,angle2b, holePosition) {
    points = concat(
        arcPoints(r=r1,start=90+angle1a,end=90+angle1b),
        arcPoints(r=r2,start=90+angle2b,end=90+angle2a));
    render(convexity=2)
    difference() {
        linear_extrude(height=baseThickness) polygon(points);
        if (holePosition != undef) {
            v2 = r2*[cos(90+(angle2a+angle2b)/2),sin(90+(angle2a+angle2b)/2), 0];
            v1 = r1*[cos(90+(angle1a+angle1b)/2),sin(90+(angle1a+angle1b)/2), 0];
            pos = v2 * (1-holePosition) + v1 * holePosition;
            translate(pos)
            rotate([nailHoleAngle-90,0,0])
            translate([0,0,-baseThickness])
            cylinder(h=baseThickness+2,d=nailHoleDiameter,$fn=12);
        }
    }
        
}

rings1 = [for(r=rings) if (r[0]) r];

for (r=rings1) 
    hook(r[0],r[1],r[2],r[3],r[4],zOffset=baseThickness);

for (i=[0:len(rings1)-2]) {
    w1 = 360*basePieceWidth/(rings1[i][0]*PI);
    w2 = 360*basePieceWidth/(rings1[i+1][0]*PI);
    join(rings1[i][0]/2-rings1[i][2],-rings1[i][1]/2,-rings1[i][1]/2+w1,rings1[i+1][0]/2,-rings1[i+1][1]/2,-rings1[i+1][1]/2+w2,i==0 ? 0.85 : i == len(rings1)-2 ? 0.4 : undef);
    join(rings1[i][0]/2-rings1[i][2],-w1/2,w1/2,rings1[i+1][0]/2,-w2/2,w2/2, i==0 ? 0.85 : i == len(rings1)-2 ? 0.4 : undef);
    join(rings1[i][0]/2-rings1[i][2],rings1[i][1]/2-w1,rings1[i][1]/2,rings1[i+1][0]/2,rings1[i+1][1]/2-w2,rings1[i+1][1]/2, i==0 ? 0.85 : i == len(rings1)-2 ? 0.4 : undef); 
}
