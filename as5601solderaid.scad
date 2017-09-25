pcbSizeX = 11.94;
pcbSizeY = 11.58;
//pcbThickness = 1.6;
icSizeX = 4.9; 
icSizeY = 3.9;
icHeight = 1.5;

wall = 1.25;
baseThickness = 0.75;
snapLength = 4;
wallHeight = 1.75;

tolerance = 0.3;

module dummy() {}

icSizeX1 = icSizeX + 2*tolerance;
icSizeY1 = icSizeY + 2*tolerance;
pcbSizeX1 = pcbSizeX + 2*tolerance;
pcbSizeY1 = pcbSizeY + 2*tolerance;
nudge = 0.001;

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
     
    render(convexity=3)
    difference() {
        linear_extrude(height=baseThickness+icHeight)
        difference() {
            square([pcbSizeX1+2*wall,pcbSizeY1+2*wall],center=true);
            mirrored() side(); 
        }
        translate([-icSizeX1/2,-icSizeY1/2,baseThickness])
        cube([icSizeX1,icSizeY1,icHeight+nudge]);
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
