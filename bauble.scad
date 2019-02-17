use <bezier.scad>;
use <tubemesh.scad>;

// <params>
/* [Global] */
output = 0; // [0:Icycle, 1:Hanger]

/* [Icicle] */
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

/* [Attachment] */
bottom_height = 1.75; 
diameter = 10; 
holeWall = 1.75; 
holeSize = 1.6;
blobSize = 0; 
// </params>

module dummy() {}

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

if (output == 1) {
    $fn = 36;
    intersection() {
        union() {
            cylinder(d=diameter,h=bottom_height);
            render(convexity=2)
            for (i=[0:36:360]) rotate([0,0,i]) translate([diameter/2,0,0]) cylinder(d=blobSize,h=bottom_height);
                
            render(convexity=2)
            translate([0,0,bottom_height])
            scale([1,1,1.25])
            rotate([0,90,0])
            translate([0,0,-holeWall/2])
            difference() {
                linear_extrude(height=holeWall) circle(d=holeSize*2+holeWall*2);
                translate([-0.25*holeWall,0,-50]) cylinder(d=holeSize*2,h=100);
            }
        }
        cylinder(d=100,h=100);
    }
}
else {
    tubeMesh([for(i=[0:len(profile)-1]) section(i)], endCap=false);
}