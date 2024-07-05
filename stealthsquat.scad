use <Bezier.scad>
use <roundedSquare.scad>;
//include <stealthsquatoriginal.scad>

//<params>
handleWidth = 40;
handleLength = 140;
width = 600;
height = 325;
handleSlant = 9;
phoneHole = 6.4;
strapSlitWidth = 5;
strapSlitLength = 39;
strapEndLength = 45.2;
strapEndWidth = 22.35;
holderExtra = 20;


thickness = 17.6;
//</params>


handleH = handleWidth * cos(handleSlant);

outerProfile = 
    [
    [0,-height*.3], POLAR(width/6,180),
        POLAR(width/10,0),
        [-width/2*.75,-height*.5],
        POLAR(width/20,180),
        POLAR(width/8,-90-handleSlant),
        [-width*.48-handleLength*sin(handleSlant)*.4,-handleLength*.4*cos(handleSlant)],LINE(),LINE(),
        [-width*.48+handleLength*sin(handleSlant)*.6,handleLength*.6*cos(handleSlant)], POLAR(width/12,90-handleSlant), POLAR(width/2.3,180), [0,height*0.5],  REPEAT_MIRRORED([1,0])];
        
innerProfile = [ 
    [-width/2*.7,-height*.435+handleWidth],
    POLAR(width/30,180),
    POLAR(width/15,-90-handleSlant),
        [-width*.48-handleLength*sin(handleSlant)*.4+handleH,-handleLength*.4*cos(handleSlant)-handleH*tan(handleSlant)],LINE(),LINE(),
        [-width*.48+handleLength*sin(handleSlant)*.6+handleH,handleLength*.6*cos(handleSlant)-handleH*tan(handleSlant)],
        POLAR(width/15,90-handleSlant), 
        POLAR(width/4.5,90-handleSlant),
        [-width*.5*.3,0],
        POLAR(width/6,-90-handleSlant),
        POLAR(width/30,0), 
    [-width/2*.7,-height*.435+handleWidth],
        
       ];
        
//BezierVisualize(outerProfile,lineThickness=1,controlLineThickness=1,nodeSize=5);
//BezierVisualize(innerProfile,lineThickness=1,controlLineThickness=1,nodeSize=5);

module endHolder() {
    translate([-width/3.5,0,0]) 
    {
        difference() {
            roundedSquare([strapEndLength+holderExtra*2,strapEndWidth+holderExtra*2],center=true,radius=10);
            square([strapEndLength,strapEndWidth],center=true);
        }
    square([strapSlitLength,strapSlitWidth],center=true);
    }
}

module main() {
    difference() {
        polygon(Bezier(outerProfile));
        polygon(Bezier(innerProfile));
        mirror([1,0]) polygon(Bezier(innerProfile));
        translate([0,height*.25]) circle(d=phoneHole);
        square([strapEndLength,strapEndWidth],center=true);
    }
    square([strapSlitLength,strapSlitWidth],center=true);
    y1=-height*.5+strapEndWidth/2+holderExtra;
}

//linear_extrude(height=thickness) 
{
    main();
    endHolder();
}