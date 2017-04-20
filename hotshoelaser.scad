hotshoeWidthTolerance = 0.4;
hotshoeThicknessTolerance = 0.3;
   
mountOffset = 0;
clipLength = 30; 
clipWallThickness = 1.5;
clipOpeningAngle = 120;
laserDiameter = 13.8;
laserButtonStickout = 1.25;
laserButtonPresserArcAngle=30;

module dummy() {}

hotshoeLength = 18;
hotshoeInset = 3.2;
hotshoeTaper = 0.25;
hotshoeCorner = 1.5;   
hotshoeWidth = 18.52-hotshoeWidthTolerance;
hotshoeThickness = 1.95-hotshoeThicknessTolerance;

nudge = 0.001;    
    
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

module spiralArc(startAngle=0, endAngle=360, startRadius=10, endRadius=10, thickness=5, precision=36) {
    for (i=[0:precision-1]) {
        t1=i/precision;
        t2=(i+1)/precision;
        angle1 = (1-t1)*startAngle + t1*endAngle;
        angle2 = (1-t2)*startAngle + t2*endAngle;
        r1 = thickness/2+(1-t1)*startRadius + t1*endRadius;
        r2 = thickness/2+(1-t2)*startRadius + t2*endRadius;
        hull() {
            translate(r1*[cos(angle1),sin(angle1)]) circle(d=thickness);
            translate(r2*[cos(angle2),sin(angle2)]) circle(d=thickness);
        }
    }
}

module clip() {
    render(convexity=5)
        translate([0,laserDiameter/2+clipWallThickness,0]) 
        
        difference() {
            linear_extrude(height=clipLength) 
                spiralArc(startRadius=laserDiameter/2,endRadius=laserDiameter/2,thickness=clipWallThickness,startAngle=90+clipOpeningAngle/2,endAngle=360+90-clipOpeningAngle/2);
            translate([0,laserDiameter*.85,clipLength]) rotate([-45,0,0])
            cube(center=true,laserDiameter+2*clipWallThickness);
    translate([0,0,clipLength-clipWallThickness+nudge]) cylinder(h=clipWallThickness,d1=laserDiameter,d2=laserDiameter+2*clipWallThickness);
       
        }
        translate([0,laserDiameter/2+clipWallThickness,0]) 
            linear_extrude(height=clipLength/2) {
            spiralArc(startRadius=laserDiameter/2,endRadius=laserDiameter/2+clipWallThickness/2,thickness=clipWallThickness,startAngle=90-clipOpeningAngle/2-laserButtonPresserArcAngle/2,endAngle=90-clipOpeningAngle/2);
            spiralArc(startRadius=laserDiameter/2+clipWallThickness/2,endRadius=laserDiameter/2+laserButtonStickout,thickness=clipWallThickness,startAngle=90-clipOpeningAngle/2,endAngle=90-clipOpeningAngle/2+laserButtonPresserArcAngle/2);
            spiralArc(startRadius=laserDiameter/2+laserButtonStickout,endRadius=laserDiameter/2+laserButtonStickout,thickness=clipWallThickness,startAngle=90-clipOpeningAngle/2+laserButtonPresserArcAngle/2,endAngle=90-clipOpeningAngle/2+laserButtonPresserArcAngle);
            }
}

render(convexity=3)
difference() {
    hotshoe(coverStickout = laserDiameter/2+mountOffset);
    translate([0,mountOffset+hotshoeThickness+laserDiameter/2+clipWallThickness,0])
    translate([0,0,-nudge]) 
        cylinder(h=clipLength+2*nudge,d=laserDiameter+clipWallThickness);
}
translate([0,hotshoeThickness+mountOffset,0])
clip();
