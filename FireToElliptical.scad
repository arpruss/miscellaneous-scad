use <ribbon.scad>;

wireDiameter = 5.2;
tabletHolderVertical = 10;
tabletHolderHorizontal = 17;
tabletEdgeToWire = 12.85;
tabletThicknessNominal = 10.6;
tabletHeightNominal = 115;
wireBelowPlane = 8;
wireHolderDiameter = 20;
wall = 2.5;
tolerance = 0.25;

angle = 10;

module dummy() {}

nudge = 0.001;
tabletThickness = tabletThicknessNominal + 2*tolerance;
tabletHeight = tabletHeightNominal + 2*tolerance;

module basicHolder2D(filled=false) {
    holderPoints = [
    [tabletThickness+wall/2,tabletHolderVertical],
    [tabletThickness+wall/2,-wall/2],
    [-wall/2,-wall/2],
    [-wall/2,tabletHolderVertical/2],
    [-wall/2,tabletHeight+wall/2-tabletHolderVertical/2],
    [-wall/2,tabletHeight+wall/2],
    [tabletThickness+wall/2,tabletHeight+wall/2],
    [tabletThickness+wall/2,tabletHeight-tabletHolderVertical]];
    ribbon(holderPoints, thickness=wall);
    if (filled) {
       hull() ribbon([for (i=[0:3]) holderPoints[i]],thickness=wall,closed=true);
       hull() ribbon([for (i=[len(holderPoints)-4:len(holderPoints)-1]) holderPoints[i]],thickness=wall,closed=true);
    }
    triangle = [[-wall/2,-wall/2], [-wall/2,tabletHeight+wall/2], [-wall/2-(tabletHeight+wall/2)*tan(angle), tabletHeight+wall/2]];
    if (filled)
        hull() ribbon(triangle, thickness=wall, closed=true);
    else
        ribbon(triangle, thickness=wall, closed=true);
    
}

module basicHolder() {
    translate([0,0,-wall]) {
        linear_extrude(height=wall)
            basicHolder2D(filled=true);    linear_extrude(height=wall+tabletHolderHorizontal)
            basicHolder2D(filled=false);
    }
}

module wireHolder() {
    $fn = 24;
    y = (tabletHeight-wireHolderDiameter/2);
    rotate([0,0,angle])
    translate([-tabletEdgeToWire-wireDiameter/2,y,0])
    render(convexity=4)
    difference() {
        translate([0,0,-wall])
        hull() {
            cylinder(h=wall+tabletEdgeToWire+2*wireDiameter,d=wireHolderDiameter); 
            translate([y*tan(angle),0,0]) cylinder(h=wall,d=wireHolderDiameter);
        }
        hull() {
            translate([0,0,tabletEdgeToWire+wireDiameter/2])
            rotate([-90,0,0])
            translate([0,0,-tabletHeight])
            cylinder(h=tabletHeight*3,d=wireDiameter+2*tolerance);
            translate([0,0,tabletEdgeToWire+wireDiameter*2])
            rotate([-90,0,0])
            translate([0,0,-tabletHeight])
            cylinder(h=tabletHeight*3,d=(wireDiameter+2*tolerance)*.65);
        }
        translate([0,0,tabletEdgeToWire+wireDiameter*2])
        rotate([-90,0,0])
        translate([0,0,-tabletHeight])
        cylinder(h=tabletHeight*3,d=(wireDiameter+2*tolerance)*1.25,$fn=4);
    }
}

module full() {
    basicHolder();
    wireHolder();
}

full();
translate([tabletThickness*2+4*wall+5,0,0]) 
mirror([1,0,0]) full();