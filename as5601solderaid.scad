pcbSizeX = 11.94;
pcbSizeY = 11.58;
pcbThickness = 1.6;
icSizeX = 4.9; 
icSizeY = 3.9;
pressureWedgeThickness = 0.2;

wall = 1.25;
baseThickness = 0.75;
snapLength = 4;

tolerance = 0.25;

module dummy() {}

icSizeX1 = icSizeX + 2*tolerance;
icSizeY1 = icSizeY + 2*tolerance;
pcbSizeX1 = pcbSizeX + 2*tolerance;
pcbSizeY1 = pcbSizeY + 2*tolerance;
pcbThickness1 = pcbThickness + tolerance;
nudge = 0.001;

module mirrored() {
    children();
    rotate([0,0,180]) children();
}

module base() {
    module side() {
        polygon([[-pcbSizeX1/2-nudge,-pcbSizeY1/2-nudge],
            [-pcbSizeX1/2+1.75,-pcbSizeY1/2],
            [-icSizeX1/2,-icSizeY1/2],
            [-icSizeX1/2,icSizeY1/2],
            [-pcbSizeX1/2+1.75,pcbSizeY1/2],
            [-pcbSizeX1/2-nudge,pcbSizeY1/2+nudge]]);
    }
    mirrored() side();
}

module pressureWedges() {
    module side() {
        translate([icSizeX1/2+nudge,0,0])
        rotate([90,0,0])
        translate([0,0,-icSizeY1/2])
        linear_extrude(height=icSizeY1) polygon([[0,baseThickness],[0,0],[-pressureWedgeThickness,0]]);
    }
    
    mirrored() side();
}

module edge() {
    difference() {
        square([pcbSizeX1+2*wall,pcbSizeY1+2*wall],center=true);
        square([pcbSizeX1,pcbSizeY1],center=true);
    }
}

module snaps() {
    module side() {
        translate([pcbSizeX1/2+wall,0,pcbThickness+baseThickness-0.5])
        rotate([90,0,0])
        translate([0,0,-snapLength/2])
        linear_extrude(height=snapLength)
        polygon([[-wall,0],[0,0],
                 [0, wall*1.5], [-wall*1.75, wall*1.5]]);
    }
    
    mirrored() side();
}

render(convexity=4)
difference() {
    union() {
        linear_extrude(height=baseThickness) base();
        linear_extrude(height=pcbThickness+baseThickness) edge();
        snaps();
        pressureWedges();
    }
    mirrored() translate([-pcbSizeX1/2-wall-nudge,snapLength/2,baseThickness+nudge]) cube([pcbSizeX1+2*wall+2*nudge,1,pcbThickness]);
}