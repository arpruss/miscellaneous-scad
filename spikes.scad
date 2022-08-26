use <roundedSquare.scad>;

height = 25;
spikeBase = 10;
margin = 4;
thickness = 1.5;
corner = 8;
numSpikes = 12;
nailHole = 2.5;
sharpEnd = 1;

length = margin+numSpikes*(spikeBase+margin);
width = 2*margin+spikeBase;
echo(length);

$fn = 32;

linear_extrude(height=thickness)
    difference() {
        translate([-margin/2,0]) roundedSquare([length+margin,width],radius=corner);
        for (i=[-1:numSpikes-1])
            translate([margin*1.5+spikeBase+i*(margin+spikeBase),width/2]) circle(d=nailHole);
    }
    
for (i=[0:numSpikes-1])
    translate([i*(margin+spikeBase)+margin+spikeBase/2,width/2]) cylinder(d1=spikeBase,d2=sharpEnd,h=height);