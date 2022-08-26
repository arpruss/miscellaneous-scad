include <hershey.scad>;

text = "Inscribed text";
font = "futural";

width = widthHersheyText(text, font=futural);
echo(width);

render(convexity=2)
difference() {
    cube([width+20,20,5]);
    translate([10,0,5+0.001])
    drawHersheyText(text, font=font, valign="center") translate([0,0,-2]) cylinder(r1=0,r2=1,h=2,$fn=12);
}