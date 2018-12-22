use <bezier.scad>;
use <tubemesh.scad>;

inset1 = 0.2;
strength1 = .3;
angle2 = 45;
strength2 = 0.3;

rLow = 5;
strengthLow = 10;
rMid = 10;
zMid = 30;
strengthMid = 10;
angleTop = 15;
strengthTop = 20;
zTop = 60;

neckZ = 10;
twistAngle = 180;
sections = 10;

crossSection = Bezier([ [1-inset1,0], POLAR(strength1, 90), POLAR(strength2, -90+angle2), [1,1], REPEAT_MIRRORED([-1,1]), REPEAT_MIRRORED([-1,0]), REPEAT_MIRRORED([0,-1]) ]);

profile = Bezier([ [rLow,0], OFFSET([0,strengthLow]),
    OFFSET([0,-strengthMid]), [rMid,zMid], SYMMETRIC(),
    POLAR(strengthTop, -90+angleTop), [0,zTop] ]);

circle = ngonPoints(n=len(crossSection),r=1);

function section(i) =
    let(r=profile[i][0],z=profile[i][1])
    sectionZ( r * twistSectionXY( (
        let(t=min(1,z/neckZ))
        [for(i=[0:len(crossSection)-1]) (1-t)*circle[i]+t*crossSection[i]] ), z/zTop*twistAngle), z
        );

tubeMesh([for(i=[0:len(profile)-1]) section(i)], endCap=false);