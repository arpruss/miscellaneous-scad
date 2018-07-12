digit = "8";
size = 95;
stencilThickness = 1.5;
handleHeight = 20;
handleThickness = 5;

module handle(p1,p2,r=10,height=20,thickness=5,sides=8) {
    angle = atan2(p2[1]-p1[1],p2[0]-p1[0]) + 180/sides;
    module base() {
        translate(p1) rotate(angle) circle(r=r,$fn=sides);
        translate(p2) rotate(angle) circle(r=r,$fn=sides);
    }
    linear_extrude(height=height+thickness) base();
    translate([0,0,height])
    linear_extrude(height=thickness) hull() base();
}

module digit(d,size=100,thickness=1.5,handleHeight=20,handleThickness=4, margin=20) {
    
    translate([margin,margin])
    linear_extrude(height=thickness)
    difference() {
        translate([-margin,-margin]) square([size*.9+2*margin,2*margin+size]);
        text(d,font="Arial:style=black",size=size);
    }
    function s(x) = x/100*size;
    if (d=="0") {
        handle([s(18),s(70)],[s(60),s(70)],s(5),height=handleHeight,thickness=handleThickness);
    }
    else if (d=="4") {
        handle([s(40),s(95)],[s(62),s(68)],s(5),height=handleHeight,thickness=handleThickness);
    }
    else if (d=="6") {
        handle([s(68),s(43)],[s(68),s(11)],s(5),height=handleHeight,thickness=handleThickness);
    }
    else if (d=="8") {
        handle([s(65),s(42)],[s(65),s(10)],s(5),height=handleHeight,thickness=handleThickness);
        handle([s(65),s(97)],[s(65),s(128)],s(5),height=handleHeight,thickness=handleThickness);
    }
    else if (d=="9") {
        handle([s(65),s(97)],[s(65),s(128)],s(5),height=handleHeight,thickness=handleThickness);
    }
}

digit(digit,size=size,thickness=stencilThickness,handleHeight=handleHeight,handleThickness=handleThickness);