use <Bezier.scad>;

length = 30;
width = 21;
spacingSmaller = 7.5;
spacingBigger = 8.5;
bottomLength = 16;
thickness = 2;
taperLength = 6;
holeSpacing = 4.5;
holeRows = 2;
holeDiameter = 1.75;
rounding = 2;

function outline(extra=0)
    = [ [ 0, spacingSmaller/2 ], LINE(),LINE(),
        [ taperLength, spacingSmaller/2+extra ], POLAR(taperLength,0), POLAR(taperLength,180),
        [ length-bottomLength+extra, spacingBigger/2+extra ],
        POLAR(spacingBigger,0),
        POLAR(spacingBigger*0.75+extra, 90),
        [ length+extra, 0 ],
        REPEAT_MIRRORED([0,1])
        ];
        
$fn = 16;

module holes() {
    for (i=[0:holeRows-1]) 
        translate([holeSpacing*(i+1),0,width/2])
            for (z=[holeSpacing/2:holeSpacing:width/2-holeDiameter])
                for (s=[-1,1])
                    translate([0,0,z*s])
                        rotate([90,0,0]) cylinder(d=holeDiameter,h=100,center=true);
}    
        
intersection() {
    difference() {        
        linear_extrude(height=width)
        difference() {
            polygon(Bezier(outline(thickness)));
            polygon(Bezier(outline(0)));
        }
        holes();
    }
    hull() {
        translate([rounding,0,rounding]) rotate([90,0,0]) cylinder(d=rounding*2,h=100,center=true);
        translate([rounding,0,width-rounding]) rotate([90,0,0]) cylinder(d=rounding*2,h=100,center=true);
        translate([length,-50,0]) cube([1,100,width]);
    }
}