use <hexwrap.scad>;

//<params>
wingWidth = 10;
screwHole = 4;
screwExtraY = 10;
length = 85;
width = 60;
height = 36;
incut = 8;
thickness = 1.5;
hexSpacing = 2;
hexDiameter = 10;
margin = 2;
hexAspect = 1.5;
cutoutLength = 43;
//</params>

module side(width=width) {
    sideCustom(width=width)
    hexWrap(width=width,height=length,margin=margin,spacing=hexSpacing,diameter=hexDiameter,heightToWidthRatio=hexAspect);
}

module sideWithCutout(width=width) {
    sideCustom(width=width) {
        difference() {
            hexWrap(width=width,height=length,margin=margin,spacing=hexSpacing,diameter=hexDiameter,heightToWidthRatio=hexAspect);
            translate([margin,length-margin-cutoutLength]) square([width-2*margin,cutoutLength]);
        }
        translate([0,length-margin-cutoutLength-margin])
        square([width,margin]);
    }
}

module sideCustom(width=100) {
    rotate([90,0,0])
    translate([0,0,-thickness/2])
    linear_extrude(height=thickness) children();
    for(x=[0,width]) translate([x,0,0]) cylinder(d=thickness,h=length,$fn=32);
}

module extrude_side(start,end,cutout) {
    v = end-start;
    width = norm(v);
    angle = atan2(v[1],v[0]);
    translate(start) rotate([0,0,angle]) if(cutout) sideWithCutout(width=width) ;else side(width=width);
}

path = [[0,0],[0,height-incut],[incut,height],[width-incut,height],[width,height-incut],[width,0]];

module trace_sides(path) {
    for(i=[1:1:len(path)-1]) extrude_side(path[i-1],path[i],i==len(path)-1);
}

module wing() {
    rotate([90,0,0])
    translate([0,0,-thickness/2])
    linear_extrude(height=thickness)
    difference() {
        square([wingWidth,length]);
        for(y=[wingWidth/2+screwExtraY,length-wingWidth/2-screwExtraY]) translate([wingWidth/2,y]) circle(d=screwHole,$fn=32);
    }
}

trace_sides(path);
translate([-wingWidth,0,0]) wing();
translate([width,0,0]) wing();