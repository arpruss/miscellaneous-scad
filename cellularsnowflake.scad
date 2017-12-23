hexSize = 10;
steps = 50;
thickness = 2;
// Generation rule. A sequence of 7 zero/one digits. The 1s digit says if a cell is generated when it has zero neighbors. The 10s digit says if a cell is generated when it has one neighbor. Etc. The rule "10" means: generate a new cell whenever there are no neighbors.
generationRule = 0000001;
// Survival rule. A sequence of 7 zero/one digits. The 1s digit says if a live cell survives when it has zero neighbors. The 10s digit says if a live cell survives when it has one neighbor. Etc. The rule "11" means: survive when you have at most one neighbor.
survivalRule = 1111111;
// This is a binary encoding of the generation and survival rules (7 bits generation followed by 7 bits generation).  Set to -1 if you want to use the decimal ones above. The range is 0 to 16383.
binaryRule = -1;

module dummy(){}

function digit(x,n) = floor(x / pow(10,n)) % 10;
function bit(x,n) = floor(x / pow(2,n)) % 2;

rules = 
    binaryRule >= 0 ?
    [ [for (i=[0:6]) bit(binaryRule,i)], [for (i=[0:6]) digit(binaryRule, i+7)] ]
    :
    [ [for (i=[0:6]) digit(generationRule,i)], [for (i=[0:6]) digit(survivalRule, i)] ];

animate = 0;

data = [[1]];

cos30 = cos(30);
sin30 = sin(30);

// The data holds about 1/12 of the snowflake.
function rowSize(i) =
    i == 0 ? 1 : ceil((i+1)/2);

// This allows data to be got at points at one
// remove from the data by using symmetries.
function get(data,i,j) = 
    i >= len(data) ? 0 :
    i <= 1 ? data[i][0] :
    let(rs = rowSize(i)) (
    j == -1 ? data[i][1] :
    j == rs ? ( i%2 ? data[i][rs-1] : data[i][rs-2] )
    : data[i][j] );
    

function neighborCount(data,i,j) =
    i == 0 ? 6*get(data,1,0) :
    j == 0 ? get(data,i,-1)+get(data,i,1)+get(data,i+1,-1)+get(data,i+1,0)+get(data,i+1,1)+get(data,i-1,0) :
    get(data,i,j-1)+get(data,i,j+1)+get(data,i+1,j)+get(data,i+1,j+1)+get(data,i-1,j)+get(data,i-1,j-1);
    
function evolve(data, n) = 
    n == 0 ? data :
    evolve(
     [ for(i=[0:len(data)]) 
        [ for(j=[0:rowSize(i)-1]) 
            rules[get(data,i,j)][neighborCount(data,i,j)] ] ], n-1);

function getCoordinates(i,j) = 
        hexSize*([0,i]+[cos(30),-sin(30)]*j);

module visualize(data) {
    for(i=[0:len(data)-1]) for(j=[0:rowSize(i)-1])
        if(data[i][j] )
            translate(getCoordinates(i,j)) circle(r=1.001*hexSize/sqrt(3),$fn=6);
}    

module foldout() {
    for(i=[0:60:359.999]) rotate(i) {
        mirror([1,0]) children();
        children();
    }
}

if (animate) {
    foldout() visualize(evolve(data,round($t*steps)));
}
else {
    linear_extrude(height=thickness)
    foldout() visualize(evolve(data,steps));
}
