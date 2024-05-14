function rotateMatrixX(a) = 
    [ [ 1,0,0,0  ],
      [ 0,cos(a),-sin(a),0 ],
      [ 0,sin(a),cos(a),0 ],
      [ 0,0,0,1 ] ];
      
function rotateMatrixY(a) = 
    [ [ cos(a),0,sin(a),0],
      [ 0,1,0,0 ],
      [ -sin(a), 0,cos(a), 0],
      [ 0,0,0,1 ] ];
      
function rotateMatrixZ(a) = 
    [ [ cos(a),-sin(a),0,0 ],
      [sin(a),cos(a),0,0 ],
      [ 0,0,1,0 ],
      [ 0,0,0,1 ] ];
      
      
function rotateMatrix(a=0,v=[0,0,1]) =
    is_list(a) ? rotateMatrixZ(a[2])*rotateMatrixY(a[1])*rotateMatrixX(a[0]) : 
     let(W = 
    [ [ 0,-v[2],v[1],0 ],
      [ v[2],0,-v[0],0 ],
      [ -v[1],v[0],0,0 ],
      [ 0,0,0,0 ] ])
     [ [ 1,0,0,0 ],[0,1,0,0],[0,0,1,0],[0,0,0,1] ] +
     sin(a) * W + 2 * pow(sin(a/2),2) * W*W;

function translateMatrix(v) = 
    [ [ 1,0,0,v[0] ], 
      [ 0,1,0,v[1] ], 
      [ 0,0,1,v[2] ],
      [ 0,0,0,1 ] ];
      
function multmatrixPath(m,p) = 
    [ for(q=p) let(p1=m*[for (i=[0:3]) i<len(q) ? q[i]: 0 ]) [for (i=[0:2]) p1[i] ] ];

