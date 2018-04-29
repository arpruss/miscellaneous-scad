horizontalCells = 16;
verticalCells = 16;
cellSize = 13.5;
innerWallThickness = 1;
innerWallHeight = 13;
outerWallThickness = 2;
outerWallHeight = 13;
baseThickness = 1;
flareSize = 1.5;
startHolePosition = 1; // [0:None, -1:Bottom, 1:Top]
endHolePosition = -1; // [0:None, -1:Bottom, 1:Top]
// set seed to something other than 0 for a repeatable design
seed = 0;

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

rs = seed ? rands(0,.9999999,ceil(horizontalCells * verticalCells * len(directions) / 2),seed) : rands(0,.9999999,ceil(horizontalCells * verticalCells * len(directions) / 2));

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
function getRandomUnvisitedNeighbor(cells,pos,r) =
    let(n=countUnvisitedNeighbors(cells,pos))
    n == 0 ? undef :
        getNthUnvisitedNeighbor(cells,pos,floor(r*n));
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

function iterateMaze(cells,pos,stack=[],rs=rs) = 
    let(unvisited = getRandomUnvisitedNeighbor(cells,pos,rs[0]))
    unvisited != undef ? 
        iterateMaze(visit(cells, pos, unvisited), move(pos,unvisited), concat([pos], stack), rs=tail(rs)) : 
    len(stack) > 0 ?
        iterateMaze(cells,stack[0],tail(stack), rs=tail(rs)) :
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

module innerWall() {
    linear_extrude(height=innerWallHeight) circle(d=innerWallThickness, center=true);
}

module innerWallFlare() {
    translate([0,0,innerWallHeight-flareSize]) linear_extrude(height=flareSize,scale=(flareSize*2+innerWallThickness)/innerWallThickness) circle(d=innerWallThickness,center=true);
}

module mazeBox(h) {
    linear_extrude(height=h) hull() renderOutside(max(0,(outerWallThickness-innerWallThickness)/2),spacing=cellSize) circle(d=outerWallThickness);
}

module hole(x,y,position,spacing=10) {
    if (position != 0) {
        holeSize=spacing-innerWallThickness;
        translate([(x+0.5)*spacing,(y+0.5)*spacing,0])
        if (position>0) {
            translate([0,0,baseThickness+nudge]) cylinder(h=outerWallHeight+innerWallHeight,d=holeSize,$fn=32);
        }
        else {
            translate([0,0,-nudge]) cylinder(h=baseThickness+3*nudge,d=holeSize,$fn=32);
        }
    }
}
        
module maze0() {
    difference() {
        union() {
            maze = iterateMaze(baseMaze([0,0]), [0,0]);

            translate([0,0,baseThickness]) {
                renderInside(maze, spacing=cellSize)            innerWall();
                if (flareSize>0)
                    renderInside(maze, spacing=cellSize)            innerWallFlare();
            renderOutside(max(0,(outerWallThickness-innerWallThickness)/2),spacing=cellSize) cylinder(d=outerWallThickness,h=outerWallHeight);        
            if(flareSize>0)
            renderOutside(0, spacing=cellSize)            innerWallFlare();
            }

            if(baseThickness>0)
                mazeBox(baseThickness+nudge);
        }
        
        hole(horizontalCells-1,verticalCells-1,endHolePosition,spacing=cellSize);
        hole(0,0,startHolePosition,spacing=cellSize);
    }
}

module maze() {
    if (flareSize>0) 
    //render(convexity=0)
    intersection() {
      maze0();
      mazeBox(h=baseThickness+outerWallHeight+innerWallHeight);
    }
    else maze0();
}

maze();