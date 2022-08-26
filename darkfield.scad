diameter = 31.75;
spotDiameterRatio = 0.6;
rim = 2;
strut = 1.5;
thickness = 0.95;
mode = 0; // [0:central dark,1:off-center hole,2:sector]
handle = 0; //[0:no,1:yes]

module dummy() {}

innerRadius = diameter/2-rim;

$fn = 128;

module handle() {
    hull() {
        circle(d=diameter/2);
        translate([0,diameter]) circle(d=diameter/2);
    }
}

module sector(r1=5,r2=10,startAngle=-30,endAngle=30) {
    function arc(r,start,end) = [for (i=[0:$fn]) let(angle=start+(end-start)*i/$fn) r*[cos(angle),sin(angle)]];
    polygon(concat(arc(r2,startAngle,endAngle),arc(r1,endAngle,startAngle)));
}

module basic() {
    difference() {
        union() {
            circle(d=diameter);
            if (handle) handle();
        }
        if (mode==1)
            translate([(innerRadius-spotDiameterRatio*diameter/2),0]) circle(d=spotDiameterRatio*diameter);
        else if (mode==0)
            circle(d=diameter-rim*2);
        else if (mode==2) {
            sector(r1=spotDiameterRatio*diameter/2,r2=innerRadius,startAngle=270-60,endAngle=270+60);
        }
    }
    if (mode==0) {
        circle(d=spotDiameterRatio*diameter);
        for (a=[0,120,240]) rotate(30+a) translate([0,-strut/2]) square([diameter/2-rim/2,strut]);
    }
}

linear_extrude(height=thickness) basic();