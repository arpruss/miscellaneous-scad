use <tubemesh.scad>

//<params>

// The vase profile will range from the left edge of the drawing square (=center of vase) to the right side of the drawing.
rightHandProfile = [ [ [-35,-25],[-18,0],[-25,25] ], [[0,1,2]] ]; // [draw_polygon:100x100]
crossSection = [ [ [-25,-25], [25,-25], [25,25], [-25,25] ], [[0,1,2,3]] ]; // [draw_polygon:100x100]
twistAngle = 180;
numberOfSections = 30;
actualHeight = 100;
forceDegreesOfRotationalSymmetry = 1;
mirrorInXAxis = 0; //[0:No,1:Yes]
//</params>

function findLowestY(path,pos=0,lowest=[-1,1e50]) =
    pos >= len(path) ? lowest :
    findLowestY(path,
        pos=pos+1,
        lowest=path[pos][1]<lowest[1] ? [pos,path[pos][1]] :       lowest);
        
// right-most curve from rightHandProfile
profile = [for (i=rightHandProfile[1][0]) rightHandProfile[0][i]];
np = len(profile);
lowest = findLowestY(profile);
lowestIndex = lowest[0];
lowestY = lowest[1];
highest = findLowestY(-profile);
highestIndex = highest[0];
highestY = -highest[1];

function angle(a,b) = let(ab=b-a) atan2(ab[1],ab[0]);

nextAngle = angle(profile[lowestIndex], profile[(lowestIndex+1+np)%np]);
prevAngle = angle(profile[lowestIndex], profile[(lowestIndex-1+np)%np]);
direction = nextAngle<prevAngle ? 1 : -1;

adjHighestIndex = direction*lowestIndex < direction*highestIndex ? highestIndex : np+highestIndex;
pointsInverted = [for(i=[lowestIndex:direction:adjHighestIndex]) [profile[i%np][1],50+profile[i%np][0]]];

function findSegment(f,x,soFar=0) =
    soFar >= len(f) ? len(f)-1 :
    x <= f[soFar][0] ? max(0,soFar-1) :
    findSegment(f,x,soFar=soFar+1);

function interpolateFunction(f,x) =
    let(i=findSegment(f,x))
    (f[i+1][1]-f[i][1])/(f[i+1][0]-f[i][0])*(x-f[i][0])+f[i][1];

renorm = 1/max([for(c=crossSection[0]) norm(c)]); 

module main(yMultiply=1) {
    for (crossIndices=crossSection[1]) {
        cross = [for(i=crossIndices) [crossSection[0][i][0],crossSection[0][i][1]*yMultiply]];
        sections = [for (i=[0:numberOfSections-1]) 
                let(t=i/(numberOfSections-1),
                    z=lowestY*(1-t)+highestY*t,
                    scale=renorm*interpolateFunction(pointsInverted,z))
                    twistSectionXY(sectionZ(scale*cross,z),t*twistAngle)];
        scale(actualHeight/(highestY-lowestY))
        translate([0,0,-lowestY])
        tubeMesh(sections);
    }               
}

for (i=[0:forceDegreesOfRotationalSymmetry-1])
    rotate([0,0,i*360/forceDegreesOfRotationalSymmetry]) {
        main();
        if (mirrorInXAxis) {
            main(yMultiply=-1);
        }
}

