use <hershey.scad>;
rotate([0,0,-45])
rotate([90,0,0]) {
translate([0,15,0])
drawHersheyText("Hello,", font="cursive", halign="center") sphere(r=2,$fn=8);
drawHersheyText("OpenSCAD!", font="cursive", halign="center") sphere(r=2,$fn=8);
}