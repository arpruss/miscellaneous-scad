generate = 2; // [0:pieces, 1:board, 2:box, 3:demo]
wall = 1;
incut = 1;
rounding = 2;
numberOfSides1 = 6;
numberOfSides2 = 3;
bottomHeight = 15;
shortHeight = 16;
tallHeight = 28;
diameter = 15;
// if you make a solid base for the pieces, the hollow ones will feel more solid, but you might confuse them for the solid ones when you turn them upside down
solidBaseHeight = 0;

boardThickness = 2.5;
boardHoleDepth = 2;
boardPieceTolerance = 2;
boardHoleSpacing = 5;

boxTolerance = 0.2;
boxSliderWidth = 3.5;
boxSliderThickness = 1.5;
boxWall = 0.75;
boxBottomWall = 1;

module dummy() {}
nudge = 0.01;

sideCounts = [numberOfSides1,numberOfSides2];
colors = [ [0.25,0.25,0.25], [1,1,1] ];

function getBit(x,n) = floor(x / pow(2,n)) % 2;

// piece(hollow,tall) { outer; inner; }
module piece(hollow,tall) {    
    height = tall ? tallHeight : shortHeight;
    
    module solid(height, diameter) {
        mul = (diameter-2*incut)/diameter;    
        linear_extrude(height=bottomHeight-2*incut+nudge) children();
            
        translate([0,0,bottomHeight-2*incut])  
            linear_extrude(height=incut+nudge,scale=mul) children();

       translate([0,0,bottomHeight-incut]) 
            linear_extrude(height=incut+nudge,scale=1/mul) scale(mul) children();
        translate([0,0,bottomHeight]) 
            linear_extrude(height=height-bottomHeight) children();
    }
    
    if (hollow) {
        difference() {
            solid(height,diameter) children(0);
            translate([0,0,-nudge])
            solid(height+2*nudge,diameter-2*wall,incut) children(1);
        }
        if (solidBaseHeight) {
            intersection() {
                solid(height,diameter,0) children(0);
                cylinder(d=3*diameter,h=solidBaseHeight,$fn=4);
            }
        }
    }
    else {
        solid(height,diameter) children(0);
    }
}

module poly(diameter, inset, sides) {
    rounding1 = inset>0 ? rounding/2 : rounding;
    r = diameter/2 - rounding1-inset;
    hull() {
        for (i=[0:sides-1])
            translate(r*[cos(i/sides*360),sin(i/sides*360)]) circle(r=rounding1,$fn=24);
    }
}

s = boardHoleSpacing;
d = diameter + boardPieceTolerance*2;
r = d/2;
dx = d + s;

module pieces(demo=false) {
    for (i=[0:(demo ? 15 : 7)]) {
        translate([floor(i/4)*dx,(i%4)*dx,0])
        color(colors[getBit(i,3)])
        render(convexity=2)
            piece(getBit(i,1),getBit(i,2)) {
                sides = sideCounts[getBit(i,0)];
                poly(diameter,0,sides);
                poly(diameter,wall,sides);
            }
    } 
}

module board() {
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

boxSize = 3*dx+dx+s + 2 * boxTolerance;
boxHeight = boxBottomWall + diameter + boardPieceTolerance + boxSliderWidth * 2 + boardThickness;

module box() {
    size = boxSize;
    height = boxHeight;
    
    module rounded(s,r) {
        hull() {
            translate([r,r]) circle(r=r);
            translate([s-r,s-r]) circle(r=r);
            translate([s-r,r]) circle(r=r);
            translate([r,s-r]) circle(r=r);
        }
    }
    
    ridgeSpacing = boxSliderWidth+boardThickness;
    module ridges(bottomOnly=0) {
        spacing = ridgeSpacing;
        for (i=[bottomOnly:1])
        translate([0,0,height-i*spacing])
        rotate([-90,0,0])
        linear_extrude(height=size-d) polygon([[0,0],[boxSliderWidth,0],[0,boxSliderWidth]]);
    }
    
    render(convexity=2)
    difference() {
        union() {
            translate([boxWall-nudge,boxWall+d/2,0]) ridges();
            translate([boxWall+d/2,size+nudge+boxWall,0]) mirror([0,1,0]) mirror([1,0,0]) rotate([0,0,90]) ridges(bottomOnly=1);

        translate([boxWall+d/2,boxWall-nudge,0]) mirror([1,0,0]) rotate([0,0,90]) ridges();
            translate([size+nudge+boxWall,boxWall+d/2,0]) mirror([1,0,0]) ridges();
            linear_extrude(height=boxBottomWall) rounded(size+2*boxWall,r+boxWall);

            linear_extrude(height=height)
            difference() {
                rounded(size+2*boxWall,r+boxWall);
                translate([boxWall,boxWall])
                rounded(size,r);
            }
            
        }
        translate([-nudge,size-d/2+boxWall,height-ridgeSpacing]) cube([size+2*boxWall+2*nudge,boxWall+d/2+nudge,ridgeSpacing]);
    }
}

echo($fn);

module demo() {
    ridgeSpacing = boxSliderWidth+boardThickness;

    box();
    translate([boxWall+boxTolerance+(dx+s)/2,boxWall+boxTolerance+(dx+s)/2,boxHeight-ridgeSpacing]) {
        color("red")
        board();
        translate([0,0,boardThickness-boardHoleDepth]) pieces(demo=true);
    }
}

if (generate==1) board(); 
else if (generate==0) pieces();
else if (generate==3) {
    demo();
}
else if (generate==2) {
    box();
}