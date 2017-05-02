pi = 3.1415926535897932;

function eval(c,v) = 
    let(op=c[0]) (
    op == undef ? c :
    op == "x" ? v[0] : 
    op == "y" ? v[1] :
    op == "z" ? v[2] :
    op == "t" ? v[3] :
    op == "P" ? pi :
    op == "v" ? v[c[1]] :
    op == "'" ? c[1] : 
    op == "+" ? eval(c[1],v)+eval(c[2],v) :
    op == "-" ? (len(c)==2 ? -eval(c[1],v) : eval(c[1],v)-eval(c[2],v)) :
    op == "*" ? eval(c[1],v)*eval(c[2],v) :
    op == "/" ? eval(c[1],v)/eval(c[2],v) :
    op == "%" ? eval(c[1],v)%eval(c[2],v) :
    op == "cos" ? cos(eval(c[1],v)) :
    op == "sin" ? sin(eval(c[1],v)) :
    op == "tan" ? tan(eval(c[1],v)) :
    op == "acos" ? acos(eval(c[1],v)) :
    op == "asin" ? asin(eval(c[1],v)) :
    op == "atan" ? atan(eval(c[1],v)) :
    op == "atan2" ? atan2(eval(c[1],v),eval(c[2],v)) :
    op == "COS" ? cos(eval(c[1],v)*180/pi) :
    op == "SIN" ? sin(eval(c[1],v)*180/pi) :
    op == "TAN" ? tan(eval(c[1],v)*180/pi) :
    op == "ACOS" ? acos(eval(c[1],v))*pi/180 :
    op == "ASIN" ? asin(eval(c[1],v))*pi/180 :
    op == "ATAN" ? atan(eval(c[1],v))*pi/180 :
    op == "ATAN2" ? atan2(eval(c[1],v),eval(c[2],v))*pi/180 :
    op == "abs" ? abs(eval(c[1],v)) :
    op == "ceil" ? ceil(eval(c[1],v)) :
    op == "cross" ? cross(eval(c[1],v),eval(c[2],v)) :
    op == "exp" ? exp(eval(c[1])) :
    op == "floor" ? floor(eval(c[1])) :
    op == "ln" ? ln(eval(c[1])) :
    op == "len" ? len(eval(c[1])) :
    op == "log" ? log(eval(c[1])) :
    op == "max" ? (len(c) == 2 ? max(eval(c[1],v)) : max([for(i=[1:len(c)-1]) eval(c[i],v)])) :
    op == "min" ? (len(c) == 2 ? min(eval(c[1],v)) : min([for(i=[1:len(c)-1]) eval(c[i],v)])) :
    op == "norm" ? norm(eval(c[1],v)) :
    op == "rands" ? rands(eval(c[1],v),eval(c[2],v),eval(c[3],v),eval(c[4],v)) :
    op == "round" ? round(eval(c[1],v)) :
    op == "sign" ? sign(eval(c[1],v)) :
    op == "sqrt" ? sqrt(eval(c[1],v)) :
    op == "^" || op == "pow" ? pow(eval(c[1],v),eval(c[2],v)) :
    op == "<" ? eval(c[1],v)<eval(c[2],v) :
    op == "<=" ? eval(c[1],v)<=eval(c[2],v) :
    op == "==" ? eval(c[1],v)==eval(c[2],v) :
    op == "!=" ? eval(c[1],v)!=eval(c[2],v) :
    op == ">=" ? eval(c[1],v)>=eval(c[2],v) :
    op == ">" ? eval(c[1],v)>=eval(c[2],v) :
    op == "&&" ? eval(c[1],v)&&eval(c[2],v) :
    op == "||" ? eval(c[1],v)||eval(c[2],v) :
    op == "!" ? !eval(c[1],v) :
    op == "?" ? (eval(c[1],v)?eval(c[2],v):eval(c[3],v)) :
    op == "[" ? [for (i=[1:len(c)-1]) eval(c[i],v)] :
    op == "#" ? eval(c[1],v)[eval(c[2],v)] :
    op == "concat" ? [for (i=[1:len(c)-1]) let(vect=eval(c[i],v)) for(j=[0:len(vect)-1]) vect[j]] : 
    undef
    );
    
module plot3d(f,start,end,steps=20,height=1) {
    delta = (end-start)/steps;
    for(i=[0:steps-1])
       for(j=[0:steps-1]) {
           xy = [i*delta[0],j*delta[1]]+start;
           z = eval(f,xy);
           translate([xy[0],xy[1],z-height/2]) cube([delta[0],delta[1],height/2]);
       }
               
}   

module curve3d(f,t0,t1,steps=30,thickness=1,closed=false) {
    delta = (t1-t0)/(steps-1);
    values = [for (i=[0:steps-1]) eval(f,[0,0,0,t0+i*delta])];
        
    for(i=[0:steps-2]) {
        hull() {
            translate(values[i]) sphere(d=thickness);
            translate(values[i+1]) sphere(d=thickness);
        }
    }
}

module demo() {
// 3*(x*y^3-x^3*y)
//plot3d(["*", 3, [ "-", ["*", "x", ["^", "y", 3]], ["*", ["^", "x", 3], "y"] ]], [-1,-1],[1,1], steps=50, height=0.5);

    // borromean knot parametrization by I.J. McGee
    scale = 30;
    r = sqrt(3)/3;
    // scale*[cos(t),sin(t)+r,-cos(3*t)/3];
    color("red") curve3d([ "*", scale, ["[", ["COS", "t"], ["+", ["SIN", "t"], r], ["-", ["/", ["COS", ["*", 3, "t"]], 3]]] ], 0, 2*pi, steps=60, thickness=10);
    // scale*[cos(t)+0.5,sin(t)-r/2,-cos(3*t)/3];
    color("green") curve3d([ "*", scale, ["[", ["+",["COS", "t"],0.5], ["-", ["SIN", "t"], r/2], ["-", ["/", ["COS", ["*", 3, "t"]], 3]]] ], 0, 2*pi, steps=60, thickness=10);
    // scale*[cos(t)-0.5,sin(t)-r/2,-cos(3*t)/3];
    color("blue") curve3d([ "*", scale, ["[", ["-",["COS", "t"],0.5], ["-", ["SIN", "t"], r/2], ["-", ["/", ["COS", ["*", 3, "t"]], 3]]] ], 0, 2*pi, steps=60, thickness=10);
    
       
}

demo();


//