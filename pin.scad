use <tubemesh.scad>;

//<params>
diameter = 5;
height = 15;
baseLipThickness = 4;
baseLip = 3;
topLip = 1;
topLipExtraThickness = 2;
topLipHoldingAngle = 45;
topLipSlippingAngle = 30;
slippingReduction = 0.5;
incutBelowTopLip = 3;
incutFractionOfDiameter = 0.5;
//</params>

module dummy(){}

nudge = 0.001;

module topLip(diameter,lip,extraThickness,holdingAngle,slippingReduction,slippingAngle,incutFraction,$fn=20) {
    r = diameter/2;
    r2 = diameter/2-slippingReduction;
    x1 = incutFraction * r;
    vSteps = 2*$fn;
    function lipX(lip,y,r) =
        lip+sqrt(r*r-y*y);
    holdingHeight = tan(90-holdingAngle) * lip;
    slippingHeight = tan(90-slippingAngle) * (lip+slippingReduction);
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
    difference() {
        tubeMesh([for(j=[0:vSteps-1]) lipSection(j)]);
        cube([x1*2,y1*2+2*nudge,2*(holdingHeight+extraThickness+slippingHeight+nudge)],center=true);
    }
        
}

//<skip>
topLip(diameter,topLip,topLipExtraThickness,topLipHoldingAngle,slippingReduction,topLipSlippingAngle,incutFractionOfDiameter);
//</skip>