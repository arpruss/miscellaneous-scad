module hexes(width=100,height=100,diameter=10,spacing=2) {
    hexWidth = sqrt(3)/2 * diameter;
    nx = ceil(width/ (hexWidth + spacing))+3;
    rowHeight = diameter/2 + diameter/4 + spacing;
    ny = ceil(height / rowHeight)+1;
    for (i=[0:1:nx-1]) for(j=[0:1:ny-1]) {
        translate([(i-1)*rowHeight+diameter/2,(j-(i%2==1?.5:0))*(hexWidth+spacing)+hexWidth/2])  circle(d=diameter,$fn=6);
    }
}

module hexWrap(width=100,height=100,diameter=10,spacing=2,margin=2,heightToWidthRatio=1) {
    height = height / heightToWidthRatio;
    scale([1,heightToWidthRatio]) {
        difference() {
            square([width,height]);
            translate([margin,margin]) intersection() {
                hexes(width-2*margin,height-2*margin,diameter,spacing);
                square([width-2*margin,height-2*margin]);
            }
        }
    }
}

hexWrap(width=200);