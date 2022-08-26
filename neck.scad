use <bezier.scad>;

width = 3*25.4;
length = 16*25.4;
height1 = 25.4;
height2 = 25.4/2;

delta = height1-height2;
top = [[0,height1],POLAR(2*delta,0),POLAR(2*delta,180),[4*delta,height2], SHARP(), SHARP(), [length,height2]];
echo(top);
side = concat(Bezier(top),[[length,0],[0,0]]);

//projection()
rotate([90,0,0]) linear_extrude(height=width) polygon(side);