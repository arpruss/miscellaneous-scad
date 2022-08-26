
stlObject1_size=[28.524,5.32,5.935049];

module main() {
    render(convexity=2)
    intersection() {
        translate([25.972,0,0]) rotate([0,0,180])  import("C:/cygwin64/home/Alexander_Pruss/3d/WacomButtonFix7.stl");
        translate([-1,-10,-10]) cube([24,20,20]);
    }
}

main();