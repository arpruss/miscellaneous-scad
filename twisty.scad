use <quickthread.scad>;

numSlices = 30;
points = [for (i=[0:numSlices]) 
        let(t=i/numSlices, 
            angle=45+90*t,
            r=5/sin(angle)
            )
        for (j=[0:3])
            [r*cos(angle+j*90),r*sin(angle+j*90),10*t]];
polyhedron(faces=extrusionFaces(4,numSlices),points=points);
