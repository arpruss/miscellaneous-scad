use <tubeMesh.scad>;

//<params>
hoopDiameter_millimeters = 0; // set to zero to use inches; set both millimeters and inches to zero for straight
hoopDiameter_inches = 33.5; // set to zero to use millimeters 
sleeveDiameter = 18.8; // should match the outer diameter of the tubing
barbOuterDiameter = 15.7; // should be a little bigger than the inner diameter of the tubing so it can bit into it
reinforcementScrewHole = 3.8; // put a machine screw through the middle to reinforce 
innerAreaThickening = 1;
reinforcementScrewHolePostDiameter = 8;
barbsPerSide = 7;
barbLength = 4;
barbHeight = 1.5;
barbSpacing = 0;
barbTipFlat = 0.3;
firstBarbSpacing = 5;
sleeveLength = 4;
innerHoleDiameter = 0; // set to zero for solid
pegsPerSide = 2;
pegHoleWallMinimum = 2;
pegRadialTolerance = .5; // .5 for PETG, .28 for ABS?
pegChamfer = .48; 
pegHeightTolerance = 1; // 1 for PETG, .75 for ABS?
smoothness = 80;
split = 0; //[0:No,1:Yes]
select = 0; //[0:All, 1:One half, 2:Pegs only, 3:Single peg]
//</params>

hoopDiameter = hoopDiameter_inches == 0 ? hoopDiameter_millimeters : hoopDiameter_inches * 25.4;

module dummy() {} 

hoopR = hoopDiameter / 2;
barbR = barbOuterDiameter / 2;

function merge(z) = 
    [for(a=z) for(b=a) b];
        
function zToAngle(z) = z/(2*hoopR*PI)*360;

function ring(z,r) =
    let(profile=ngonPoints(n=smoothness,r=r))
    hoopDiameter == 0 ?
        sectionZ(profile,z) :
    let(angle=zToAngle(z))
        [for(p=profile) 
            let(r1=hoopR+p[0]) [r1*cos(angle),p[1],r1*sin(angle)]];

function barb(distance,direction=1,first=false) =
    let(z=distance*direction)
    [ ring(z,barbR-barbHeight+(first?innerAreaThickening:0)),
      ring(z,barbR),
      ring(z+direction*barbTipFlat,barbR),
      ring(z+direction*barbLength,barbR-barbHeight) ];
        
 halfLength = sleeveLength/2+firstBarbSpacing+
            (barbSpacing+barbLength)*(barbsPerSide-1)+barbLength;
        
function barbZ(i) = sleeveLength/2+firstBarbSpacing+
            (barbSpacing+barbLength)*i;
    
screwDX = hoopR==0?0:-.5*cos(halfLength/(2*hoopR*PI)*360);
endAngle = zToAngle(halfLength);
screwR = sqrt(pow(screwDX + hoopR,2)+pow(halfLength,2));
farPostR = screwR+reinforcementScrewHolePostDiameter/2;
postLength = 2*farPostR*sin(endAngle);

module full() {
    barbs = [for(i=[0:barbsPerSide-1])
        barb(barbZ(i),first=(i==0))];
    basic = concat([ring(sleeveLength/2,sleeveDiameter/2),ring(sleeveLength/2,barbR-barbHeight+innerAreaThickening)],merge(barbs));
    half = hoopR<=0 || reinforcementScrewHole<= 0 || reinforcementScrewHole <= 0 ? basic : concat(basic,[[for (p=ngonPoints(n=smoothness,d=reinforcementScrewHolePostDiameter)) [hoopR+screwDX+p[0],p[1],postLength/2]],]);
    function revZ(section)=[for(p=section) [p[0],p[1],-p[2]]];
    full = concat([for(i=[0:len(half)-1]) revZ(half[len(half)-1-i])],half);
    rotate([-90,0,0])
    tubeMesh(full);
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
        if (hoopDiameter>0 && i!=0) {
            angle = z/(2*hoopR*PI)*360;
            translate([cos(angle)*hoopR,sin(angle)*hoopR,0]) cylinder(r=pegR,h=pegHoleR*2,$fn=32,center=true);
        }
        else {
            translate([0,z,0]) cylinder(r=pegR,h=pegHoleR*2,$fn=32,center=true);
        }
    }
}

module main() {
     screwDX = hoopR==0?0:-.5*cos(halfLength/(2*hoopR*PI)*360);
     endAngle = zToAngle(halfLength);
     screwR = sqrt(pow(screwDX + hoopR,2)+pow(halfLength,2));
     farPostR = screwR+reinforcementScrewHolePostDiameter/2;
     postLength = 2*farPostR*sin(endAngle);
     difference() {
         translate([-hoopR,0,0]) {
            difference() {
                full();
                inside(smoothness/4);
                if (split) {
                    holes();
                    translate([-halfLength*2-hoopR+hoopR,-halfLength*2-hoopR,-barbR*2]) cube([halfLength*4+hoopR*2,halfLength*4+hoopR*2,barbR*2]);
                }
            }
        }
        if (reinforcementScrewHole>0) {
            translate([screwDX,0,0]) 
            rotate([90,0,0]) cylinder(d=reinforcementScrewHole,$fn=16,h=halfLength*4,center=true);
        }
    }
 }
 

if (!split || (select!=2 && select !=3)) main();
if (split) {
    delta = max(sleeveDiameter,barbOuterDiameter)+10.;
    if (select==0) translate([delta,0,0]) main();
    if ((select==0 || select==2 || select == 3) && pegsPerSide>0) {
        for (i=[0:select == 3 ? 0 : pegsPerSide*2])
            translate([-delta,i*pegR*2.5,0]) peg();
    }
}
 