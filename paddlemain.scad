use <bezier.scad>;
use <paths.scad>;
use <tubemesh.scad>;

buttonWidth = 11.9;
buttonHeight = 3.1;
buttonTolerance = 0.3;
topWall = 2;
sideWall = 2.5;
width = 50;
length = 80;
bulgeAngle = 10;
bulgeTension = 0.2;
bulgeFraction = 0.05;
corner = 4;
height = 22;
cableHole = 3.8;
contactHole = 2.5;
contactHorizontalSpacing = 5.1;
contactVerticalSpacing = 12.15;
potShaftHole = 7.5;
potIndexHole = 2.6;
potIndexDistance = 8.3;

buttonPosition = 0.2;

function edges(offset=0) = 
    let(width=width+2*offset,
        length=length+2*offset)
    Bezier(
        [ [0,-length/2], LINE(), LINE(), [width/2-corner,-length/2],
          POLAR(corner/2,0),
          SMOOTH_ABS(corner/2),
          [width/2,-length/2+corner],
          POLAR(bulgeTension*length,90-bulgeAngle),
          POLAR(bulgeTension*length,-90),
          [width/2+length*bulgeFraction,0],
          REPEAT_MIRRORED([0,1]),
          REPEAT_MIRRORED([1,0]) ] );
          
outer = edges();
interp = interpolationData(outer);
peri = totalLength(interp);
buttonDistance = peri/2-width/2-buttonPosition*length;
buttonZ = height/2;


module bowl() {
    linear_extrude(height=topWall) polygon(outer);
    linear_extrude(height=height) difference() {
        polygon(outer);
        polygon(edges(-sideWall));
    }
}

module onFace(distance,horizOffset,vertOffset) {
    d = distance+horizOffset;
    z = buttonZ+vertOffset;
    xy = interpolateByDistance(interp,d);
    tangent = getTangentByDistance(interp,d);
    angle = atan2(tangent[1],tangent[0])-90;
    translate([0,0,z])
    translate(xy)
    rotate([0,0,angle])
    rotate([0,90,0])
    rotate([0,0,90])
    children();
}

module hole(distance,horizOffset,vertOffset,diameter) {
    onFace(distance,horizOffset,vertOffset) cylinder(h=3*sideWall+width/2,d=diameter,$fn=16,center=true);
}

module buttonHolder(positive=true) {
    function layer(w,nudge=0) = 
        [[-w/2,-height/2-nudge],[w/2,-height/2-nudge],[w/2,height/2+nudge],[-w/2,height/2+nudge]];
    
    w = buttonWidth+2*buttonTolerance;
    
    translate([0,0,-1])
    if (positive) {
        tubeMesh(
            [sectionZ(layer(w+2*buttonHeight),0),
            sectionZ(layer(w+2*buttonHeight),2),
            sectionZ(layer(w),2+buttonHeight)]);
    }
    else {
        tubeMesh([sectionZ(layer(w),1),sectionZ(layer(w,1),3+buttonHeight)]);
        for(i=[-1,1]) for(j=[-1,1]) translate([contactHorizontalSpacing/2*i,contactVerticalSpacing/2*j,0]) cylinder(d=contactHole,h=width/2,center=true);
    }
}

difference() {
    union() {
        bowl();
        onFace(peri/2, 0, 0)
            translate([0,0,-0.1])
            cylinder(d1=3*cableHole,h=cableHole,d2=cableHole);
        onFace(buttonDistance,0,0) buttonHolder();
    }
    hole(peri/2, 0,0, cableHole);
    cylinder(h=3*topWall,d=potShaftHole,center=true);
    translate([-potIndexDistance,0,0])
    cylinder(h=3*topWall+100,d=potIndexHole,center=true);
        onFace(buttonDistance,0,0) buttonHolder(positive=false);
}
