use <tubemesh.scad>;

// exponential horn

length = 70;
throatWidth = 30;
throatHeight = 20;
mouthWidth = 80;
mouthHeight = 50;
wallThickness = 1.5;
numSections = 20;
flangeLength = 4;
flangeFlare = 3;

module dummy(){}

// exponent^length = ratio


function getExponent(ratio) = pow(ratio, 1/length);

wExp = getExponent(mouthWidth/throatWidth);
hExp = getExponent(mouthHeight/throatHeight);

sections = 
    [ for(i=[0:numSections])
        let(z=i/numSections*length,
            x=pow(wExp,length-z)*throatWidth/2,
            y=pow(hExp,length-z)*throatHeight/2)
        [ [x,y,z], [-x,y,z], [-x,-y,z], [x,-y,z] ] ];

module hornShape() {
    data = pointsAndFaces(sections,startCap=true,endCap=true,optimize=true);   
    polyhedron(points=data[0], faces=data[1]);
}

module hornShellQuick() {
    render(convexity=2)
    difference() {
        scale([(mouthWidth+wallThickness*2)/mouthWidth,(mouthHeight+wallThickness*2)/mouthHeight,1]) hornShape();
    }
}

module hornShellGood() {
    render(convexity=2)
    intersection() {
        difference() {
            minkowski() {
                hornShape();
                sphere(r=wallThickness,$fn=12);
            }
            hornShape();
        }
        translate([-mouthWidth/2-wallThickness,-mouthHeight/2-wallThickness,0])
        cube([mouthWidth+2*wallThickness,mouthHeight+2*wallThickness,length]);
    }
}

module flange() {
    if (flangeLength>0) {
        x1 = throatWidth/2+wallThickness;
        y1 = throatHeight/2+wallThickness;
        x2 = x1 + flangeFlare;
        y2 = y1 + flangeFlare;
        render(convexity=2)
        difference() {
            morphExtrude([[x1,y1],[-x1,y1],[-x1,-y1],[x1,-y1]], [[x2,y2],[-x2,y2],[-x2,-y2],[x2,-y2]], height=flangeLength);
            translate([-throatWidth/2,-throatHeight/2,-1]) cube([throatWidth,throatHeight,flangeLength+2]);
        }
    }
}

hornShellGood();
translate([0,0,length-0.001]) flange();