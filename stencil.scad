digits = "82";
size = 94;
stencilThickness = 1;
handleHeight = 20;
handleThickness = 4;
verticalMargin = 13;
horizontalMargin = 0;

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

module digit(d,size=100,thickness=1.5,handleHeight=20,handleThickness=4, hMargin=20,vMargin=20) {
    
        function s(x) = x/100*size;

    translate([hMargin,vMargin]) union() {
        linear_extrude(height=thickness)
        difference() {
            translate([-hMargin,-vMargin]) square([size*.9+2*hMargin,2*vMargin+size]);
            text(d,font="Arial:style=black",size=size);
        }
        
        if (d=="0") {
            handle([s(-2),s(50)],[s(40),s(50)],s(5),height=handleHeight,thickness=handleThickness);
        }
        else if (d=="4") {
            handle([s(20),s(75)],[s(42),s(48)],s(5),height=handleHeight,thickness=handleThickness);
        }
        else if (d=="6") {
            handle([s(48),s(23)],[s(48),s(-9)],s(5),height=handleHeight,thickness=handleThickness);
        }
        else if (d=="8") {
            handle([s(45),s(22)],[s(45),s(-10)],s(5),height=handleHeight,thickness=handleThickness);
            handle([s(45),s(77)],[s(45),s(108)],s(5),height=handleHeight,thickness=handleThickness);
        }
        else if (d=="9") {
            handle([s(45),s(77)],[s(45),s(108)],s(5),height=handleHeight,thickness=handleThickness);
        }
    }
}

module digits(s,size=100,thickness=1.5,handleHeight=20,handleThickness=4, hMargin=20,vMargin=20,spacing=0.1) {
    
    nudge = 0.001;
    w = len(s)*(0.9+spacing)*size+spacing*size;
    cube([hMargin+nudge,vMargin*2+size,thickness]);
    translate([hMargin+w-nudge,0,0]) cube([hMargin+nudge,2*vMargin+size,thickness]);
    translate([hMargin,0,0]) {
        for (i=[0:len(s)-1]) {
            translate([i*(spacing+0.9)*size,0,0])
                digit(s[i],size=size,thickness=thickness,hMargin=size*spacing,vMargin=vMargin,handleHeight=handleHeight,handleThickness=handleThickness);
        }
    }
}

render(convexity=9)
digits(digits,size=size,thickness=stencilThickness,handleHeight=handleHeight,handleThickness=handleThickness,vMargin=verticalMargin,hMargin=horizontalMargin);