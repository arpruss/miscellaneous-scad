function _furthestAwayFromPoint(points,poly,z,bestD=-1,bestPos=0,pos=0) = 
    len(poly) <= pos ? bestPos :
    norm(points[poly[pos]]-z) > bestD ? _furthestAwayFromPoint(points,poly,z,bestD=norm(points[poly[pos]]-z),bestPos=pos,pos=pos+1) :
    _furthestAwayFromPoint(points,poly,z,bestD=bestD,bestPos=bestPos,pos=pos+1);
    
function _triangleArea(a,b,c) = norm(cross(b-a,c-a))/2;
    
function _furthestAwayFromLine(points,poly,z1,z2,bestArea=-1,bestPos=0,pos=0) = 
    len(poly) <= pos ? bestPos :
    _triangleArea(z1,z2,points[poly[pos]]) > bestArea ? _furthestAwayFromLine(points,poly,z1,z2,bestArea=_triangleArea(z1,z2,points[poly[pos]]),bestPos=pos,pos=pos+1) :
    _furthestAwayFromLine(points,poly,z1,z2,bestArea=bestArea,bestPos=bestPos,pos=pos+1);
    
function normalize(v) = v/norm(v);

function _winding(points,poly,sum=0,pos=0) =
    pos >= len(poly) ? sum :
    _winding(points,poly,sum=sum+(points[poly[(pos+1)%len(poly)]][0]-points[poly[pos]][0])*(points[poly[(pos+1)%len(poly)]][1]+points[poly[pos]][1]),pos=pos+1);

function _isCCW(points,poly) =
_winding(points,poly) < 0;

function identifyPlane(points,poly) = let(i=_furthestAwayFromPoint(points,poly,points[poly[0]]),
           j=_furthestAwayFromLine(points,poly,points[poly[0]],points[poly[i]]),
           normal = cross(points[poly[i]]-points[poly[0]],points[poly[j]]-points[poly[0]]),
           a = points[poly[i]]-points[poly[0]],
           b = cross(normal,a),
           cs = [points[poly[0]],normalize(a),normalize(b),normalize(normal)])
           _isCCW(projectPoints(cs,points),poly) ? cs : [cs[0],-cs[1],cs[2],cs[3]];
                      
function projectPoint(coordsys,p) = let(v=p-coordsys[0],
           vp=v-(v*coordsys[3])*coordsys[3]) [vp*coordsys[1],vp*coordsys[2]];
           
function projectPoints(coordsys,p) = [for(v=p) projectPoint(coordsys,v)];
    
function triangulate(points,poly=undef) = 
    let(poly = poly==undef ? [for(i=[0:1:len(points)-1]) i] : poly)
    len(points[poly[0]]) == 2 ? triangulate2D(points,poly) : triangulate2D(projectPoints(identifyPlane(points,poly),points),poly);

function mod(a,b) = let(m=a%b) m < 0 ? m+b : m;

function _delPoint(v,i) = [for(j=[0:1:len(v)-1]) if(i!=j) v[j]];
    
function _isCCWTriangle(a,b,c) = cross(b-a,c-a) >= 0;
    
function _crosses(points,poly,a,b,ignore,pos=0) =     
    pos >= len(poly) ? false :
    ignore != pos && ignore !=  mod(pos+1,len(poly)) && _isCross(points[poly[pos]],points[poly[mod(pos+1,len(poly))]],a,b) ? true : _crosses(points,poly,a,b,pos=pos+1);

function _isReflex(points,poly,i) = 
    let(n=len(poly),
        a=points[poly[mod(i-1,n)]],
        b=points[poly[i]],
        c=points[poly[mod(i+1,n)]]) cross(b-a,c-b) < 0;
                
function _checkEar2(points,poly,a,b,c,j) = 
   let(p=points[poly[mod(j,len(poly))]],
       c1=cross(p-a,b-a))
       ! ( c1*cross(p-b,c-b) >0 && c1*cross(p-c,a-c)>0 );
                
function _checkEar(points,poly,a,b,c,i,j) =
    mod(j,len(poly))==mod(i-1,len(poly)) ? true :
    _isReflex(points,poly,mod(j,len(poly))) && ! _checkEar2(points,poly,a,b,c,j) ? false :
    _checkEar(points,poly,a,b,c,i,j+1);

function _isEar(points,poly,i) = 
    _isReflex(points,poly,i) ? false :
    let(n=len(poly),
        a=points[poly[mod(i-1,n)]],
        b=points[poly[i]],
        c=points[poly[mod(i+1,n)]],
        j=i+2)
        _checkEar(points,poly,a,b,c,i,i+2);        

function _findEar(points,poly,pos=0) =
    assert(pos<len(poly))
    _isEar(points,poly,pos) ? pos : _findEar(points,poly,pos=pos+1);

