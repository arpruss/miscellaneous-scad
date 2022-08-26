module vertical_extrude(height=2,slope=1) {
    rotate([90,0,0]) {
        linear_extrude(height=height) children();
        m = [[1,0,0,0],
                    [0,1,slope,-slope*height],
                    [0,0,1,0],
                    [0,0,0,1]];
        echo(m);
        multmatrix(m) linear_extrude(height=height) children();
    }
}

vertical_extrude() text("Hello");