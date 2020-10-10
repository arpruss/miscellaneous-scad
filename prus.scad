use <tubeMesh.scad>;

//<params>
iconWidth = 12;
iconLength = 20;
lineThickness = 3;
iconHeight = 4;
handleWidth = 14;
handleLength = 22;
handleHeight = 18;
handleInsetRatio = 0.25;
stipple = 0.5;
//</params>
$fn = 64;
handleSlices = 24;

module icon() {
    square([lineThickness,iconLength],center=true);
    translate([0,-iconLength/2+2/3*iconLength]) square([iconWidth,lineThickness],center=true);
    translate([iconWidth/4,-iconLength/2+1/3*iconLength]) square([iconWidth/2,lineThickness],center=true);
}

function ellipse(r1,r2) = [for(i=[0:1:$fn-1]) let(angle=i/$fn*360) [r1*cos(angle),r2*sin(angle)]];
    
function baseProfile(t) = 1-0.5*sqrt(1-pow(1.8*(t-0.5),2));
    
function profile(t) = (baseProfile(t)-baseProfile(0.5))/(baseProfile(1)-baseProfile(0.5))*handleInsetRatio+(1-handleInsetRatio);
    
sections = [for(i=[0:handleSlices-1]) let(t=i/(handleSlices-1))
        sectionZ(ellipse(handleWidth/2*profile(t),handleLength/2*profile(t)),t*handleHeight)];

module stipples() {
    n = ceil(iconLength / stipple);
    for(i=[0:1:n]) {
        translate([0,-iconLength/2+i*stipple]) tubeMesh([ [[-iconWidth/2,stipple,0],[-iconWidth/2,stipple,stipple],[-iconWidth/2,0,stipple]], [[iconWidth/2,stipple,0],[iconWidth/2,stipple,stipple],[iconWidth/2,0,stipple]]]);
    }
}

tubeMesh(sections);
translate([0,0,handleHeight-0.01])
difference() {
    linear_extrude(height=iconHeight) mirror([1,0]) icon();
    translate([0,0,iconHeight-stipple+0.001]) stipples();
}
