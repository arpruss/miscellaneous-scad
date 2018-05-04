mazeRadius = 6;
wallLength = 13;
innerWallThickness = 0.75;
innerWallHeight = 11.5;
outerWallThickness = 1.5;
// must be at least as big as inner wall thickness
outerWallHeight = 13;
baseThickness = 1;
startEndInset = 0.5;
flangeWidth = 2;
flangeAngle = 45;
// set seed to something other than 0 for a repeatable design
seed = 5;

module dummy() {}

$fn = 16;

nudge = 0.001;

// Algorithm:   https://en.wikipedia.org/wiki/Maze_generation_algorithm#Recursive_backtracker

// cell structure: [visited, [wall1, wall2, ...]]
// position: [x,y]
          
//   x x  
// x x x
// x x  
      
cellWidth = 2*cos(30);

function inside(pos) = 
    let (y=pos[1]-cy,
         x=pos[0]-cx)
      abs(x) < mazeRadius &&
      abs(y) < mazeRadius &&
      abs(x-y) < mazeRadius;
      
function toDisplay(pos) =
    let (y=pos[1]-cy,
         x=pos[0]-cx) 
    wallLength * (
        [cellWidth*(x-y/2), 1.5*y]
    );

directions = [ [1,0], [1,1], [0,1], [-1,0], [-1,-1], [0,-1] ];
revDirections = [ 3, 4, 5, 0, 1, 2 ];
wallCoordinates = [ for(i=[0:5]) let(t=i*360/6) [[cos(t-30),sin(t-30)],[cos(t+30),sin(t+30)]] ];
gridWidth = mazeRadius * 2 - 1;
gridHeight = mazeRadius * 2 - 1;
cx = mazeRadius-1;
cy = mazeRadius-1;

rs = seed ? rands(0,.9999999,ceil(gridWidth * gridHeight * len(directions) / 2),seed) : rands(0,.9999999,ceil(gridWidth * gridHeight * len(directions) / 2));


function move(pos,dir) = pos+directions[dir];
function tail(list) = len(list)>1 ? [for(i=[1:len(list)-1]) list[i]] : [];
function visited(cells,pos) = !inside(pos) || cells[pos[0]][pos[1]][0];
function countUnvisitedNeighbors(cells,pos,count=0, dir=0) = dir >= len(directions) ? 
        count :        
        countUnvisitedNeighbors(cells, pos, count = count + (visited(cells,move(pos,dir))?0:1), dir = dir+1);
function getNthUnvisitedNeighbor(cells,pos,count,dir=0) =
    visited(cells,move(pos,dir)) ?
        getNthUnvisitedNeighbor(cells,pos,count,dir=dir+1) :
    count == 0 ? dir :
    getNthUnvisitedNeighbor(cells,pos,count-1,dir=dir+1);
function getRandomUnvisitedNeighbor(cells,pos,r) =
    let(n=countUnvisitedNeighbors(cells,pos))
    n == 0 ? undef :
        getNthUnvisitedNeighbor(cells,pos,floor(r*n));
function visit(cells, pos, dir) = 
    let(newPos=move(pos,dir))
    [ for(x=[0:gridWidth-1]) [ for(y=[0:gridHeight-1]) 
        let(isNew=[x,y]==newPos,
            isOld=[x,y]==pos)
        [ cells[x][y][0] || isNew,
        [for (i=[0:len(directions)-1])
            cells[x][y][1][i] && 
            ( !isNew || revDirections[i] != dir )
            && ( !isOld || i != dir)
        ]]]];

function iterateMaze(cells,pos,stack=[],rs=rs) = 
    let(unvisited = getRandomUnvisitedNeighbor(cells,pos,rs[0]))
    unvisited != undef ? 
        iterateMaze(visit(cells, pos, unvisited), move(pos,unvisited), concat([pos], stack), rs=tail(rs)) : 
    len(stack) > 0 ?
        iterateMaze(cells,stack[0],tail(stack), rs=tail(rs)) :
    cells;
        
function baseMaze(pos) = 
    [ for(x=[0:gridWidth-1]) [ for(y=[0:gridHeight-1]) 
        let(xy = [x,y])
        [ !inside(xy) || xy == pos,
        [for (i=[0:len(directions)-1])
            inside(move(xy,i))] ] ] ];

function walled(cells,pos,dir) =
    cells[pos[0]][pos[1]][1][dir];

function countUnvisitedNeighborsWalled(cells,pos,count=0, dir=0) = dir >= len(directions) ? 
        count :        
        countUnvisitedNeighborsWalled(cells, pos, count = count + ((walled(cells,pos,dir) || visited(cells,move(pos,dir)))?0:1), dir = dir+1);
