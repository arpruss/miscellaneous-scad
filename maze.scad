// Algorithm:   https://en.wikipedia.org/wiki/Maze_generation_algorithm#Recursive_backtracker

mazeWidth = 16;
mazeHeight = 12;

// cell structure: [visited, [wall1, wall2, ...]]
// position: [x,y]
// direction: 0,1,2,3

directions = [ [-1,0], [1,0], [0,-1], [0,1] ];
wallCoordinates = [ [ [-0.5,-0.5],[-0.5,0.5] ],
    [ [0.5,-0.5],[0.5,0.5] ],
    [ [-0.5,-0.5],[0.5,-0.5] ],
    [ [-0.5,0.5],[0.5,0.5] ] ];
revDirections = [1,0,3,2];

function inside(pos) = pos[0] >= 0 && pos[1] >= 0 && pos[0] < mazeWidth && pos[1] < mazeHeight;
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
    [ for(x=[0:mazeWidth-1]) [ for(y=[0:mazeHeight-1]) 
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
    [ for(x=[0:mazeWidth-1]) [ for(y=[0:mazeHeight-1]) 
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

module renderOutside(spacing=10) {
    for(wall=wallCoordinates) {
        hull() {
            for(i=[0:1])
            translate([(0.5+wall[i][0])*spacing*mazeWidth,(0.5+wall[i][1])*spacing*mazeHeight]) children();
        }
    }
}
        
maze = iterateMaze(baseMaze([0,0]), [0,0]);
renderInside(maze) cylinder(d=1,h=10);        
renderOutside() cylinder(d=1.5,h=15);        

        