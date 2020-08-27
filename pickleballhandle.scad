use <tubeMesh.scad>;

fullThickness = 22;
tangThickness = 5.17+3.07;
minExtraThickness = 2;
vSide = 13;
hSide = 19;
screwCountersinkDepth = 2.75;
screwCountersinkWidth = 6.5;
screwWideHole = 3.4;
screwNarrowHole = 2.6;
stringThickness = 4;
stringInset = 5;

minThickness = tangThickness+minExtraThickness*2;

halfThickness = (fullThickness-tangThickness)/2;

pointsTop = [[73.144373385,29.6/2],[-45.274765781,29.6/2],[-53.416238695,17.691139026],[-59.798564288,19.945730339],[-62.460890666,20.981843653],[-64.349046594,21.835361354],[-66.468584775,22.369252322],[-68.638751060,23.264764875],[-70.862896810,24.497061585],[-73.144373385,26.041305021],[-73.144373385,26.041305021]];

module outline() {
    polygon(points_handle_1_1);
}

thinningStart = 2;

function handleThickness(x) = 
    x >= pointsTop[thinningStart][0] ? fullThickness :
    let(t = (x - pointsTop[len(pointsTop)-1][0])/(pointsTop[thinningStart][0]-pointsTop[len(pointsTop)-1][0])) (t)*fullThickness + (1-t)*(minThickness);

function backCrossSection() = let(x=pointsTop[0][1],y=fullThickness/2) 
    [ [x, 0], [x,vSide/2],[hSide/2,y],[-hSide/2,y],[-x,vSide/2],[-x,0] ];

function crossSection(x,h) =
    [for (p=backCrossSection()) [x,p[0]*h/pointsTop[0][1],p[1]*handleThickness(x)/fullThickness]];

screws = [pointsTop[thinningStart-1][0],pointsTop[0][0]-20];

module handle() {
    intersection() {
        translate([0,0,-tangThickness/2])
    tubeMesh([for (p=pointsTop) crossSection(p[0],p[1])]);
        translate([-200,-200,0]) cube([400,400,400]);
    }
}

module full(hole,countersink) {
    difference() {
        handle();
        for (x=screws) {
            translate([x,0,-0.5]) cylinder(d=hole,$fn=20,h=fullThickness+1);
            if(countersink)
            translate([x,0,fullThickness/2-tangThickness/2-screwCountersinkDepth]) cylinder(d=screwCountersinkWidth,$fn=20,h=fullThickness+1);
        }
        translate([pointsTop[0][0]-(stringThickness+stringInset),-stringThickness/2,-0.01])
        linear_extrude(height=stringThickness) hull() {
            translate([stringThickness+stringInset+1-.1,0]) square([.1,stringThickness]);
            translate([stringThickness/2,stringThickness/2])
            circle(d=stringThickness,$fn=18);
        }
//        cube([stringThickness+stringInset+1, stringThickness, stringThickness]);
    }
}

full(screwWideHole,true);
translate([0,70,0])
full(screwNarrowHole,false);