function getNthUnvisitedNeighborWalled(cells,pos,count,dir=0) =
    (walled(cells,pos,dir) || visited(cells,move(pos,dir))) ?
        getNthUnvisitedNeighborWalled(cells,pos,count,dir=dir+1) :
    count == 0 ? dir :
        getNthUnvisitedNeighborWalled(cells,pos,count-1,dir=dir+1);

function revisit(maze,pos) = 
    [ for(x=[0:gridWidth-1]) [ for(y=[0:gridHeight-1]) 
        [ [x,y] == pos,
          maze[x][y][1] ] ] ];

function getLongest(options,pos=0,best=[]) =
        len(options)<=pos ? best :
    getLongest(options,pos=pos+1,best=best[0]>=options[pos][0] ? best : options[pos]);

function furthest(maze,pos,length=1)
    = let(n=countUnvisitedNeighborsWalled(maze,pos))
      n == 0 ? [length,pos] :
      getLongest([for (i=[0:n-1]) 
         let(dir=getNthUnvisitedNeighborWalled(maze,pos,i))
         furthest(visit(maze,pos,dir),move(pos,dir),length=length+1)]);


module renderWall(dir,outer) {
    height = outer ? outerWallHeight : innerWallHeight;
    thickness = outer ? outerWallThickness : innerWallThickness;
    hull() {
        translate(wallLength*wallCoordinates[dir][0])
            cylinder(d=thickness,h=height);
        translate(wallLength*wallCoordinates[dir][1])
            cylinder(d=thickness,h=height);
    }
    if (flangeWidth>0 && flangeAngle > 0) {
        flangeHeight = flangeWidth/tan(flangeAngle);
        translate([0,0,height-flangeHeight])
            hull() {
                translate(wallLength*wallCoordinates[dir][0])
                    cylinder(d1=thickness,d2=thickness+flangeWidth, h=flangeHeight);
                translate(wallLength*wallCoordinates[dir][1])
                    cylinder(d1=thickness,d2=thickness+flangeWidth, h=flangeHeight);
            }
    }
}

module renderMaze(maze) {
    for (x=[0:len(maze)-1])
        for(y=[0:len(maze[0])-1]) 
            if(inside([x,y]))
                translate(toDisplay([x,y])) 
                    for(i=[0:len(directions)-1]) {
                        outer = !inside(move([x,y],i));
                        if (outer || maze[x][y][1][i]) renderWall(i,outer);        
                        }
}

module hole(x,y,position,spacing=10) {
    if (position != 0) {
        holeSize=spacing-innerWallThickness;
        translate([(x+0.5)*spacing,(y+0.5)*spacing,0])
        if (position>0) {
            translate([0,0,baseThickness+nudge-startInset]) cylinder(h=outerWallHeight+innerWallHeight,d=holeSize,$fn=32);
        }
        else {
            translate([0,0,-nudge]) cylinder(h=baseThickness+3*nudge,d=holeSize,$fn=32);
        }
    }
}

module base() {
    for(x=[0:gridWidth-1]) for(y=[0:gridHeight-1])
        if(inside([x,y]))
        translate(toDisplay([x,y]))
            hull() 
                for (w=wallCoordinates)
                    translate(wallLength*w[0])
                        circle(d=outerWallThickness, $fn=6);
}

module maze0() {
    b=baseMaze([cx,cy]);
     maze = iterateMaze(baseMaze([cx,cy]), [cx,cy]);
    translate([0,0,baseThickness-nudge])
    renderMaze(maze, spacing=wallLength);  if (baseThickness>0)
    linear_extrude(height=baseThickness)
    base();
}

module mark(xy) {
    translate(toDisplay(xy))
    translate([0,0,baseThickness-startEndInset+nudge])
    cylinder(d1=wallLength*0.75,d2=wallLength,h=startEndInset);
}

difference() {
    if (flangeWidth>0 && flangeAngle>0) {
        intersection() {
            maze0();
            linear_extrude(height=baseThickness+innerWallHeight+outerWallHeight) base();
        }
    }
    else {
        maze0();
    }
    if (startEndInset>0) {
        mark([cx,cy]);
        mark([cx,cy+mazeRadius-1]);
        mark([cx,cy-(mazeRadius-1)]);
        mark([cx+mazeRadius-1,cy]);
        mark([cx-(mazeRadius-1),cy]);
        mark([cx+mazeRadius-1,cy+mazeRadius-1]);
        mark([cx-(mazeRadius-1),cy-(mazeRadius-1)]);
    }
}
