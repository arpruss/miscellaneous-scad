pcbSizeX = 11.94;
pcbSizeY = 11.58;
icSizeX = 4.9; 
icSizeY = 3.9;
icHeight = 1.5;
hole = 2;

wall = 1.25;
baseThickness = 0.75;
snapLength = 4;
wallHeight = 1.75;

pcbTolerance = 0.05;
icTolerance = 0.02;

module dummy() {}

icSizeX1 = icSizeX + 2*icTolerance;
icSizeY1 = icSizeY; // + 2*tolerance;
pcbSizeX1 = pcbSizeX + 2*pcbTolerance;
pcbSizeY1 = pcbSizeY + 2*pcbTolerance;
nudge = 0.01;

module mirrored() {
    children();
    rotate([0,0,180]) children();
}

module base() {
    module side() {
        polygon([[-pcbSizeX1/2,-pcbSizeY1/2],
                 [-icSizeX1/2,-icSizeY/2],
                 [icSizeX1/2,-icSizeY/2],
                 [pcbSizeX1/2,-pcbSizeY1/2]]);
            }
     
    
    difference() {
        union() {
            linear_extrude(height=baseThickness+icHeight)       
                difference() {
                    square([pcbSizeX1+2*wall,pcbSizeY1+2*wall],center=true);
                    mirrored() side(); 
                }
            
        }
        translate([-icSizeX1/2,-icSizeY/2-nudge,baseThickness]) 
            cube([icSizeX1,icSizeY+2*nudge,icHeight+nudge]);
        translate([0,0,-1]) cylinder(h=baseThickness+icHeight+2,d=hole,$fn=30);
    }
}

module edge() {
    difference() {
        square([pcbSizeX1+2*wall,pcbSizeY1+2*wall],center=true);
        square([pcbSizeX1,pcbSizeY1],center=true);
    }
}

base();
linear_extrude(height=wallHeight+baseThickness+icHeight) edge();
