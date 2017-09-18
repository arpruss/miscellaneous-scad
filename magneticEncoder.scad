use <tubemesh.scad>;

bearingID = 8;
//bearingThickness = 7;
bearingOD = 22;
bearingCollarHeight = 4;

pcbSizeX = 11.94;
pcbSizeY = 11.58;
pcbThickness = 1.6;
bottomBevel = 0.5;

icThickness = 1.54;

verticalOffset = 2.5;
pcbHolderBevel = 1.4;

magnetDiameter = 6;
//magnetThickness = 2.5;
magnetCollarHeight = 2.25;
magnetCollarBevel = 0.25; //0.25;
shaftLength = 14;

tolerance = 0.2;
pcbTolerance = 0.3;
shaftOuterTolerance = 0.1;
magnetTolerance = 0.15;

supportSize = 7;

wall = 1.5;

module dummy() {}

pcbThickness1 = pcbThickness+pcbTolerance;

nudge = 0.001;
height = bearingCollarHeight+verticalOffset+pcbThickness1;

// this is xy-centered for convenience
module topBeveledCube(size, bevel=1, bevelHeightToWidthRatio=1) {
    function section(xSize, ySize, zPos) = 
        [ [xSize/2,-ySize/2,zPos],
          [xSize/2,ySize/2,zPos],
          [-xSize/2,ySize/2,zPos],
          [-xSize/2,-ySize/2,zPos ] ];
    
    tubeMesh([
        section(size[0],size[1],0),
        section(size[0],size[1],size[2]-bevel*bevelHeightToWidthRatio),
        section(size[0]-bevel*2,size[1]-bevel*2,size[2])]);
}

// this is xy-centered for convenience
module flaredCylinder(d=10, r=undef, h=10, flare=1) {
    $fn = 64;
    diameter = (r==undef)?d:(2*r);
    tubeMesh([ngonPoints(n=$fn,d=diameter,z=0),
        ngonPoints(n=$fn,d=diameter,z=h-flare),
        ngonPoints(n=$fn,d=diameter+2*flare,z=h)]);
}

module bottom() {
    $fn = 64;
    render(convexity=2)
    difference() {
        cylinder(d=bearingOD+2*wall+2*tolerance, h=height);
        translate([0,0,pcbThickness1+pcbHolderBevel]) cylinder(d=bearingOD+2*tolerance-2*wall, h=height);
        translate([0,0,height-bearingCollarHeight]) flaredCylinder(d=bearingOD+2*tolerance, h=bearingCollarHeight+nudge, flare=0.5);
        translate([0,0,-nudge])
        topBeveledCube([pcbSizeX+2*pcbTolerance,pcbSizeY+2*pcbTolerance,pcbThickness1+pcbHolderBevel+2*nudge], bevel=pcbHolderBevel);
    }
}

module top(supports=false) {
    $fn = 64;
    od = bearingID-2*shaftOuterTolerance;
    render(convexity=2)
    difference() {
        cylinder(d=od,h=shaftLength+magnetCollarHeight);
        translate([0,0,shaftLength])
            flaredCylinder(d=magnetDiameter+2*magnetTolerance,h=magnetCollarHeight,flare=magnetCollarBevel);
    }
    if (supportSize>0) {
        x = od/2;
        for (angle=[0:90:360-90]) rotate([0,0,angle]) {
            
            morphExtrude([ 
                [ x-.05, 0, 0],
                [ x+.6, -.4, 0],
                [ x+supportSize, -.4, 0],
                [ x+supportSize, .4, 0],
                [ x+.6, .4, 0] ],
                [ [ x-.05, 0, shaftLength-5],
                  [ x+.6, -.4, shaftLength-5],
                  [ x+.6, .4, shaftLength-5] ]);                
        }
    }
}

//bottom();
//translate([10+bearingOD,0,0]) 
top();