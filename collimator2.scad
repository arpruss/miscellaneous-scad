thickness = 2;
length = 70;
width = 32;
bottomHolePercent = 65;

height = width * 0.75 + 5;
incut = width;
circleDiameter = width * bottomHolePercent / 100;

linear_extrude(height = thickness)
        difference() {
            square([length,width]);
            translate([length/2,width/2]) scale([length/width,1]) circle(circleDiameter/2);
        }

for(i=[0,1]) {
    translate([0,i*(thickness+width),0])
    rotate([90,0,0]) linear_extrude(height = thickness) polygon(points=[[0,0],[0,height],[length/2-incut/2,height],[length/2,height-incut/2],[length/2+incut/2,height],[length,height],[length,0]]);
}

for (i = [0:1]) {
    translate([thickness+i*(length-thickness),0,0]) rotate([0,-90,0])
    linear_extrude(height = thickness) polygon(points=[[0,0],[height,0],[height-width/2,width/2],[height,width],[0,width]]);
}