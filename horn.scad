use <tubemesh.scad>;

// exponential horn

length = 100;
throatWidth = 45;
throatHeight = 40;
mouthWidth = 120;
mouthHeight = 60;
wallThickness = 1.4;
numSections = 20;
flangeLength = 4;
flangeFlare = 3;

watchHolder = 0; // [1:yes, 0:no]
holderCutFromFront = 3;
holderCutHeight = 23;
holderCutThickness = 4;
holderWall = 4;
holderDepth = 20;
tolerance = 0.75;

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

module flange(tolerance=0,hollow=true) {
    if (flangeLength>0) {
        x1 = throatWidth/2+wallThickness+2*tolerance;
        y1 = throatHeight/2+wallThickness+2*tolerance;
        x2 = x1 + flangeFlare+2*tolerance;
        y2 = y1 + flangeFlare+2*tolerance;
        render(convexity=2)
        difference() {
            morphExtrude([[x1,y1],[-x1,y1],[-x1,-y1],[x1,-y1]], [[x2,y2],[-x2,y2],[-x2,-y2],[x2,-y2]], height=flangeLength+tolerance);
            if (hollow)
            translate([-throatWidth/2,-throatHeight/2,-1]) cube([throatWidth,throatHeight,flangeLength+2]);
        }
    }
}

module horn() {
    hornShellGood();
    translate([0,0,length-0.001]) flange();
}

nudge = 0.001;

module holder() {
    w = throatWidth + 2*flangeFlare + 2*tolerance + 2*holderWall;
    h0 = 0.5 * (mouthHeight - throatHeight);
    h = throatHeight + 2*flangeFlare + h0 + wallThickness;
    render(convexity=5)
    difference() {
        translate([-w/2,0,0])
        cube([w,holderDepth+holderWall,h]);
        translate([0,-nudge,h0+throatHeight/2+wallThickness+tolerance])
        rotate([-90,0,0])
        flange(tolerance=tolerance,hollow=false);
        translate([-w/2-nudge,-nudge,h0+throatHeight*0.1+wallThickness+2*tolerance]) cube([w+2*nudge,flangeLength+tolerance+nudge,nudge+flangeFlare+throatHeight]);
        translate([-w/2-nudge,tolerance+flangeLength+holderCutFromFront,h0+throatHeight/2+wallThickness+tolerance-holderCutHeight/2]) cube([w+2*nudge,holderCutThickness,h]);
        translate([-w/2+holderWall,-nudge,h0]) {
            cube([w-2*holderWall,flangeLength+tolerance+holderDepth-holderWall+nudge,h-h0-holderWall]);
            cube([w-2*holderWall,flangeLength+holderCutFromFront+holderCutThickness+nudge,h+nudge-h0]);
        }
    }
}

if (watchHolder)
    holder();
else
    horn();