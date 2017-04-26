function ringPoints(param) = len(param[0]);
function ringValue(param,point) = param[0][point];
function numRings(param) = floor(0.5+height(param)/lead(param)*$fn);
function radius(param) = param[1];
function height(param) = param[2];
function lead(param) = param[3];
function heightAtRing(param, ring) = ring/(numRings(param)-1)*height(param);
function angleAtRing(param, ring) = heightAtRing(param, ring) / lead(param) * 360;

function extrusionPoint(param,ring,point) = 
    let (n=ringPoints(param),
        v=ringValue(param,point),
        r=radius(param),
        angle=angleAtRing(param,ring)) 
        [ (r+v[0])*cos(angle), (r+v[0])*sin(angle), heightAtRing(param,ring)+v[1]];
        
function mod(m,n) = let(mm = m%n) mm<0 ? n+mm : mm;
        
function extrusionPointIndex(param,ring,point) = 
    let (n=ringPoints(param)) 
        n*ring + mod(point,n);
        
function startFacePoints(param) = 
    let (n = ringPoints(param)) 
        [for (i=[0:n-1]) extrusionPointIndex(param,0,i)];
            
function endFacePoints(param) = 
    let (m=numRings(param), n=ringPoints(param)) 
            [for (i=[n-1:-1:0]) extrusionPointIndex(param,m-1,i)];
                
function tubeFaces(param) =
    let (m=numRings(param), n=ringPoints(param))
            [for (i=[0:m-2]) for (j=[0:n-1]) for(tri=[0:1])
                tri==0 ? 
                    [extrusionPointIndex(param,i,j),extrusionPointIndex(param,i+1,j),extrusionPointIndex(param,i,j+1)] :
                    [extrusionPointIndex(param,i,j+1), extrusionPointIndex(param,i+1,j),
            extrusionPointIndex(param,i+1,j+1)]];
                

function extrusionFaces(param) = concat([startFacePoints(param)],concat(tubeFaces(param),[endFacePoints(param)]));

function extrusionPoints(param) = 
    let (m = numRings(param), n=ringPoints(param))
        [for (i=[0:m-1]) for (j=[0:n-1]) extrusionPoint(param,i,j)];
                    
module rawThread(profile, radius, height, lead) {
    param = [profile, radius, height+2*lead, lead];
    size = 1+2*radius + 2*max(max([for (v=profile) v[0]]),max([for (v=profile) -v[0]]));
    render(convexity=10)
    intersection() {
        translate([-size/2,-size/2,0]) cube([size,size,height]);
        translate([0,0,-lead])
        polyhedron(faces=extrusionFaces(param),points=extrusionPoints(param));
    }
}

//rawThread([[0,0],[1.5,1.5],[0,3]], 25, 50, 3);
rawThread([[0,0],[0,3],[3,3],[3,0]], 25, 50, 6, $fn=80);
