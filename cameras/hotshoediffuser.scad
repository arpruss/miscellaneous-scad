hotshoeWidthTolerance = 0.2;
hotshoeThicknessTolerance = 0.3;
sideWall = 2;
frontWall = 0.75;
r1 = 50;
r2 = 30;
height = 44;
azimuthAngle = 100;
distanceFromBackOfHotshoe = 90;
rearSupportHeight = 8;
frontSupportHeight = 20;
frontSupportVerticalOffset = 5;
attachmentThickness = 2;
hotshoeLengthExtra = 1;
hotshoeOnly = 0; // [0:No, 1:Yes]
   
module dummy() {}

offset = r1+r2-distanceFromBackOfHotshoe-frontWall;
hotshoeLength = 18+hotshoeLengthExtra;
hotshoeInset = 3.2;
hotshoeTaper = 0.25;
hotshoeCorner = 1.5;   
hotshoeWidth = 18.52-hotshoeWidthTolerance;
hotshoeThickness = 1.95-hotshoeThicknessTolerance;

nudge = 0.01;    

$fn = 120;

module donutPiece(r1=100,r2=30,height=40,azimuthAngle=60) {
    rotate([0,0,90-azimuthAngle/2])
    rotate_extrude(angle=azimuthAngle) {
        translate([0,-height/2]) square([r1+nudge,height]);
    intersection() {
        translate([r1,0]) circle(r=r2);
        translate([r1,-height/2]) square([r1+r2,height]);
    }
    }
}

module filledSupports() {
    hull() supports();
}

module supports() {
    y0 = -sideWall/2+nudge;
    x0 = hotshoeWidth/2+sideWall/2;
    x1a = sin(azimuthAngle/2)*(r1+r2);
    y1a = cos(azimuthAngle/2)*(r1+r2-offset);
    y1 = 2*(r1+r2+abs(offset));
    scale = y1/(y1a-y0+offset);
    x1 = x0+(x1a-x0)*scale;
    h1 = sideWall*2+rearSupportHeight+(height-rearSupportHeight)*scale;
    for (s=[-1,1]) 
        hull() 
    {
            translate([s*x0,y0]) cylinder(h=rearSupportHeight, d=sideWall,$fn=16);
            translate([s*x1,y1])
            cylinder(h=h1, d=sideWall,$fn=16);
        }
    hull() {
        translate([x0,y0]) cylinder(d=sideWall,h=rearSupportHeight,$fn=16);
        translate([-x0,y0]) cylinder(d=sideWall,h=rearSupportHeight,$fn=16);
    }
    
}


module shield(filled=false) {
    intersection() {
        filledSupports();
    
    translate([0,0,height/2])
    difference() {
        translate([0,-offset,0])
        donutPiece(r1=r1,r2=r2,height=height,azimuthAngle=360);
        if (!filled) {
            translate([0,-offset,0])
            intersection() {
                donutPiece(r1=r1,r2=r2-frontWall,height=height+2*nudge,azimuthAngle=360);
                //translate([0,sideWall/sin(azimuthAngle/2),0]) donutPiece(r1=r1,r2=r2,height=height+2*nudge,azimuthAngle=360);
            }
        }
    }
    }
    
}

module hotshoe(coverStickout = 2) {    
hotshoeProfile = [
    [-hotshoeWidth/2, 0],
    [-hotshoeWidth/2+hotshoeTaper, hotshoeThickness],
    [-hotshoeWidth/2+hotshoeInset, hotshoeThickness],
    [-hotshoeWidth/2+hotshoeInset, hotshoeThickness+coverStickout],
    [hotshoeWidth/2-hotshoeInset, hotshoeThickness+coverStickout],
    [hotshoeWidth/2-hotshoeInset, hotshoeThickness],
    [hotshoeWidth/2-hotshoeTaper, hotshoeThickness],
    [hotshoeWidth/2, 0] ];

    rotate([90,0,180])
    render(convexity=1)
    intersection() {
        rotate([0,0,180])
        rotate([90,0,0])
        linear_extrude(height=hotshoeThickness+coverStickout)
        polygon([[-hotshoeWidth/2,0],
            [-hotshoeWidth/2,hotshoeLength-hotshoeCorner],
            [-hotshoeWidth/2+hotshoeCorner,hotshoeLength],
            [hotshoeWidth/2-hotshoeCorner,hotshoeLength],
            [hotshoeWidth/2,hotshoeLength-hotshoeCorner],
            [hotshoeWidth/2,0]]);

        linear_extrude(height=hotshoeLength) polygon(hotshoeProfile);
    }
}

module supportBars() {
    union() {
    translate([-(r1+r2),-sideWall+nudge,0]) cube([(r1+r2)*2,sideWall,height]);
    translate([-(r1+r2),-sideWall+hotshoeLength,frontSupportVerticalOffset]) cube([(r1+r2)*2,sideWall,frontSupportHeight]);
    }
}

hotshoe(coverStickout = attachmentThickness+frontSupportVerticalOffset);
if (!hotshoeOnly) {
    shield();
    intersection() {
        union() {
            supports();
            supportBars();
        }
        shield(filled=true);
    }
}
