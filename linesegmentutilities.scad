function cross2D(a,b) = a[0]*b[1]-a[1]*b[0];

function pointLeftOfLineSegment2D(v,line) =
    cross2D(line[1]-line[0],v-line[0]) > 0;

// do the two lines meet in a plus sign?
function plusSignish2D(line1,line2) =
    pointLeftOfLineSegment2D(line1[0],line2) !=
      pointLeftOfLineSegment2D(line1[1],line2) &&
    pointLeftOfLineSegment2D(line2[0],line1) !=
      pointLeftOfLineSegment2D(line2[1],line1);
      
function pointToLineDistance(v,line) =
    let(dir = line[1]-line[0],
        l = norm(dir))
        l == 0 ? norm(v-line[0]) :
            let(p = (v-line[0])*dir/(l*l))
            p <= 0 ? norm(v-line[0]) :
            p >= 1 ? norm(v-line[1]) :
            norm(v-(line[0]+p*dir));
            
function distanceBetweenLineSegments2D(line1,line2)
    = plusSignish2D(line1,line2) ? 0 :
        min(pointToLineDistance(line1[0],line2),
            pointToLineDistance(line1[1],line2),
            pointToLineDistance(line2[0],line1),
            pointToLineDistance(line2[1],line1));

function infinity() = 1e200 * 1e200;

function distanceBetweenStrokes2D(s1,s2) =
    min( [for(i=[1:len(s1)-1]) for(j=[1:len(s2)-1]) distanceBetweenLineSegments2D([s1[i-1],s1[i]],[s2[i-1],s2[i]])] );

function distanceBetweenLineDrawings2D(d1,d2)
    = 
    len(d1) == 0 || len(d2) == 0 ? infinity() :
    min( [for(s1=d1) for(s2=d2) distanceBetweenStrokes2D(s1,s2)] );

