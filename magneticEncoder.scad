use <tubemesh.scad>;

bearingID = 8;
//bearingThickness = 7;
bearingOD = 22;
bearingCollarHeight = 4;

pcbSizeX = 11.94;
pcbSizeY = 11.58;
pcbThickness = 1.6;
bottomExtraThickness = 1;

icThickness = 1.54;

verticalOffset = 1.5;
bevel = 1;

magnetDiameter = 6;
//magnetThickness = 2.5;
magnetCollarHeight = 1.75;
magnetCollarBevel = 0.25;
shaftLength = 20;
shaftSupports = true;

tolerance = 0.2;

wall = 1.5;


module dummy() {}

pcbThickness1 = pcbThickness+bottomExtraThickness;

nudge = 0.001;
height = bearingCollarHeight+verticalOffset+pcbThickness1;

// this is xy-centered for convenience
module topBeveledCube(size, bevel=1) {
    function section(xSize, ySize, zPos) = 
        [ [xSize/2,-ySize/2,zPos],
          [xSize/2,ySize/2,zPos],
          [-xSize/2,ySize/2,zPos],
          [-xSize/2,-ySize/2,zPos ] ];
    
    tubeMesh([
        section(size[0],size[1],0),
        section(size[0],size[1],size[2]-bevel),
        section(size[0]-bevel*2,size[1]-bevel*2,size[2])]);
}

module bottom() {
    $fn = 64;
    render(convexity=2)
    difference() {
        cylinder(d=bearingOD+2*wall+2*tolerance, h=height);
        translate([0,0,pcbThickness1+bevel]) cylinder(d=bearingOD+2*tolerance-2*wall, h=height);
        translate([0,0,height-bearingCollarHeight]) cylinder(d=bearingOD+2*tolerance, h=bearingCollarHeight+nudge);
        translate([0,0,-nudge])
        topBeveledCube([pcbSizeX+2*tolerance,pcbSizeY+2*tolerance,pcbThickness1+bevel+2*nudge], bevel=bevel);
    }
}

module top(supports=false) {
    $fn = 32;
    od = bearingID-2*tolerance;
    render(convexity=2)
    difference() {
        cylinder(d=od,h=shaftLength+magnetCollarHeight);
        tubeMesh([ngonPoints(n=$fn,d=magnetDiameter-2*tolerance,z=shaftLength),
        ngonPoints(n=$fn,d=magnetDiameter-2*tolerance,z=shaftLength+magnetCollarHeight-magnetCollarBevel),
        ngonPoints(n=$fn,d=magnetDiameter-2*tolerance+2*magnetCollarBevel,z=shaftLength+magnetCollarHeight+nudge)]);
    }
    if (supports) {
        x = od/2;
        for (angle=[0:90:360-90]) rotate([0,0,angle]) {
            
            morphExtrude([ 
                [ x-.1, 0, 0],
                [ x+.4, -.4, 0],
                [ x+10, -.4, 0],
                [ x+10, .4, 0],
                [ x+.4, .4, 0] ],
                [ [ x-.1, 0, shaftLength-5],
                  [ x+.4, -.4, shaftLength-5],
                  [ x+.4, .4, shaftLength-5] ]);                
        }
    }
}

bottom();
translate([10+bearingOD,0,0]) 
top(supports=shaftSupports);