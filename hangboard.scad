use <Bezier.scad>;
use <tubemesh.scad>;

holdDepths = [11,15,18,24];
holdHeight = 19;
holdWidth = 68;
verticalSpacing = 12;

boardDepth = 38.1;
boardHeight = 88.9;
boardWidth = 500;

maxCutDepth = 32; // ??

sloperAngle1 = 22;
sloperAngle2 = 35;

n = len(holdDepths);
spacing = (boardWidth-n*holdWidth)/(n+1);
nudge = 0.01;

function holdProfile(offset) = 
    let(h = holdHeight/2+offset)
    [for(z=Bezier([[0,h],POLAR(h/2,-90),POLAR(h/2,180),[h,0],LINE(),LINE(),[holdWidth/2+offset,0],REPEAT_MIRRORED([1,0]),REPEAT_MIRRORED([0,1])])) z-[offset,offset]];

module hold(depth) {
    feather = 2;
    vh = [[0,-depth],LINE(),LINE(),[0,-feather],POLAR(feather/2,90),POLAR(feather/2,180),[feather,0]];
    //BezierVisualize(vh);
    //echo(vh);
    tubeMesh([for (p=Bezier(vh)) sectionZ(holdProfile(p[0]),p[1])]);
}

module sloperProfile(angle) {
    t = tan(angle);
    y = t*maxCutDepth;
    
//    polygon([[0,0],[y,0],[0,maxCutDepth]]);
    path = [[0,0],LINE(),LINE(),[y+10,0],POLAR(10,-180),SYMMETRIC(),[y-5,5*t],POLAR(2,90+angle),LINE(),[0,maxCutDepth]];
    polygon(Bezier(path));
}

module sloper(angle) {
    w = boardWidth / 4;
    rotate([0,0,-90])
    rotate([-90,0,0])
    translate([0,0,-nudge]) linear_extrude(height=w+2*nudge) sloperProfile(angle);
}

module basic() {
    difference() {
        cube([boardWidth,boardHeight,boardDepth]);
        for (i=[0:n-1]) {
            row = floor(i / 2);
            col = i % 2;
            for (j=[0,2])
            translate([spacing+(col+j)*(spacing+holdWidth),verticalSpacing+row*(holdHeight+verticalSpacing),boardDepth+nudge]) hold(holdDepths[i]);
        }
        sloperWidth = boardWidth / 4;
        for (i=[0,2]) {
            translate([i*sloperWidth,boardHeight+nudge,nudge+boardDepth]) sloper(sloperAngle1);
            translate([(i+1)*sloperWidth,boardHeight+nudge,nudge+boardDepth]) sloper(sloperAngle2);
        }
    }
}

basic();
//sloperProfile(30);
//hold(20);