use <Bezier.scad>;

collarHeight = 5;
coneLength = 20;
outerDiameter = 17.2;
bottomTaper = 1;

outline = [ [0,0], LINE(), LINE(), [(outerDiameter-bottomTaper)/2,0], LINE(), LINE(),
            [outerDiameter/2,collarHeight], POLAR(coneLength*0.5,90), POLAR(outerDiameter*.5,0), [0,collarHeight+coneLength] ];
            
rotate_extrude() 
polygon(Bezier(outline));            