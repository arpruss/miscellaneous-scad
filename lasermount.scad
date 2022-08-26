   
mountOffset = 2;
clipLength = 40; 
clipWallThickness = 1.5;
clipOpeningAngle = 130;
laserDiameter = 14;
clipTolerance = 0.1;
mountLength = 39;
mountInset = 10;
mountTaper = 0.25;
mountCorner = 1.5;   
mountWidth = 30;
mountThickness = 1.75;
screwHole = 5;
screwOffset = 2;
mountWidthTolerance = 0.4;
mountThicknessTolerance = 0.3;


module dummy() {}

laserDiameter1 = laserDiameter+clipTolerance*2;
nudge = 0.001;    

module holes() {
    x = mountWidth/2-screwOffset-screwHole/2;
for (h=[[-x,2*screwHole],[x,2*screwHole],[-x,mountLength-2*screwHole],[x,mountLength-2*screwHole]]) translate([h[0],mountThickness,h[1]]) rotate([90,0,0]) cylinder(d=screwHole, h=mountThickness*3, $fn=16);  
    }

module mount(coverStickout = 2) {    
mountProfile = [
    [-mountWidth/2, 0],
    [-mountWidth/2+mountTaper, mountThickness],
    [-mountWidth/2+mountInset, mountThickness],
    [-mountWidth/2+mountInset, mountThickness+coverStickout],
    [mountWidth/2-mountInset, mountThickness+coverStickout],
    [mountWidth/2-mountInset, mountThickness],
    [mountWidth/2-mountTaper, mountThickness],
    [mountWidth/2, 0] ];
    
    render(convexity=1)
    intersection() {
        rotate([0,0,180])
        rotate([90,0,0])
        linear_extrude(height=mountThickness+coverStickout)
        polygon([[-mountWidth/2,0],
            [-mountWidth/2,mountLength-mountCorner],
            [-mountWidth/2+mountCorner,mountLength],
            [mountWidth/2-mountCorner,mountLength],
            [mountWidth/2,mountLength-mountCorner],
            [mountWidth/2,0]]);
        linear_extrude(height=mountLength) 
            polygon(mountProfile);
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
        translate([0,laserDiameter1/2+clipWallThickness,0]) 
        
        difference() {
            linear_extrude(height=clipLength) 
                spiralArc(startRadius=laserDiameter1/2,endRadius=laserDiameter1/2,thickness=clipWallThickness,startAngle=90+clipOpeningAngle/2,endAngle=360+90-clipOpeningAngle/2);
            translate([0,laserDiameter1*.85,clipLength]) rotate([-45,0,0])
            cube(center=true,laserDiameter1+2*clipWallThickness);
    translate([0,0,clipLength-clipWallThickness+nudge]) cylinder(h=clipWallThickness,d1=laserDiameter1,d2=laserDiameter1+2*clipWallThickness);
       
        }
        /*
        translate([0,laserDiameter1/2+clipWallThickness,0]) 
            linear_extrude(height=clipLength/2) {
            spiralArc(startRadius=laserDiameter1/2,endRadius=laserDiameter1/2+clipWallThickness/2,thickness=clipWallThickness,startAngle=90-clipOpeningAngle/2-laserButtonPresserArcAngle/2,endAngle=90-clipOpeningAngle/2);
            spiralArc(startRadius=laserDiameter1/2+clipWallThickness/2,endRadius=laserDiameter1/2+laserButtonStickout,thickness=clipWallThickness,startAngle=90-clipOpeningAngle/2,endAngle=90-clipOpeningAngle/2+laserButtonPresserArcAngle/2);
            spiralArc(startRadius=laserDiameter1/2+laserButtonStickout,endRadius=laserDiameter1/2+laserButtonStickout,thickness=clipWallThickness,startAngle=90-clipOpeningAngle/2+laserButtonPresserArcAngle/2,endAngle=90-clipOpeningAngle/2+laserButtonPresserArcAngle);
            }
            */
}

render(convexity=3)
difference() {
    mount(coverStickout = laserDiameter1/2+mountOffset);
    holes();
    #translate([0,mountOffset+mountThickness+laserDiameter1/2+clipWallThickness,0])
    translate([0,0,-nudge]) 
        cylinder(h=clipLength+2*nudge,d=laserDiameter1+clipWallThickness);
}

translate([0,mountThickness+mountOffset,0])
clip();
