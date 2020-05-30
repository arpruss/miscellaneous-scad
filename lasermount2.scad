use <tubemesh.scad>;

//<params>
snapLength = 32;
transitionAngle = 8;
snapWall = 1.5;
snapAngle = 230;
switchOffset = 1.25;
switchAreaLength = 6;
preSwitchLength = 3;
switchAreaAngularSize = 20;
cutLength = 4;
laserDiameter = 14.13;
laserTolerance = 0;
screwHole = 4;
screwOffsetFromEdge = 3;
hotshoe = false;
hotshoeWidthTolerance = 0.4;
hotshoeThicknessTolerance = 0.3;
mountWidth = 30; // irrelevant in hotshoe mode
mountWall = 2;  // irrelevant in hotshoe mode
mountOffset = 0;  // irrelevant in hotshoe mode
mountBarThickness = 10;  // irrelevant in hotshoe mode
mountRadiusOfCurvature = 0;  // 0 for flat; irrelevant in hotshoe mode
switchOnRight = true;
layers = 60;
//</params>

module dummy() {}

hotshoeLength = 18;
hotshoeInset = 3.2;
hotshoeTaper = 0.25;
hotshoeCorner = 1.5;   
hotshoeWidth = 18.52-hotshoeWidthTolerance;
hotshoeThickness = 1.95-hotshoeThicknessTolerance;

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
    rotate([0,180,0])
    rotate([-90,0,0])
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



nudge = 0.001;

function getR(angle,r1,arcAngle,r2,widerAngle,transitionAngle) =
    let(a0=arcAngle/2-widerAngle-transitionAngle)
    angle <= a0 ? r1 :
    angle <= a0+transitionAngle ? let(t=(angle-a0)/transitionAngle) (1-t)*r1+t*r2 : r2;

function arc(r1=10,arcAngle=230,r2=11,widerAngle=20,transitionAngle=15,steps=64) =
        [for (i=[0:steps]) let(angle=-arcAngle/2*(steps-i)/steps+arcAngle/2*i/steps) 
            getR(angle,r1,arcAngle,r2,widerAngle,transitionAngle)*[cos(angle),sin(angle)]];
        
function reverse(v) = [for(i=[len(v)-1:-1:0]) v[i]];
    
function wallAt(z,r1=10,arcAngle=230,r2=11,widerAngle=20,transitionAngle=5,wall=1.5,switchLength=10,cutLength=8,cutArcAngle=30,height=30,insideOnly=false,steps=64) =
    let(d=1.5*(r2-r1),
        t=z<preSwitchLength?1:
          z<preSwitchLength+d?1-(z-preSwitchLength)/d:
          z<preSwitchLength+d+switchLength?0:
          z<preSwitchLength+switchLength+2*d?(z-switchLength-preSwitchLength-d)/d:
          1,
        r2_=r2*(1-t)+r1*t,
        u=z<height-cutLength?0:(z-(height-cutLength))/cutLength,
        arcAngle_=arcAngle*(1-u)+cutArcAngle*u,
        a2=arc(r1=r1,arcAngle=arcAngle_,r2=r2_,widerAngle=widerAngle,transitionAngle=transitionAngle,steps=steps))
        sectionZ(insideOnly?a2:concat(arc(r1=r1+wall,arcAngle=arcAngle_,r2=r2_+wall,widerAngle=widerAngle,transitionAngle=transitionAngle,steps=steps),
    reverse(a2)),z);

module snap(inside=false) {
    r1 = laserDiameter/2+laserTolerance;
    r2 = r1 + laserTolerance+switchOffset; 
    h = inside?snapLength+2*nudge:snapLength;
    translate([0,0,inside?-nudge:0])
    rotate([0,0,90])
    translate([-r1-snapWall,0,0]) 
tubeMesh([for(z=[0:h/layers:h]) wallAt(z,arcAngle=snapAngle,widerAngle=switchAreaAngularSize,r1=r1,r2=r2, cutArcAngle=inside?snapAngle:30, height=h,transitionAngle=transitionAngle, insideOnly=inside, cutLength=cutLength, steps=layers)]);
}

module mountPlate(plate=true) {
    if (plate && mountRadiusOfCurvature) {
        mountCurved();
        rotate([90,0,0])
            translate([-mountBarThickness/2,0,0]) cube([mountBarThickness,hotshoe?hotshoeLength:snapLength,mountOffset+laserDiameter/2+snapWall/2]);
    }
    else {
        rotate([90,0,0]) {
            if(plate)
            linear_extrude(height=mountWall+nudge)
            difference() {
                translate([-mountWidth/2,0]) square([mountWidth,snapLength]);
                for (s=[-1,1]) for(y=[screwOffsetFromEdge+screwHole,snapLength-(screwOffsetFromEdge+screwHole)]) translate([s*(mountWidth/2-screwOffsetFromEdge-screwHole/2),y]) circle(d=screwHole,$fn=16);
            }
            else 
                hotshoe();
            translate([-mountBarThickness/2,0,0]) cube([mountBarThickness,hotshoe?hotshoeLength:snapLength,mountOffset+laserDiameter/2+snapWall/2]);
        }
    }
}

module mountCurved() {
    circum = 2 * PI * mountRadiusOfCurvature;
    angle = 360 * mountWidth / circum;
    off = screwOffsetFromEdge + screwHole/2;
    holeAngularOffset = 360 * off / circum;
    translate([0,mountRadiusOfCurvature,0])
    difference() {
        rotate([0,0,-angle/2-90]) rotate_extrude($fn=layers*360/angle,angle=angle) translate([mountRadiusOfCurvature,0]) square([mountWall,snapLength]);
    for(z=[snapLength-off,off]) translate([0,0,z]) for(a=[angle/2-holeAngularOffset,-angle/2+holeAngularOffset]) rotate(a) translate([0,-mountRadiusOfCurvature,0]) rotate([90,0,0]) cylinder(h=3*mountWall,$fn=16,center=true);
    }
}

//mountCurved();

module main(plate=!hotshoe) {
    translate([0,-mountOffset+nudge,0]) snap();
    difference() {
        mountPlate(plate);
        translate([0,-mountOffset+nudge,0]) snap(inside=true);
    }
}

if (switchOnRight) mirror([1,0,0])
 main();
else main();
//hotshoe();