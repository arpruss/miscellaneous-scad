buttonWidth = 11.94;
spacing = 4;
screwSize = 1.4;
buttonThickness = 3.96;
buttonTensioning = 0.5;
tolerance = 0.3;
stripWidth = 9;
thickness = 4;
buttonCount = 3;

module dummy() {}

nudge = 0.001;

length = buttonCount * (buttonWidth+2*tolerance) + (1+buttonCount) * spacing;
echo(length);
module main() {
    cube([length,stripWidth,thickness]);
    for (i=[0:buttonCount]) {
        x = (spacing+buttonWidth+2*tolerance)*i;
        translate([x,0,thickness-nudge]) cube([spacing,stripWidth,buttonThickness-buttonTensioning]);
    }
}

render(convexity=2)
difference() {
    main();
    for (i=[0:buttonCount]) {
        x = (spacing+buttonWidth+2*tolerance)*i+tolerance+spacing/2;
        translate([x,stripWidth/2,-nudge]) cylinder(d=screwSize,h=2*nudge+buttonThickness+thickness,$fn=16);
        if (i<buttonCount) {
        translate([x+spacing/2+buttonWidth/2+tolerance,stripWidth/2,-nudge]) cylinder(d=screwSize,h=2*nudge+buttonThickness+thickness,$fn=16);
        }
    }
}