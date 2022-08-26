use <tubemesh.scad>;

//<params>
insideHeight=11;
insideWidth=10.5;
insideLength=67;
wallThickness=3;
socketOffsetFromEnd=0;
socketDiameter=10; // was 9.6
socketStickout=3;
socketWallThickness=0.8;
wireHoleHeight=8;
wireHoleWidth=5;
flange=5;
tolerance=0.25;
//</params>

module dummy(){}

nudge = 0.01;

insideHeight1=insideHeight+tolerance;
insideWidth1=insideWidth+2*tolerance;
socketDiameter1=socketDiameter+2*tolerance;
insideLength1=insideLength+2*tolerance;

module box(wallThickness) {
    x = 2*wallThickness+insideLength1;
    y = 2*wallThickness+insideWidth1;
    top = [[-flange,-flange],[x+flange,-flange],[x+flange,y+flange],[-flange,y+flange]];
    base = [[0,0],[x,0],[x,y],[0,y]];
    morphExtrude(base,top,height=insideHeight1+wallThickness);
//    cube([2*wallThickness+insideLength1,2*wallThickness+insideWidth1,wallThickness+insideHeight1]);
}

render(convexity=2) {
    difference() {
        box(wallThickness);
        translate([wallThickness,wallThickness,wallThickness+nudge]) box(0);
    }
    translate([wallThickness+insideLength1-socketDiameter1/2-socketOffsetFromEnd,wallThickness+insideWidth1/2,0]) difference() {
            cylinder(d=socketDiameter1+2*socketWallThickness,h=insideHeight1+wallThickness+socketStickout);
            cylinder(d=socketDiameter1,h=insideHeight1+wallThickness+socketStickout+nudge);
            translate([-socketDiameter1,-wireHoleWidth/2-tolerance,insideHeight1+wallThickness-wireHoleHeight-2*tolerance]) cube([socketDiameter1,wireHoleWidth+2*tolerance,wireHoleHeight+2*tolerance+socketStickout]);
    }
}
