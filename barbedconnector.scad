use <tubeMesh.scad>;

//<params>
barbsPerSide = 7;
barbOuterDiameter = 15.7;
barbLength = 4;
barbHeight = 1.5;
barbSpacing = 0;
barbTipFlat = 0.3;
firstBarbSpacing = 5;
sleeveDiameter = 18.8;
sleeveLength = 4;
hoopDiameter = 863.6; // set to zero for straight (33.5" = 817mm; 34" = 863.6mm; 36" = 914.4mm)
innerHoleDiameter = 0; // set to zero for solid
pegsPerSide = 2;
pegHoleWallMinimum = 2;
pegRadialTolerance = .28;
pegChamfer = .5;
pegHeightTolerance = .5;
smoothness = 80;
split = 1; //[0:No,1:Yes]
select = 0; //[0:All, 1:One half, 2:Pegs only]
//</params>

module dummy() {} 

hoopR = hoopDiameter / 2;
barbR = barbOuterDiameter / 2;

function merge(z) = 
    [for(a=z) for(b=a) b];

function ring(z,r) =
    let(profile=ngonPoints(n=smoothness,r=r))
    hoopDiameter == 0 ?
        sectionZ(profile,z) :
    let(angle=z/(2*hoopR*PI)*360)
        [for(p=profile) 
            let(r1=hoopR+p[0]) [r1*cos(angle),r1*sin(angle),p[1]]];

function barb(distance,direction=1) =
    let(z=distance*direction)
    [ ring(z,barbR-barbHeight),
      ring(z,barbR),
      ring(z+direction*barbTipFlat,barbR),
      ring(z+direction*barbLength,barbR-barbHeight) ];
        
 halfLength = sleeveLength/2+firstBarbSpacing+
            (barbSpacing+barbLength)*(barbsPerSide-1)+barbLength;
        
function barbZ(i) = sleeveLength/2+firstBarbSpacing+
            (barbSpacing+barbLength)*i;
    
 module half() {
     barbs = [for(i=[0:barbsPerSide-1])
        barb(barbZ(i))];
    rotate([hoopDiameter==0?-90:0,0,0]) 
    tubeMesh(concat([ring(-.001,sleeveDiameter/2),ring(sleeveLength/2,sleeveDiameter/2),ring(sleeveLength/2,barbR-barbHeight)],merge(barbs)));
     
 }
 
 module inside(smoothness) {
     if (innerHoleDiameter>0) {
         rings = [for(i=[-smoothness:smoothness])
                let(z=i/smoothness*(halfLength+.01)) ring(z,innerHoleDiameter/2)];
         rotate([90,0,0]) tubeMesh(rings);
     }
 }
 
pegHoleR = (barbR-barbHeight-pegHoleWallMinimum)/sqrt(2);
pegR = pegHoleR-pegRadialTolerance;
 
function pegZ(n) = n/pegsPerSide*(halfLength-pegR*2);
 
module chamferedCylinder(d=10,r=undef,h=10,chamfer=1) {
    diameter = r==undef ? d : 2*r;
    cylinder(d=diameter,h=h-chamfer+0.001,$fn=32);

    translate([0,0,h-chamfer])
    cylinder(d1=diameter,d2=diameter-chamfer*2,h=chamfer,$fn=32);
}

 
module peg() {
    pegH = pegHoleR - pegHeightTolerance;
    translate([0,0,pegH]) {
        translate([0,0,-.01]) chamferedCylinder(r=pegR,h=pegH+.01,chamfer=pegChamfer);
        mirror([0,0,-1]) chamferedCylinder(r=pegR,h=pegH,chamfer=pegChamfer);
    }
}
 
module holes() {
    for (i=[-pegsPerSide:pegsPerSide]) {
        z = i<0 ? -pegZ(-i) : pegZ(i);
        if (hoopDiameter>0) {
            angle = z/(2*hoopR*PI)*360;
            translate([cos(angle)*hoopR,sin(angle)*hoopR,0]) cylinder(r=pegR,h=pegHoleR*2,$fn=32,center=true);
        }
        else {
            translate([0,z,0]) cylinder(r=pegR,h=pegHoleR*2,$fn=32,center=true);
        }
    }
}
 
 module main() {
     translate([-hoopR,0,0]) {
        difference() {
            union() {
                half();
                mirror([0,1,0]) half();
            }
            inside(smoothness/4);
            if (split) {
                holes();
                translate([-halfLength*2-hoopR+hoopR,-halfLength*2-hoopR,-barbR*2]) cube([halfLength*4+hoopR*2,halfLength*4+hoopR*2,barbR*2]);
            }
        }
    }
 }
 

if (select!=2) main();
if (split) {
    delta = max(sleeveDiameter,barbOuterDiameter)+10.;
    if (select==0) translate([delta,0,0]) main();
    if ((select==0 || select==2) && pegsPerSide>0) {
        for (i=[0:pegsPerSide*2])
            translate([-delta,i*pegR*2.5,0]) peg();
    }
}
 