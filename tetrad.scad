generate = 2; // [0:pieces, 1:board, 2:demo]
wall = 1;
incut = 1;
rounding = 2;
// put 0 for circle
numberOfSides1 = 0;
numberOfSides2 = 3;
bottomHeight = 15;
shortHeight = 16;
tallHeight = 28;
diameter = 15;
solidBase = 7;
boardThickness = 2;
boardHoleDepth = 1.5;
boardPieceTolerance = 2;
boardHoleSpacing = 5;

module dummy() {}
nudge = 0.01;

function getBit(x,n) = floor(x / pow(2,n)) % 2;

// piece(hollow,tall) { outer; inner; }
module piece(hollow,tall) {    
    height = tall ? tallHeight : shortHeight;
    mul = (diameter-2*incut)/diameter;    
    
    difference() {
        union() {
        linear_extrude(height=bottomHeight-2*incut+nudge) children(0);
            
        translate([0,0,bottomHeight-2*incut])  
            linear_extrude(height=incut+nudge,scale=mul) children(0);

       translate([0,0,bottomHeight-incut]) 
            linear_extrude(height=incut+nudge,scale=1/mul) scale(mul) children(0);
        translate([0,0,bottomHeight]) 
            linear_extrude(height=height-bottomHeight) children(0);
        }
        if (hollow) {
            translate([0,0,solidBase])
            linear_extrude(height=tallHeight) 
                scale(mul) children(1);
            translate([0,0,bottomHeight])
                linear_extrude(height=tallHeight)
                children(1);
        }
    }
}

module poly(diameter, inset, sides) {
    if (sides == 0)
        circle(d=diameter-2*inset,$fn=36);
    else {
        rounding1 = inset>0 ? rounding/2 : rounding;
        r = diameter/2 - rounding1-inset;        hull() {
            for (i=[0:sides-1])
                translate(r*[cos(i/sides*360),sin(i/sides*360)]) circle(r=rounding1,$fn=16);
        }
    }
}

module pieces() {
    s = boardHoleSpacing;
    d = diameter + boardPieceTolerance*2;
    dx = d + s;

    for (i=[0:15]) {
        translate([floor(i/4)*dx,(i%4)*dx,0])
            color(getBit(i,0)*0.75*[1,1,1]+[0.25,0.25,0.25])
        render(convexity=2)
                piece(getBit(i,1),getBit(i,2)) {
                    poly(diameter,0,[numberOfSides1,numberOfSides2][getBit(i,3)]);
                    poly(diameter,wall,[numberOfSides1,numberOfSides2][getBit(i,3)]);
            }
    } 
}

module board() {
    s = boardHoleSpacing;
    d = diameter + boardPieceTolerance*2;
    dx = d + s;
    $fn = 36;
    render(convexity=4)
    difference() {
        linear_extrude(height=boardThickness)
        hull() {
            circle(d=dx+s);
            translate([3*dx,0])
            circle(d=dx+s);
            translate([0,3*dx])
            circle(d=dx+s);
            translate([3*dx,3*dx])
            circle(d=dx+s);
        }
        translate([0,0,boardThickness-boardHoleDepth])
            linear_extrude(height=boardThickness)
                for(i=[0:3]) for(j=[0:3])
                    translate([i*dx,j*dx]) circle(d=d);
    }
}

if (generate==1) board(); 
else if (generate==0) pieces();
else if (generate==2) {
    board();
    translate([0,0,boardThickness-boardHoleDepth]) pieces();
}
