use <bezier.scad>;

color("red")
rotate_extrude($fn=128,angle=180)
translate([-100,0,0])
rotate([0,0,90])
polygon(Bezier([[0,0],POLAR(15,45),POLAR(10,30),[0,10],REPEAT_MIRRORED([1,0])]));