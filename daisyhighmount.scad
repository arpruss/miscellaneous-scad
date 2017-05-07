dovetailWidth = 13;
dovetailHeight = 3;
extraHeight = 4;
length = 51;
holeDiameter = 4.5;
offsetHeight = 30;
baseWidth = 13;
webThickness = 2;
mountThickness = 2.5;
mountWidth = 20;
roundedness = 2;
triangleSide = 6;

module dummy() {}

nudge = 0.01;

extraWidth = dovetailWidth - 2*dovetailHeight;

module webbedMount() {
    render(convexity=2)
    difference() {
    rotate([90,0,0])
    linear_extrude(height=length) {
        translate([0,offsetHeight+mountThickness]) {
            translate([-webThickness/2,-offsetHeight]) square([webThickness,offsetHeight]);
            translate([-baseWidth/2,0]) square([baseWidth, extraHeight+nudge]);
        polygon([ [-extraWidth/2,0], [-extraWidth/2,extraHeight], [-extraWidth/2-dovetailHeight,extraHeight+dovetailHeight], [extraWidth/2+dovetailHeight,extraHeight+dovetailHeight], [extraWidth/2,extraHeight], [extraWidth/2,0]]); 
        }
    }
    }
    linear_extrude(height=mountThickness+nudge)
    translate([-mountWidth/2+roundedness,-length+roundedness])
    offset(r=roundedness)square([mountWidth-roundedness*2,length-2*roundedness]);            
}

module triangleEnd() {
    linear_extrude(height=offsetHeight+mountThickness+nudge)
    polygon([[-triangleSide/2,0], [0,-triangleSide*sqrt(3)/2], [triangleSide/2,0]]);
}

render(convexity=4)
difference() {
    webbedMount(); 
translate([mountWidth/4+webThickness/4,-mountWidth/2,-nudge]) cylinder(d=holeDiameter, h=3*nudge+mountThickness, $fn=16);
translate([-(mountWidth/4+webThickness/4),-mountWidth/2,-nudge]) cylinder(d=holeDiameter, h=3*nudge+mountThickness, $fn=16);
translate([mountWidth/4+webThickness/4,-length+mountWidth/2,-nudge]) cylinder(d=holeDiameter, h=3*nudge+mountThickness, $fn=16);
translate([-(mountWidth/4+webThickness/4),-length+mountWidth/2,-nudge]) cylinder(d=holeDiameter, h=3*nudge+mountThickness, $fn=16);
}
triangleEnd();
translate([0,-length,0]) rotate([0,0,180]) triangleEnd();
