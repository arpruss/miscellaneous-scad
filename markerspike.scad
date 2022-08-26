headDiameter = 20;
headThickness = 2.5;
tailDiameter = 2.5;
tailBigDiameter = 3;
tailLength = 28;

$fn = 64;
cylinder(d=headDiameter,h=headThickness);
cylinder(d1=tailBigDiameter,d2=tailDiameter,h=tailLength+headThickness);