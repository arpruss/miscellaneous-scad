use <eval.scad>;

//<params>
xEquation = "sin(t)+2*sin(2*t)";
yEquation = "cos(t)-2*cos(2*t)";
zEquation = "-sin(3*t)";
tStart = 0;
tEnd = 360;
numberOfSteps = 40;
thickness = 10;
graphScale = 10;
//</params>

module curve3d(xf,yf,zf,t0,t1,steps=30,thickness=1,graphScale=1,$fn=16) {
    xfc = compileFunction(xf);
    yfc = compileFunction(yf);
    zfc = compileFunction(zf);

    delta = (t1-t0)/(steps-1);
    values = [for (i=[0:steps-1]) let(t=t0+i*delta)
        graphScale * [ eval(xfc,[["t", t]]), eval(yfc,[["t", t]]), eval(zfc,[["t", t]]) ] ];

    for(i=[0:steps-2]) {
        hull() {
            translate(values[i]) sphere(d=thickness);
            translate(values[i+1]) sphere(d=thickness);
        }
    }
}

curve3d(xEquation,yEquation,zEquation,tStart,tEnd,steps=numberOfSteps,thickness=thickness,graphScale=graphScale);

echo(compileFunction("(1+12)"));
echo(compileFunction("(x^z)"));
echo(compileFunction("[1^2,3*4,5]"));
echo(compileFunction("2*2*[a,b,c,d]"));
echo(compileFunction("[1^2,[3*4,5]]"));
echo(compileFunction("x==1?10:x==2?20:x==3?30:40",optimize=false));
echo(compileFunction("x==1?10:x==2?20:x==3?30:40",optimize=true));
echo(eval(compileFunction("[1,2]+[2,3]")));
echo(eval(compileFunction("atan2(1,0)")));
echo(eval(compileFunction("cross([1,2,3],[3,4,6])")));
echo(eval(compileFunction("true && false",optimize=true)));
echo(eval(compileFunction("x==1?10:x==2?20:x==3?30:40"), [["x",1]]));
echo(compileFunction("let(abc=1,def=2)abc+def"));
