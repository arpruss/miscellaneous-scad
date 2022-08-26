thickness = 2;
innerDiameter=20;
height=26;

module dummy() {}

d0 = innerDiameter;
h = height;
d1 = innerDiameter+2*thickness;

points = [[0,0],[d1/2,0],[d1/2+1.75,2.5],[d1/2+1.75,4],[d1/2,3.5+2.5],[d1/2,h],[0,h]];
difference() {
   rotate_extrude() 
    polygon(points);
    translate([0,0,thickness])
    cylinder(h=h,d=d0);
}
