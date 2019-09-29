use <tubemesh.scad>;
use <bezier.scad>;
use <paths.scad>;

//<params>
taper = 5;
diameter = 38;
height = 180;
twists = 1.75;
lobes = 1;
lobeOffset = 5;
slices = 40;
bottomAngle = 20;
bottomTension = 40;
topOffset = 60;
topTension = 50;
topAngle = 20;
bottomAngleFeatheringParameter = 0.5;
rotation = 0;
flipHorizontally = 0; // [0:no, 1:yes]
rescale = 1;
// set to zero for no slit
mountSlitThickness = 4; 
mountSlitDepth = 10;
mountSlitHeight = 14;
mountSlitXOffset = 0;
mountSlitYOffset = 0;
tolerance = 0.25;
//</params>


module dummy() {}

module horn(taper=5,diameter=38,height=180,twists=1.75,lobes=1,lobeOffset=5,slices=40,bottomAngle=20,bottomTension=40,topOffset=60,topTension=50,topAngle=20,
    bottomAngleFeatheringParameter=0.5) {
    nudge = 0.01;

    r = diameter/2;
    precision = 1/slices;

    function base(twistAngle) = lobes == 1 ? [ for(i=[0:5:360]) r*[cos(i),sin(i)]] : [ for(i=[0:5:360]) (r+lobeOffset*abs(cos((i)*lobes/2)))*[cos(i-twistAngle),sin(i-twistAngle)]];
        
    edge = [ [r,0],SHARP(),SHARP(),
             [taper,height-1.5*taper],SMOOTH_ABS(.25*taper),OFFSET([taper,0]),
            [0,height] ];
    core = [ [0,0],POLAR(bottomTension,90+bottomAngle),POLAR(topTension,-90-topAngle),[topOffset,height] ];

    profile = Bezier(edge,precision=precision,optimize=false);
    corePath = Bezier(core,precision=precision,optimize=false);
    coreInterp = interpolationData(corePath);

    function coreAt(t) = interpolateByParameter(coreInterp,t);
    function angleAt(t) =
        let(b=coreAt(t+0.001),
            a=coreAt(t),
            angle=-atan2(b[0]-a[0],b[1]-a[1]),
            u=bottomAngleFeatheringParameter*bottomTension/height)
            t<=u ? angle*t/u : angle;

    function xzRotate(angle,point) =
        let(m=[[cos(angle),0,-sin(angle)],
               [0,1,0],
               [sin(angle),0,cos(angle)]])
           m*point;

    function tiltSection(section,fakeHeight) =
        let(t = fakeHeight/height,
            p = coreAt(t))
            [for(v=section) [p[0],0,p[1]] + xzRotate(angleAt(t), [v[0],v[1],0])];

    sections = [for(p=profile) tiltSection(p[0]/r*base(p[1]/height*360*twists),p[1])];
        
    tubeMesh(sections);
}
    
module mountSlit(mountSlitThickness=4, mountSlitDepth=10, mountSlitHeight=14) {
    if (mountSlitThickness>0) {
        nudge = 0.01;
        hull() {
            cube([mountSlitThickness+2*tolerance,mountSlitDepth+2*tolerance,2*mountSlitHeight+2*tolerance+nudge],center=true);
            translate([0,0,2*tolerance+mountSlitHeight+max(mountSlitThickness/2,mountSlitDepth/2)]) cube([nudge,nudge,nudge],center=true);
        }
    }
}

difference() {
    scale(rescale)
        mirror([flipHorizontally?1:0,0,0])
            rotate([0,0,rotation]) 
                horn(taper=taper,diameter=diameter,height=height,twists=twists,lobes=lobes,lobeOffset=lobeOffset,slices=slices,bottomAngle=bottomAngle,bottomTension=bottomTension,topOffset=topOffset,topTension=topTension,topAngle=topAngle,bottomAngleFeatheringParameter=bottomAngleFeatheringParameter);
    
    translate([mountSlitXOffset,mountSlitYOffset,0])
        mountSlit(mountSlitThickness=mountSlitThickness,mountSlitDepth=mountSlitDepth,mountSlitHeight=mountSlitHeight);
}
