use <pointHull.scad>;

module beveledCube(size=10,bevel=2,bevelEdges=false) {
    size = is_list(size) ? size : [size,size,size];
    
    points = [ for (i=[0,1]) for (j=[0,1]) for (k=[0,1]) let(p=[i,j,k])
        for (l=[0:2])
            [for (m=[0:2]) size[m]*p[m]+((l==m)==!bevelEdges ?(p[m]?-bevel:bevel):0)] ];
    pointHull(points);
}

