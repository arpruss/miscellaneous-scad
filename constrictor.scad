outerDiameter = 36;
innerDiameter = 27.2;
jointThickness = 1.5;
jointLength = 1;
numberOfPieces = 6;
openingAngle = 40;
height = 41;

circlePerimeter = PI* innerDiameter; 
perimeter = (360-openingAngle) * circlePerimeter / 360;
piecePerimeter = (perimeter+jointLength)/numberOfPieces - jointLength;
pieceAngle = piecePerimeter / circlePerimeter * 360;
pieceSliceAngle = (outerDiameter-innerDiameter)/2/(PI*outerDiameter)*360/2;

$fn = 36;

function arc(r=10,startAngle=0,endAngle=180)
    = [for (i=[0:$fn]) let(a=startAngle+(endAngle-startAngle)*i/$fn) r*[cos(a),sin(a)]];

module piece() {
    z = concat(
        arc(r=innerDiameter/2,
            startAngle=-pieceAngle/2,
            endAngle=pieceAngle/2),
         arc(r=outerDiameter/2,
            startAngle=pieceAngle/2-pieceSliceAngle,endAngle=-pieceAngle/2+pieceSliceAngle));
    polygon(z);
}

module profile() {
    extPieceAngle = pieceAngle+jointLength/circlePerimeter*360;
    for (i=[0:numberOfPieces-1])
        rotate(extPieceAngle*i) piece();
    
    t0 = 0;
    t1 = -pieceAngle+numberOfPieces*extPieceAngle-jointLength/circlePerimeter*360;
    polygon(concat(arc(r=innerDiameter/2,
        startAngle=t0,
        endAngle=t1),arc(r=innerDiameter/2+jointThickness,
        startAngle=t1,
        endAngle=t0)));
}

linear_extrude(height=height) profile();
