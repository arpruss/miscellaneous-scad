use <graph3d.scad>;

difference() {
graphFunction3D("50*(cos(2*x)+cos(2*y))",0,360,0,360,surfaceThickness=20,realSize=[360,360]);
    translate([180,180,0]) cylinder(d=150, h=200, center=true);
}