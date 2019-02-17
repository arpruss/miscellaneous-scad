function sumTo(v,n) = n<=0 ? 0 : v[n-1]+sumTo(v,n-1);
function sum(v) = sumTo(v,len(v));
function interpolationData(v) = let(
    n=len(v)-1,
    d=[for (i=[0:n-1]) norm(v[i]-v[i+1])],
    sumD=[for (i=[0:n]) sumTo(d,i)],
    totalD=sumD[n]) 
        [d,sumD,v,totalD];
function totalLength(interp) = interp[3];
function interpolatePoints(a,b,t) = (1-t)*a+(t)*b;
function findSegmentByDistance(sumD,distance) = let(
    found = [for(i=[0:len(sumD)-1]) if(sumD[i]<=distance && distance<sumD[i+1]) i])
        len(found)>0 ? found[0] : -1;
function interpolateByDistance(interp,distance) = let(
    n=len(interp[1])-1,
    d=interp[0],
    sumD=interp[1],
    v=interp[2],
    totalD=interp[3],
    i=findSegmentByDistance(sumD,distance))
        i<0 ? (distance<totalD/2 ? v[0] : v[n]) :
            interpolatePoints(v[i],v[i+1],(distance-sumD[i])/d[i]);
function get2DNormalBetweenPoints(a,b) = let(
    v = (b-a)/norm(b-a))
        [v[1],-v[0]];
function getTangentByDistance(interp,distance) = let(
    n=len(interp[1])-1,
    d=interp[0],
    sumD=interp[1],
    v=interp[2],
    totalD=interp[3],
    i0=findSegmentByDistance(sumD,distance),
    i = i0 < 0 ? (distance<totalD/2 ? 0 : n-1) : i0)
        (v[i+1]-v[i])/norm(v[i+1]-v[i]);
    
function interpolateByParameter(interp,t) = interpolateByDistance(interp,t*totalLength(interp));
function singleInterpolateByDistance(v,distance) = interpolateByDistance(interpolationData(v),distance);
function singleInterpolateByParameter(v,t) = interpolateByParameter(interpolationData(v),t);
function measurePath(v) = totalLength(interpolationData(v));

function findCoordinateIntersection2(a,b,index,value) = 
    a[index] == value ? a : 
        b[index] == value ? b :
            let( t=(value-a[index]) / (b[index]-a[index]))
                (1-t)*a+t*b;

function findCoordinateIntersections(path,index,value) = 
    [for (i=[0:len(path)-2]) if ((path[i][index]-value)*(path[i+1][index]-value) <= 0) findCoordinateIntersection2(path[i],path[i+1],index,value)];            

function mirrorMatrix(normalVector) = let(v = normalVector/norm(normalVector)) len(v)<3 ? [[1-2*v[0]*v[0],-2*v[0]*v[1]],[-2*v[0]*v[1],1-2*v[1]*v[1]]] : [[1-2*v[0]*v[0],-2*v[0]*v[1],-2*v[0]*v[2]],[-2*v[0]*v[1],1-2*v[1]*v[1],-2*v[1]*v[2]],[-2*v[0]*v[2],-2*v[1]*v[2],1-2*v[2]*v[2]]];

function trimArray(a, n) = [for (i=[0:n-1]) a[i]];

function transformPoint(matrix,a) = 
    let(n=len(a))
        len(matrix[0])==n+1 ? 
            trimArray(matrix * concat(a,[1]), n)
            : matrix * a;

function transformPath(matrix,path) =
    [for (a=path) transformPoint(matrix,a)];

function reverseArray(array) = let(n=len(array)) [for (i=[0:n-1]) array[n-1-i]];

function stitchPaths(a,b) = let(na=len(a)) [for (i=[0:na+len(b)-2]) i<na? a[i] : b[i-na+1]-b[0]+a[na-1]];

//interp = interpolationData([[1,2],[2,3],[1,2]]);
//echo(singleInterpolateByParameter([[1,1],[2,2],[3,1]],0.75));
//echo(measurePath([[1,2],[2,3],[1,2]]));

