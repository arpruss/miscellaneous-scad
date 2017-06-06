use <tubemesh.scad>;

//<params>
numberOfHoles = 333;
diameter = 42.7;
equalSizeHoles = 0; // [0:no, 1:yes]
//</params>

module dummy() {}

symmetric = 0;

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


scale(diameter/2)
if (equalSizeHoles)
    golfBallEqualSizeHoles(points) mySphere(r=1,$fn=10);
else
    golfBallUnequalSizeHoles(points) mySphere(r=1,$fn=10);