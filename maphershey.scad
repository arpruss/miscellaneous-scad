use <hershey.scad>;
use <eval.scad>;

function normalize(vect) = 
    let(n=norm(vect))
    n == 0 ? [0,0,0] : vect/n;
    
function makeMatrix(v1,v2,v3,pos) =
    [[v1[0],v2[0],v3[0],pos[0]],
     [v1[1],v2[1],v3[1],pos[1]],
     [v1[2],v2[2],v3[2],pos[2]],
     [0,0,0,1]];

function getTransform(f,uv,normalize=true,extraParameters=[],delta=0.01) =
    let(u = uv[0],
        v = uv[1],
        fc = eval(f,concat([["u",u],["v",v]],extraParameters)),
        f_u = (eval(f,concat([["u",u+delta],["v",v]],extraParameters))-fc)/delta,
        f_v = (eval(f,concat([["u",u],["v",v+delta]],extraParameters))-fc)/delta,
        normal = cross(f_u,f_v),
        t = (norm(f_u)+norm(f_v))/2,
        adjNormal = t==0 ? normal : normal/t)
        
        normalize ? makeMatrix(normalize(f_u),normalize(f_v),normalize(normal),fc) : makeMatrix(f_u,f_v,normal,fc);
        
function _slice(a,start,end=undef) =
    let(end = end==undef ? len(a) : end)
        start>=end ? [] : [for (i=[start:end-1]) a[i]];
            
function _compare2D(a,b) =
    a[0] < b[0] ? -1 :
    b[0] < a[0] ? 1 :
    a[1] < b[1] ? -1 :
    b[1] < a[1] ? 1 :
    0;

function _mergeLists2DUnique(a,b,merged=[]) =
    len(a)==0 ? concat(merged,b) :
    len(b)==0 ? concat(merged,a) :
    let(comp=_compare2D(a[0],b[0]))
    comp == -1 ? _mergeLists2DUnique(_slice(a,1), b, merged=concat(merged,[a[0]])) : 
    comp == 1 ? _mergeLists2DUnique(_slice(b,1), a, merged=concat(merged,[b[0]])) :
    _mergeLists2DUnique(_slice(a,1), _slice(b,1), merged=concat(merged,[a[0]]));        

function mergeSort2DUnique(a) =
    let(l=len(a))
        l <= 1 ? a :
        let(split=floor(l/2),
            b=_slice(a,0,end=split),
            c=_slice(a,split))
            _mergeLists2DUnique(mergeSort2DUnique(b),mergeSort2DUnique(c));
            
// assume positive values           
function calculateDistances(f,variableVar,variableValue,fixedVar,fixedValue,maxDistance,prevPosition,nextPosition,distance=0,delta=0.01,extras=[],soFar=[]) = 
    distance+norm(nextPosition-prevPosition) >= maxDistance ? concat(soFar,[distance+norm(nextPosition-prevPosition)]) :
    calculateDistances(f,variableVar,variableValue+delta,fixedVar,fixedValue,maxDistance,nextPosition,eval(f,concat(extras,[[variableVar,variableValue+delta],[fixedVar,fixedValue]])),distance=distance+norm(nextPosition-prevPosition),delta=delta,extras=extras,soFar=concat(soFar,[distance+norm(nextPosition-prevPosition)] ));
    
cf = compileFunction("[u,v,u+v]");    
    
function findValue(list,value,pos=0) =
    pos >= len(list) ? pos-1 :
    list[pos] == value ? pos :
    pos > 0 && (list[pos-1]-value)*(list[pos]-value)<0 ? pos-1+(value-list[pos-1])/(list[pos]-list[pos-1]) :
    findValue(list,value,pos=pos+1);    
    
module mapHershey(text,f="[u,v,0]",font="timesr",halign="left",valign="baseline",normalize=true,size=1,extraParameters=[]) {
    cf = compileFunction(f);
    lines = getHersheyTextLines(text,size=size,font=font,halign=halign,valign=valign);
    for (line=lines) {
        hull() {
            multmatrix(getTransform(cf,line[0],normalize=normalize,extraParameters=extraParameters)) children();
            multmatrix(getTransform(cf,line[1],normalize=normalize,extraParameters=extraParameters)) children();
        }
    }
}

//module demo() {
//    mapHershey(text,f=uv,font=fonts[font]) cylinder(d=1,h=3,$fn=8);
//}

//demo();