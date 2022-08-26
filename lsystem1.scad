//<skip>
// F=forward, -/+=yaw, ^/&=pitch, </>=roll, [/]=push/pop
rules = [["A", "^F[^^F>>>>>>A]>>>[^^F>>>>>>A]>>>>>[^^F>>>>>>A]"]];
axiom = "FA";
forward = 5;
angle = 15;
iterations = 5;

module dummy() {};


//<skip>
//rotate([0,-90,0]) drawLSystem(rules,axiom,iterations,functions) sphere(1,$fn=4);
//</skip>
cube(1);