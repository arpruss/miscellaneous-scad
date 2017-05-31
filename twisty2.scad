use <quickthread.scad>;

numSlices = 30;
side = 10;
points = [for (i=[0:numSlices]) 
        let(t=i/numSlices, 
            d=side/2, 
            sq=[[d*(1-t)-d*t,d,side*t], [-d,d*(1-t)-d*t,side*t], [-d*(1-t)+d*t,-d,side*t], [d,-d*(1-t)+d*t,side*t]]) for (s=sq) s];
polyhedron(faces=extrusionFaces(4,numSlices),points=points);
