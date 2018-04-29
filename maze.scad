horizontalCells = 20;
verticalCells = 16;
cellSize = 10;
innerWallThickness = 1;
innerWallHeight = 10;
outerWallThickness = 2;
outerWallHeight = 16;
baseThickness = 1;
flareSize = 2;

module dummy() {}

$fn = 16;

nudge = 0.001;

// Algorithm:   https://en.wikipedia.org/wiki/Maze_generation_algorithm#Recursive_backtracker

// cell structure: [visited, [wall1, wall2, ...]]
// position: [x,y]
// direction: 0,1,2,3

directions = [ [-1,0], [1,0], [0,-1], [0,1] ];
wallCoordinates = [ [ [-0.5,-0.5],[-0.5,0.5] ],
    [ [0.5,-0.5],[0.5,0.5] ],
    [ [-0.5,-0.5],[0.5,-0.5] ],
    [ [-0.5,0.5],[0.5,0.5] ] ];
revDirections = [1,0,3,2];

function inside(pos) = pos[0] >= 0 && pos[1] >= 0 && pos[0] < horizontalCells && pos[1] < verticalCells;
function move(pos,dir) = pos+directions[dir];
function tail(list) = len(list)>1 ? [for(i=[1:len(list)-1]) list[i]] : [];
function visited(cells,pos) = !inside(pos) || cells[pos[0]][pos[1]][0];
function countUnvisitedNeighbors(cells,pos,count=0, dir=0) = dir >= len(directions) ? 
        count :        
        countUnvisitedNeighbors(cells, pos, count = count + (visited(cells,move(pos,dir))?0:1), dir = dir+1);
function getNthUnvisitedNeighbor(cells,pos,count,dir=0) =
    !visited(cells,move(pos,dir)) ?
        ( count == 0 ? dir :
            getNthUnvisitedNeighbor(cells,pos,count-1,dir=dir+1) ) :
        getNthUnvisitedNeighbor(cells,pos,count,dir=dir+1);
function getRandomUnvisitedNeighbor(cells,pos) =
    let(n=countUnvisitedNeighbors(cells,pos))
    n == 0 ? undef :
        getNthUnvisitedNeighbor(cells,pos,floor(rands(0,n-0.0000001,1)[0]));
function visit(cells, pos, dir) = 
    let(newPos=move(pos,dir),
        revDir=revDirections[dir])
    [ for(x=[0:horizontalCells-1]) [ for(y=[0:verticalCells-1]) 
        let(isNew=[x,y]==newPos,
            isOld=[x,y]==pos)
        [ cells[x][y][0] || isNew,
        [for (i=[0:len(directions)-1])
            cells[x][y][1][i] && 
            ( !isNew || i != revDir )
            && ( !isOld || i != dir)
        ]]]];

function iterateMaze(cells,pos,stack=[]) = 
    let(unvisited = getRandomUnvisitedNeighbor(cells,pos))
    unvisited != undef ? 
        iterateMaze(visit(cells, pos, unvisited), move(pos,unvisited), concat([pos], stack)) : 
    len(stack) > 0 ?
        iterateMaze(cells,stack[0],tail(stack)) :
    cells;
function baseMaze(pos) = 
    [ for(x=[0:horizontalCells-1]) [ for(y=[0:verticalCells-1]) 
        [ [x,y] == pos,
        [for (i=[0:len(directions)-1])
            inside(move([x,y],i))] ] ] ];

module renderWall(dir,spacing) {
    hull() {
        translate(spacing*wallCoordinates[dir][0])
            children();
        translate(spacing*wallCoordinates[dir][1])
            children();
    }
}

module renderInside(maze,spacing=10) {
    translate(spacing*[0.5,0.5])
    for (x=[0:len(maze)-1])
        for(y=[0:len(maze[0])-1]) {
            translate([x,y,0]*spacing)
                for(i=[0:len(directions)-1])
                    if (maze[x][y][1][i]) renderWall(i,spacing) children();
        }
}

module renderOutside(offset, spacing=10) {
    for(wall=wallCoordinates) {
        hull() {
            for(i=[0:1])
            translate([(0.5+wall[i][0])*spacing*horizontalCells+offset*sign(wall[i][0]),(0.5+wall[i][1])*spacing*verticalCells+offset*sign(wall[i][0])]) children();
        }
    }
}

module mazeBox(h) {
    linear_extrude(height=h) hull() renderOutside(max(0,(outerWallThickness-innerWallThickness)/2),spacing=cellSize) circle(d=outerWallThickness);
}

module flare(height,diameter,flareSize) {
    if (flareSize>0) {
        translate([0,0,height-flareSize])
        cylinder(h=flareSize,d1=diameter,d2=diameter+2*flareSize);
    }
}
        
module maze0() {
    maze = iterateMaze(baseMaze([0,0]), [0,0]);

    translate([0,0,baseThickness]) {
        renderInside(maze, spacing=cellSize)            cylinder(h=innerWallHeight,d=innerWallThickness);
        if(flareSize>0)
        renderInside(maze, spacing=cellSize)            flare(innerWallHeight,innerWallThickness,flareSize);
    renderOutside(max(0,(outerWallThickness-innerWallThickness)/2),spacing=cellSize) cylinder(d=outerWallThickness,h=outerWallHeight);        
        if(flareSize>0)
        renderOutside(0, spacing=cellSize)            flare(innerWallHeight,innerWallThickness,flareSize);
    }

    if(baseThickness>0)
        mazeBox(baseThickness+nudge);
}

module maze() {
    if (flareSize>0) 
    render(convexity=1)
    intersection() {
      maze0();
      mazeBox(h=baseThickness+outerWallHeight+innerWallHeight);
    }
    else maze0();
}

maze();