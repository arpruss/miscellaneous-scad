use <tubemesh.scad>;

circleSeparation = 150;
radius = 40;
rectHeight = 50;
baseCurveHeight = 5;
height=10;
wallThickness=2;

$fn = 36;

function outline(sep, rectHeight, radius, $fn=36) = 
    let(
        angle0=asin((radius-rectHeight)/radius),
        angle1=180-asin((radius-rectHeight)/radius)) 
    concat( 
        [for(i=[1:$fn-1]) let(t=i/$fn,
            angle=angle1*(1-t)+(360+90)*t)
        [sep/2,0]+radius*[cos(angle),sin(angle)]],
        [for(i=[1:$fn-1]) let(t=i/$fn,
            angle=90*(1-t)+(360+angle0)*t)
        [-sep/2,0]+radius*[cos(angle),sin(angle)]]);

function delta0(z,startAngle=90) =         
    let(baseCurveRadius=baseCurveHeight/sin(startAngle),
        angle=asin((baseCurveHeight-z)/baseCurveRadius))
        baseCurveRadius*cos(angle);

function delta(h,startAngle=90) = delta0(h,startAngle=startAngle)-delta0(baseCurveHeight,startAngle=startAngle);     
        
        
module solidBowl(height=height,startAngle=45,delta=0) {
    
    sections = [for(i=[0:$fn])
    let(t=i/$fn,
    delta = delta(t*baseCurveHeight,startAngle=startAngle))
    sectionZ(outline(circleSeparation,rectHeight+2*delta,radius+delta),t*baseCurveHeight)];

tubeMesh(concat(sections,[sectionZ(outline(circleSeparation,rectHeight+2*delta,radius+delta),height)]));
}

module hollowBowl(height=height,startAngle=45) {
    difference() {
        solidBowl(height=height,startAngle=90);
        translate([0,0,wallThickness])
        solidBowl(height=height,startAngle=90,delta=-wallThickness);
    }
}

hollowBowl();
