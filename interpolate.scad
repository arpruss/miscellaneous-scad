function sumTo(v,n) = n<=0 ? 0 : v[n-1]+sumTo(v,n-1);
function sum(v) = sumTo(v,len(v));
function distance(a,b) = sqrt(sum([for (i=[0:len(a)-1]) (a[i]-b[i])*(a[i]-b[i])]));
function interpolationData(v) = let(
    n=len(v)-1,
    d=[for (i=[0:n-1]) distance(v[i], v[i+1])],
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
    v = (b-a)/distance(a,b))
        [v[1],-v[0]];
function getTangentByDistance(interp,distance) = let(
    n=len(interp[1])-1,
    d=interp[0],
    sumD=interp[1],
    v=interp[2],
    totalD=interp[3],
    i0=findSegmentByDistance(sumD,distance),
    i = i0 < 0 ? (distance<totalD/2 ? 0 : n-1) : i0)
        (v[i+1]-v[i])/distance(v[i],v[i+1]);
    
function interpolateByParameter(interp,t) = interpolateByDistance(interp,t*totalLength(interp));
function singleInterpolateByDistance(v,distance) = interpolateByDistance(interpolationData(v),distance);
function singleInterpolateByParameter(v,t) = interpolateByParameter(interpolationData(v),t);
function measurePath(v) = totalLength(interpolationData(v));

//interp = interpolationData([[1,2],[2,3],[1,2]]);
//echo(singleInterpolateByParameter([[1,1],[2,2],[3,1]],0.75));
//echo(measurePath([[1,2],[2,3],[1,2]]));