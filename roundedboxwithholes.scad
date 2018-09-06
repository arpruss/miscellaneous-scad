create = 0; // [0:lid, 1:box]
rounding = 5;
outerWidth = 40;
outerLength = 60;
sideWall = 1;
lip = 3;
baseThickness = 1.5;
lidThickness = 1.5;
lidThicknessTolerance = 0.25;
lidSideTolerance = 0.25;
height = 20;
screwHoleDiameter = 2;
screwHoleDepth = 5;

module ribbon(points,closed=true) {
    for (i=[0:len(points)-(closed?1:2)]) {
        hull() {
            translate(points[i]) children();
            translate(points[(i+1)%len(points)]) children();
        }
    }
}

$fn = 10;
nudge = 0.01;

adjWidth = outerWidth - rounding - sideWall;
adjLength = outerLength - rounding - sideWall;

function arc(r,start,end,origin=[0,0]) = [ for(i=[0:$fn-1]) let(t=i/($fn-1), angle=(1-t)*start+t*end) origin+r*[cos(angle),sin(angle)] ];
    
innerCorners = [[adjLength/2,adjWidth/2],[-adjLength/2,adjWidth/2],[-adjLength/2,-adjWidth/2],[adjLength/2,-adjWidth/2]];
    
function rounded(inset=0) = 
    let(r=rounding-inset) 
    [for(a=[for (i=[0:3]) arc(r,i*90,i*90+90,origin=innerCorners[i])]) for(b=a) b];

mainOutline = rounded(inset=sideWall/2);

module filledBox(height=height) {
    linear_extrude(height=height) hull() ribbon(mainOutline) circle(d=sideWall);
}


module mainBox() {
    innerHeight = height-lidThicknessTolerance-lidThickness-lip;
    difference() {
        union() {
        filledBox(height=baseThickness);
        ribbon(mainOutline) cylinder(d=sideWall,h=height);
        intersection() {
            translate([0,0,innerHeight]) ribbon(mainOutline) cylinder(d1=sideWall,d2=sideWall+2*lip,h=lip);
            filledBox();
        }
        for (i=[0:3]) translate(innerCorners[i]) cylinder(r=rounding-sideWall/2,h=innerHeight);
        }
        for (i=[0:3]) translate([innerCorners[i][0],innerCorners[i][1],innerHeight-screwHoleDepth]) cylinder(d=screwHoleDiameter,h=screwHoleDepth+nudge);
    }
}

module lid() {
    difference() {
        linear_extrude(height=lidThickness) hull() ribbon(rounded(inset=sideWall+nudge+lidSideTolerance)) circle(d=nudge);
        for (i=[0:3]) translate([innerCorners[i][0],innerCorners[i][1],-nudge]) cylinder(d=screwHoleDiameter,h=lidThickness+2*nudge);
    }
}

if (create == 1) render(convexity=2) mainBox();
    else lid();