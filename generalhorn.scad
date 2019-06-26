use <tubemesh.scad>;
use <bezier.scad>;
use <paths.scad>;

//<params>
taper = .015;
diameter = 15;
height = 100;
twists = 1.75;
lobes = 3;
lobeOffset = 5;
slices = 80;
bottomAngle = 40;
bottomTension = 40;
topTension = 30;
topOffset = 30;
topAngle = 40;
bottomAngleFeatheringParameter = 0.5;
//</params>


module dummy() {}

r = diameter/2;
precision = 1/slices;

function base(twistAngle) = lobes == 1 ? [ for(i=[0:5:360]) r*[cos(i),sin(i)]] : [ for(i=[0:5:360]) (r+lobeOffset*abs(cos((i)*lobes/2)))*[cos(i-twistAngle),sin(i-twistAngle)]];
    
edge = [ [r,0],SHARP(),SHARP(),
         [height*taper,height-1.5*height*taper],SMOOTH_ABS(.25*taper*height),OFFSET([height*taper,0]),
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
//echo(profile);
//BezierVisualize(edge,nodeSize=0.4);    
//BezierVisualize(core,nodeSize=0.4);    
tubeMesh(sections);
