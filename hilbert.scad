use <lsystem.scad>;

rules = [ ["L", "+RF-LFL-FR+"], 
          ["R", "-LF+RFR+FL-"] ];
          
forward = 4;
scaling = 1;
angle = 90;

functions = 
    [ 
      ["F", ["m", forwardMatrix(forward)]],
      ["-", ["m", yawMatrix(angle)]],
      ["+", ["m", yawMatrix(-angle)]],
      ["^", ["m", pitchMatrix(angle)]],
      ["&", ["m", pitchMatrix(-angle)]],
      [">", ["m", rollMatrix(angle)]],
      ["<", ["m", rollMatrix(-angle)]],
      ["s", ["m", scaleMatrix(1/scaling)]],
      ["S", ["m", scaleMatrix(scaling)]],
      ["[", ["push"]],
      ["]", ["pop"]]
      ];

projection()
scale(4)
drawLSystem(rules,"L",3,functions) cube(2,center=true);
