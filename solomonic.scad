use <tubemesh.scad>;

//<params>
offset = 3;
radius = 10;
height = 100;
twists = 4;
precision = 1;
//</params>

section = [ for(i=[0:5:360]) [offset + radius*cos(i),radius*sin(i)] ];

color("red")
morphExtrude(section,twist=360*twists,height=height,numSlices=height/precision,optimize=-1,startCap=true,endCap=true);

/*linear_extrude(twist=twists*360,height=height,slices=height/precision,$fn=360/5) {
    translate([offset,0]) circle(r=radius);
}*/