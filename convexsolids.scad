use <pointhull.scad>;

v = [
	-0.729665, 0.670121, 0.319155,
	-0.655235, -0.292130, -0.754096,
	-0.093922, -0.607123, 0.537818,
	0.702196, 0.595691, 0.485187,
	0.776626, -0.366560, -0.588064,
];

function splitVertices(list) = let(n=len(list)/3) [for(i=[0:n-1]) [list[3*i],list[3*i+1],list[3*i+2]]];
    
pointHull(splitVertices(v));
