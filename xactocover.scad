innerWidth = 8.05;
bladeLength = 27;
handleAreaLength = 22;
tolerance = 0;
aspectRatio = 1.2;
wallThickness = 0.75;
tipThickness = 2;
slitThickness = 1.5;
strutThickness = 1.5;
strutWidth = 10;

module cyl(w=8,h=8) {
    rotate(360/5/2)
    cylinder($fn=5,d=w/cos(180/5),h=h);
}

nudge = 0.001;
outerWidth = innerWidth + tolerance*2 + 2*wallThickness;
insideLength = tipThickness+bladeLength+handleAreaLength;

render(convexity=2)
rotate([0,90,0]) 
{
intersection() {
    cyl(w=outerWidth,h=insideLength+tipThickness);
    for (s=[-1,1]) 
        mirror([0,s<0?1:0,0])
        translate([-outerWidth/2-10,-strutThickness/2-strutThickness/2-innerWidth/5,tipThickness+bladeLength-strutWidth])
    rotate([7,0,0])
    cube([outerWidth+20,strutThickness,strutWidth]);
}

difference() {
    scale([aspectRatio,1,1])
    cyl(w=outerWidth,h=insideLength+tipThickness);
    translate([0,0,tipThickness])
    cyl(w=innerWidth+tolerance*2,h=insideLength+nudge);
    translate([-outerWidth/2-10, -slitThickness/2, insideLength+tipThickness-handleAreaLength]) cube([outerWidth+20,slitThickness,handleAreaLength+nudge]);
}
}