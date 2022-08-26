use <sonyfe.scad>;
use <mft_kar.scad>;
use <tubemesh.scad>;

knurls = 60;
knurlHeight = 1;
sonyFlange = 18;
arFlange = 40.5;
flangeDelta = arFlange-sonyFlange+sonyFlangeAdjust();
nudge = 0.002;

module knurledCylinder(d1=10,d2=20,h=40,knurls=20,knurlHeight=0.5,$fn=16) {
    function segment(d,kh,z) = sectionZ([for (i=[0:knurls*$fn-1]) let(t=360*i/(knurls*$fn-1)) (d/2+kh*abs(sin(knurls*t/2)))*[cos(t),sin(t)]],z);        
    tubeMesh([segment(d1,0,0),
        segment(d1*.85+.15*d2,0,.15*h),
        segment(d1*.75+.25*d2,knurlHeight,.25*h),
        segment(d1*.15+.85*d2,knurlHeight,.85*h),
        segment(d2,0,h)]);
}

module knurledTube(id1=10,id2=20,od1=30,od2=40,h=40,knurls=20,knurlHeight=2) {
    difference() {
        knurledCylinder(d1=od1,d2=od2,h=h,knurls=knurls,knurlHeight=knurlHeight);
        translate([0,0,-1]) cylinder(d1=id1,d2=id2,h=h+2);
    }
}


render(convexity=9)
sonyFE();
translate([0,0,flangeDelta]) trimmedAR();
color("red")
translate([0,0,4.5-nudge]) 
    knurledTube(od1=sonyFEDiameter(),od2=arOuterDiameter(),id1=sonyFEDiameter()-6,id2=arInnerDiameter(),h=flangeDelta-arHeight()-sonyFEHeight(),knurls=knurls,knurlHeight=knurlHeight);