function _cutEar(points,poly) = 
    let(n=len(poly),
        i=_findEar(points,poly))
        _delPoint(poly,i);
            
function _getEar(points,poly) = 
    let(n=len(poly),
        i=_findEar(points,poly))
        [poly[mod(i-1,n)],poly[i],poly[mod(i+1,n)]];

function triangulate2D(points,poly,soFar=[]) = 
    len(poly) == 3 ? concat(soFar,[poly]) :
    triangulate2D(points,_cutEar(points,poly),soFar=concat(soFar,[_getEar(points,poly)]));
    
module showMesh(points,tt,width=1) 
{
    for(t=tt) {
        for(i=[0:1:len(t)-1]) {
            hull() {
                translate(points[t[i]]) sphere(d=width);
                translate(points[t[(i+1)%len(t)]]) sphere(d=width);
            }
        }
    }
}

function _find(needle,haystack) = let(f=search([needle], haystack)) f==[[]] ? undef : f[0];

function _refineTriangle(triangle,maxEdge) =
    let(a = triangle[0],
        b = triangle[1],
        c = triangle[2],
        ab = norm(a-b),
        bc = norm(b-c),
        ca = norm(c-a))
        ab <= maxEdge && bc <= maxEdge && ca <= maxEdge ? [triangle] :
        ab > maxEdge && bc > maxEdge && ca > maxEdge ? [[a,(a+b)/2,(a+c)/2],[b,(b+c)/2,(a+b)/2],[c,(a+c)/2,(b+c)/2],[(a+c)/2,(a+b)/2,(b+c)/2]] :
    ab > maxEdge && bc > maxEdge ? [[b,(b+c)/2,(a+b)/2],[a,(a+b)/2,(b+c)/2],[c,a,(b+c)/2]] :
    bc > maxEdge && ca > maxEdge ? [[c,(c+a)/2,(b+c)/2],[b,(b+c)/2,(c+a)/2],[a,b,(c+a)/2]] :
    ca > maxEdge && ab > maxEdge ? [[a,(a+b)/2,(c+a)/2],[c,(c+a)/2,(a+b)/2],[b,c,(a+b)/2]] :
    ab > maxEdge ? [[a,(a+b)/2,c],[(a+b)/2,b,c]] :
    bc > maxEdge ? [[b,(b+c)/2,a],[(b+c)/2,c,a]] :
    /*ca > maxEdge */ [[c,(c+a)/2,b],[(c+a)/2,a,b]];

function _refineMesh1(triangles,maxEdge,pos=0,newTriangles=[]) =
    pos >= len(triangles) ? newTriangles :
    _refineMesh1(triangles,maxEdge,pos=pos+1,newTriangles=concat(newTriangles,_refineTriangle(triangles[pos],maxEdge)));
    
function _maxEdge(faces) = max([for(f=faces) for(i=[0:len(f)-1]) norm(f[(i+1)%len(f)]-f[i])]);

function _refineMeshN(triangles,maxEdge,n=0) =
    n <= 0 ? triangles : _refineMeshN(_refineMesh1(triangles,maxEdge),maxEdge,n=n-1);
    
function _newPointsAndFaces(pointsAndFaces,face,faceSoFar=[]) =
    let(pos=len(faceSoFar),
        points=pointsAndFaces[0],
        faces=pointsAndFaces[1]
    )
    pos >= len(face) ? [points,concat(faces,[faceSoFar])] :
    let(v=face[pos],
        i=_find(v,points)) i==undef ? _newPointsAndFaces([concat(points,[v]),faces],face,faceSoFar=concat(faceSoFar,[len(points)])) : _newPointsAndFaces(pointsAndFaces,face,faceSoFar=concat(faceSoFar,[i]));            
        
function _toPointsAndFaces(faces,pointsAndFaces=[[],[]], pos=0) =
    pos >= len(faces) ? pointsAndFaces :
    _toPointsAndFaces(faces,_newPointsAndFaces(pointsAndFaces,faces[pos]),pos=pos+1);
    
function refineMesh(points=[],triangles=[],maxEdge=5) =
    let(tris = [for (t=triangles) [for (v=t) points[v]]],
        longestEdge = _maxEdge(tris),
        n = ceil(ln(longestEdge/maxEdge)/ln(2)),
        newTris = _refineMeshN(tris, maxEdge, n)) _toPointsAndFaces(newTris);

//<skip>
function testPoly2(n) = concat([for(i=[0:n-1]) 20*[cos(i*360/n),0*rands(0,.3,1)[0],sin(i*360/n)]],[for(i=[0:n-1]) 20*[0.8*cos(i*360/n),0*rands(0,.3,1)[0],-0.8*sin(i*360/n)]]);

testPoints=testPoly2(10);
tt = triangulate(testPoints);
m = refineMesh(testPoints,tt,5);
showMesh(m[0],m[1],width=0.3);
//</skip>
