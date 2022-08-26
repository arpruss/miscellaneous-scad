use <graph3d.scad>;

minX = 0;
maxX = 1;
minY = 0;
maxY = 1;

z = "50*pow((1-x)*x,.25)*pow(1-max(y,1-y),.25)";


graphFunction3D(z,minX,maxX,minY,maxY,resolution=50);
