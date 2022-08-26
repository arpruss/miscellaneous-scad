
module fattener() {
    linear_extrude(height=0.5,scale=0)
    circle(d=1,$fn=10);
    rotate([180,0,0])
    linear_extrude(height=0.5,scale=0)
    circle(d=1,$fn=10);
    
}

    import("1701dsolid.stl");

minkowski() {
//stlObject1();
//fattener();
    //cube(1);
//    sphere(r=1);
}

