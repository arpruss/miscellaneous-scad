use <tubemesh.scad>;

function makeFaces(bc,b1,b2,tc,t1,t2)
    = [ [bc,b1,b2],
        [tc,t2,t1],
//        [tc,t1,b1],
//        [bc,tc,b1],
//        [tc,b2,t2],
//        [bc,b2,tc],
        [t1,t2,b2],
        [t1,b2,b1] ];

function joinStars(bottomCenter,bottomRing,topCenter,topRing) =
    [
        concat([bottomCenter],[topCenter],
        bottomRing,topRing),
        let(n=len(bottomRing),bc=0,tc=1,br=2,tr=br+n)
        [for(i=[0:n-1]) for(f=makeFaces(bc,br+i,br+(i+1)%n,tc,br+i,tr+(i+1)%n)) f]
    ];
        
module polyhedronFaces(points=[], faces=[], radius=1) {
    for (f=faces) {
        echo(f);
        hull() {
            for(p=f) {
                translate(points[p]) sphere(r=radius);
            }
        }
    }
}

module starCylinder(points=12, bottomCenter=[0,0,0], bottomEvenZ=0, bottomOddZ=0,
	bottomEvenRadius=50, bottomOddRadius=30, topCenter=[10,0,0], topEvenZ=10, topOddZ=0.01,
	topEvenRadius=50, topOddRadius=30) {
	
	bottom = [for(i=[0:points-1]) let(angle=360/points*i)
					i%2 ? [bottomOddRadius*cos(angle),bottomOddRadius*sin(angle),bottomOddZ] :
						  [bottomEvenRadius*cos(angle),bottomEvenRadius*sin(angle),bottomEvenZ]];
    echo(bottom);
	top = [for(i=[0:points-1]) let(angle=360/points*i)
					i%2 ? [topOddRadius*cos(angle),topOddRadius*sin(angle),topOddZ] :
						  [topEvenRadius*cos(angle),topEvenRadius*sin(angle),topEvenZ]];
    
    pointsAndFaces = joinStars(bottomCenter,bottom,topCenter,top);
    polyhedronFaces(points=pointsAndFaces[0],faces=pointsAndFaces[1]);
    echo(pointsAndFaces[0]);
    echo(len(pointsAndFaces[0]));
    echo(pointsAndFaces[1]);
}

starCylinder();
