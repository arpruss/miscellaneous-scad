use <tubemesh.scad>;

morphExtrude(ngonPoints(n=6,r=20),ngonPoints(n=6,r=20,rotate=45),height=20,curve="pow(t,3)");