boardWidth = 625;
boardHeight = 568;
boardThickness = 9.95;

frameWidth = 10;
frameThickness = 1.5;
hole = 3.5;

cornerSize = 190;

module dummy() {}

frameWidth1 = frameWidth + frameThickness;

module corner() {
    cube([cornerSize+frameThickness,frameWidth1,frameThickness]);
    cube([frameWidth1,cornerSize+frameThickness,frameThickness]);
    if (hole>0) {
        difference() {
            cube([frameWidth1*2,frameWidth1*2,frameThickness]);
            translate([frameWidth1*1.5,frameWidth1*1.5,-1])
            cylinder(d=hole,h=frameThickness+2,$fn=12);
        }
    }
    cube([frameThickness,cornerSize+frameThickness,boardThickness+frameThickness]);
    cube([cornerSize+frameThickness,frameThickness,boardThickness+frameThickness]);
}

module edge(boardSize) {
    cube([boardSize-2*cornerSize,frameWidth1,frameThickness]);
    cube([boardSize-2*cornerSize,frameThickness,boardThickness+frameThickness]);
}

translate([frameWidth1+2,185,0]) rotate([0,0,-45]) edge(boardWidth+3);

//translate([frameWidth1+40,180,0]) rotate([0,0,-45]) edge(boardHeight);


//render(convexity=2) corner();

