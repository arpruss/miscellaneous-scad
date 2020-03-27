use <tubemesh.scad>;

//<params>
tubeDiameter = 24.84;
tubeTolerance = 0.4;

sleeveHeight = 25;
sleeveThickness = 6;
attachmentWidth = 14.7;
attachmentTolerance = 0;
attachmentBottomThickness = 8;
attachmentHoleDiameter = 3;
attachmentHoleHeight = 3.5;
attachmentHoleInset = 3.5;
bottomBezel = 1.7;
//</params>

module dummy() {}

$fn = 64;

// R = H/2+W^2/8H
function cordToRadius(H,W) = H/2+W*W/(8*H);
function cordHeight(R,W) = R-(0.5)*sqrt(4*R*R-W*W);

outerRadius = tubeDiameter/2+tubeTolerance+sleeveThickness;
attachmentWidth1 = attachmentWidth-2*attachmentTolerance;
attachmentInset = cordHeight(outerRadius,attachmentWidth1);

echo(attachmentInset);

module attachment() {
  function S(thickness,z) =
    sectionZ([[-attachmentInset,-attachmentWidth1/2],[-attachmentInset+thickness,-attachmentWidth1/2],[-attachmentInset+thickness,attachmentWidth1/2],[-attachmentInset,attachmentWidth1/2]],z);
    
    translate([outerRadius,0,0])
  difference() {
  tubeMesh(
    [S(attachmentBottomThickness+attachmentInset-bottomBezel,0),
    S(attachmentBottomThickness+attachmentInset,bottomBezel),
    S(attachmentBottomThickness+attachmentInset,attachmentHoleHeight+attachmentHoleDiameter/2),
      S(0,sleeveHeight)]); 
      
      translate([attachmentBottomThickness-attachmentHoleInset,0,attachmentHoleHeight])
      rotate([90,0,0])
      cylinder(d=attachmentHoleDiameter,h=3*attachmentWidth1,center=true);
  }
}

difference() {
    union() {
        cylinder(r=outerRadius,h=sleeveHeight);
        for (a=[0,120,240]) rotate([0,0,a]) attachment();
    }
    translate([0,0,-1]) cylinder(d=tubeDiameter+2*tubeTolerance,h=sleeveHeight+2);
}