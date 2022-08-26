// pounds
totalWeight = 25; 
// pounds
rodWeight = 0.5; 
// kg/m^3
density = 2300; 
diameter = 170;
bottomWall = 1.25;
sideWall = 1.2;
// include some tolerance
rodGuideDiameter = 34.1; 
rodGuideHeight = 15;
rodGuideThickness = 10;
handleLength = 133;
extraHeight = 2;

module dummy() {}

endWeight = (totalWeight-rodWeight)*0.453592/2;
echo("endWeight",endWeight);
V = endWeight/density * pow(1000,3);
A = 3*sqrt(3)*pow(diameter/2,2)/2-pow(rodGuideDiameter/2,2)*PI;
h = V/A+extraHeight;
echo("height",h);
echo("rod length",h*2+handleLength);

difference() {
    cylinder(d=diameter+sideWall*sqrt(3)/2,h=h+bottomWall,$fn=6);
    translate([0,0,bottomWall])     cylinder(d=diameter,h=h+bottomWall,$fn=6);
}
translate([0,0,bottomWall-.001])
difference(){
    cylinder(d1=(rodGuideDiameter+rodGuideThickness*2),d2=rodGuideDiameter,h=rodGuideHeight);
    translate([0,0,bottomWall]) cylinder(d=rodGuideDiameter,h=rodGuideHeight);
}