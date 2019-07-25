use <tubemesh.scad>;

//<params>
diameter = 10;
height = 40;
baseLipThickness = 2;
baseLip = 3;
topLip = 1;
topLipExtraThickness = 2;
holdingAngle = 45;
slippingAngle = 30;
slippingRadiusReduction = 0.5;
incutBelowTopLip = 3;
incutFractionOfDiameter = 0.4;
//</params>

module dummy(){}

nudge = 0.001;

module pin(diameter=10,height=40,baseLip=3,baseLipThickness=4,lip=1,extraThickness=2,holdingAngle=45,slippingRadiusReduction=1,slippingAngle=30,incutFraction=0.4,incutBelowTopLip=2,$fn=30) {
    r = diameter/2;
    r2 = diameter/2-slippingRadiusReduction;
    x1 = incutFraction * r;
    vSteps = 2*$fn;
    function lipX(lip,y,r) =
        lip+sqrt(r*r-y*y);
    holdingHeight = tan(90-holdingAngle) * lip;
    slippingHeight = tan(90-slippingAngle) * (lip+slippingRadiusReduction);
    echo(slippingHeight);
    function getLipZR(j) =
        j < vSteps/2 ?
            let(t=j/(vSteps/2-1))
            [t*lip, t*holdingHeight, r] :
            let(t=(j-vSteps/2)/(vSteps/2-1))
            [(1-t)*lip, holdingHeight+extraThickness+t*slippingHeight, r*(1-t)+r2*t];
    function lipSection(j) =
        let(lipZR = getLipZR(j),
            lip = lipZR[0],
            z = lipZR[1],
            r = lipZR[2],
            y1 = sqrt(r*r-x1*x1))
        concat([for(i=[0:$fn-1]) let(t=i/($fn-1), y=-y1*(1-t)+y1*t, x=lipX(lip,y,r)) [x,y,z]], [for(i=[0:$fn-1]) let(t=i/($fn-1), y=y1*(1-t)-y1*t, x=-lipX(lip,y,r)) [x,y,z]]);
            
    y1 = sqrt(r*r-x1*x1);
    translate([0,0,height+baseLipThickness])
    difference() {
        tubeMesh([for(j=[0:vSteps-1]) lipSection(j)]);
        cube([x1*2,y1*2+2*nudge,2*(holdingHeight+extraThickness+slippingHeight+nudge)],center=true);
    }
    difference() {
        union() {
            cylinder(h=height+baseLipThickness,d=diameter);
            cylinder(h=baseLipThickness,d=diameter+baseLip);
        }
        translate([0,0,height+baseLipThickness]) scale([1,1,incutBelowTopLip/x1]) rotate([90,0,0]) cylinder(r=x1,h=2*(nudge+diameter),center=true);
    }
        
}

module pinHole(diameter=10,height=40,lip=1,holdingAngle=45,tolerance=0.2,$fn=30) {
    holdingHeight = tan(90-holdingAngle) * lip;
    cylinder(d=diameter+tolerance*2,h=nudge+height+holdingHeight);
    translate([0,0,height])
    cylinder(d1=diameter+tolerance*2,d2=diameter+lip*2+tolerance*2,h=holdingHeight+nudge);
}

//<skip>
pin(diameter,height,baseLip=baseLip,baseLipThickness=baseLipThickness,lip=topLip,extraThickness=topLipExtraThickness,holdingAngle=holdingAngle,slippingRadiusReduction=slippingRadiusReduction,slippingAngle=slippingAngle,incutFraction=incutFractionOfDiameter,incutBelowTopLip=incutBelowTopLip);

translate([diameter*2,0,0])
pinHole(diameter,height,topLip,holdingAngle);
//</skip>