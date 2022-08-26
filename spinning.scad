use <tubeMesh.scad>;

card = [ [-50,-35], [50,-35], [50,35], [-50,35] ];

morphExtrude(card,height=100,twist=90,numSlices=40);