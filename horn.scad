use <tubemesh.scad>;

module dummy(){}

module horn(throat=[45,40], mouth=[120,60], length=100, wallThickness=1.4, numSections=20, flangeLength=4, flangeFlare=3, rectangular=true, solidFlangeOnly=false) {
    
    function getExponent(ratio) = pow(ratio, 1/length);
    
    mouthWidth = len(mouth)==2 ? mouth[0] : mouth;
    mouthHeight = len(mouth)==2 ? mouth[1] : mouth;
    throatWidth = len(throat)==2 ? throat[0] : throat;
    throatHeight = len(throat)==2 ? throat[1] : throat;

    wExp = getExponent(mouthWidth/throatWidth);
    hExp = getExponent(mouthHeight/throatHeight);
    
    function section(x,y,z) = 
        rectangular ? 
            [ [x,y,z], [-x,y,z], [-x,-y,z], [x,-y,z] ]:
            [ for(t=[0:10:350]) [x*cos(t), y*sin(t), z]];
            
    sections = 
        [ for(i=[0:numSections])
            let(z=i/numSections*length,
                x=pow(wExp,length-z)*throatWidth/2,
                y=pow(hExp,length-z)*throatHeight/2)
            section(x,y,z) ];

    module hornShape() {
        data = pointsAndFaces(sections,startCap=true,endCap=true,optimize=true);   
        polyhedron(points=data[0], faces=data[1]);
    }

/*    module hornShellQuick() {
        render(convexity=2)
        difference() {
            scale([(mouthWidth+wallThickness*2)/mouthWidth,(mouthHeight+wallThickness*2)/mouthHeight,1]) hornShape();
        }
    } */

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

    module flange(hollow=true) {
        if (flangeLength>0) {
            x1 = throatWidth/2+wallThickness;
            y1 = throatHeight/2+wallThickness;
            x2 = x1 + flangeFlare;
            y2 = y1 + flangeFlare;
            render(convexity=2)
            difference() {
                morphExtrude(section(x1,y1,0), section(x2,y2,flangeLength),numSlices=1);
                if (hollow) 
                    morphExtrude(section(throatWidth/2,throatHeight/2,-1), section(throatWidth/2,throatHeight/2,flangeLength+1),numSlices=1);
            }
        }
    }

    if (!solidFlangeOnly)
        hornShellGood();
    translate([0,0,solidFlangeOnly?0:length-0.001]) flange(hollow=!solidFlangeOnly);
}
