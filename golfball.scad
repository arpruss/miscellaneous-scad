use <tubemesh.scad>;

numberOfHoles = 333;

equalSizeHoles = 0;
symmetric = 0;

module dummy() {}

GA = 2.39996322972865332 * 180 / PI;

function spiral(n,numberOfHoles) = [for(i=[0:n-1])
     let (ratio = (i+1)/(numberOfHoles+1),
          a = 2*sqrt( (1-ratio)*ratio ) )
        [ a * cos(i * GA), a * sin(i * GA), 1 - 2 * ratio ] ];

points = symmetric ? concat(spiral(numberOfHoles/2,numberOfHoles), 
    -spiral(numberOfHoles/2,numberOfHoles)) : spiral(numberOfHoles,numberOfHoles);

module golfBallEqualSizeHoles(points) {
    minD = min( [ for(i=[0:numberOfHoles-2]) for(j=[i+1:numberOfHoles-1]) norm(points[i]-points[j]) ] );
    render(convexity=2)
    difference() {
     mySphere(r=1,$fn=24);
     for(i=[0:len(points)-1]) translate(points[i]) scale(minD/2) children();
    }    
}

module golfBallUnequalSizeHoles(points) {
    render(convexity=2)
    difference() {
         mySphere(r=1,$fn=24);
         for(i=[0:len(points)-1]) {
            d=min([for(j=[0:len(points)-1]) if(j!=i) norm(points[i]-points[j])]);
            translate(points[i]) scale(d/2) children();
        }
    }
}


if (equalSizeHoles)
    golfBallEqualSizeHoles(points) mySphere(r=1,$fn=8);
else
    golfBallUnequalSizeHoles(points) mySphere(r=1,$fn=8);