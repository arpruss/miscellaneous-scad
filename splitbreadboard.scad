use <roundedsquare.scad>;

//<params>
split = 10;
tolerance = 0.3;
length = 82.72;
leftHalfWidth = 26.95;
rightHalfWidth = 27.94;
wallHeight = 8;
wallThickness = 1.75;
baseWidth = 8;
baseThickness = 2.5;
//</params>

module dummy() {}
nudge = 0.01;

w1 = leftHalfWidth + 2*tolerance + 2*wallThickness;
w2 = rightHalfWidth + 2*tolerance + 2*wallThickness;
innerSplit = split - 2*wallThickness;
l = length+2*wallThickness+2*tolerance;

render(convexity=3)
difference() {
    linear_extrude(height=baseThickness) roundedSquare([w1+innerSplit+w2,l],radius=wallThickness);
    translate([baseWidth,baseWidth,-nudge]) linear_extrude(height=baseThickness+2*nudge) roundedSquare([w1-baseWidth*2,l-baseWidth*2],radius=wallThickness);
    translate([baseWidth+w1+innerSplit,baseWidth,-nudge]) linear_extrude(height=baseThickness+2*nudge) roundedSquare([w2-baseWidth*2,l-baseWidth*2],radius=wallThickness);
}
render(convexity=3)
translate([0,0,baseThickness-nudge]) 
difference() {
    linear_extrude(height=wallHeight) roundedSquare([w1+innerSplit+w2,l],radius=wallThickness);
    translate([wallThickness,wallThickness,-nudge]) cube([w1-wallThickness*2,l-wallThickness*2,wallHeight+2*nudge]);
   translate([wallThickness+w1+innerSplit,wallThickness,-nudge]) cube([w2-wallThickness*2,l-wallThickness*2,wallHeight+2*nudge]);
    #translate([w1,wallThickness,-nudge]) linear_extrude(height=wallHeight+2*nudge) roundedSquare([innerSplit,l-wallThickness*2],radius=wallThickness);
    
}