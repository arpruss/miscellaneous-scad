buttonWidth = 11.85;
spacing = 2.8;
screwSize = 1.4;
buttonThickness = 3.91;
buttonTensioning = 0.5;
tolerance = 0.3;
stripWidth1 = 11.85;
thickness = 1.5;
buttonCount = 3;
tabSize = 2.25;

module dummy() {}

stripWidth = stripWidth1+tolerance;

nudge = 0.001;

length = buttonCount * (buttonWidth+2*tolerance) + (1+buttonCount) * spacing;
echo(length);
module main() {
    cube([length,stripWidth1,thickness]);
    for (i=[0:buttonCount]) {
        x = (spacing+buttonWidth+2*tolerance)*i;
        translate([x,0,thickness-nudge]) cube([spacing,stripWidth1,buttonThickness-buttonTensioning]);
    }
}

render(convexity=2)
difference() {
    main();
    for (i=[0:buttonCount]) {
        x = (spacing+buttonWidth+2*tolerance)*i+spacing/2;
        translate([x,-tabSize+nudge,0])
            cube([tabSize,tabSize,tabSize,buttonThickness-buttonTensioning+tabSize]);
        translate([x,stripWidth1/2,-nudge]) cylinder(d=screwSize,h=2*nudge+buttonThickness+thickness,$fn=16);
        if (i<buttonCount) {
        translate([x+spacing/2+buttonWidth/2+tolerance,stripWidth1/2,-nudge]) cylinder(d=screwSize,h=2*nudge+buttonThickness+thickness,$fn=16);
        }
    }
}

for (i=[0:buttonCount-1]) {
    x = (spacing+buttonWidth+2*tolerance)*i+spacing/2+spacing/2+buttonWidth/2+tolerance-tabSize/2;
    translate([x,-tabSize+nudge,0]) cube([tabSize,tabSize,tabSize+thickness]);
    translate([x,stripWidth1-nudge,0]) cube([tabSize,tabSize,tabSize+thickness]);
}
