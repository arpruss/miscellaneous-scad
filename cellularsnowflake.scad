hexSize = 10;
// If you use join mode, it is recommended you set filledRatio to 0.5 or less.
joinMode = 0; // [0:no, 1:yes]
// How much of the hex to fill.
filledFraction = 1;
steps = 50;
thickness = 2;
// Generation rule. A sequence of probabilities depending on how many neighbors there are, between 0 and 6. The first entry is the probability of generating with zero neighbors. The last entry is the probability of generating with six neighbors.
generationRule = [0,.4,0,0,0,0,0];
// Survival rule. A sequence of probabilities depending on how many neighbors there are, between 0 and 6. The first entry is the probability of surviving with zero neighbors. The last entry is the probability of surviving with six neighbors.
survivalRule = [1,1,1,1,1,1,1];
color1 = [.26,.71,1];
color2 = [1,1,1];
// Set to 0 to get something different each time.
seed = 0; 

module dummy(){}

rules = 
    [ generationRule, survivalRule ];

animate = 0;

data = [[steps+1]];

cos30 = cos(30);
sin30 = sin(30);

// The data holds about 1/12 of the snowflake.
function rowSize(i) =
    i == 0 ? 1 : ceil((i+1)/2);

function sum(vector, pos=0, soFar=0) =
    pos >= len(vector) ? soFar :
    sum(vector, pos=pos+1, soFar=vector[pos]+soFar);

function cumulativeSums(vector, pos=0, soFar=[0]) = 
    pos >= len(vector) ? soFar :
    cumulativeSums(vector, pos=pos+1, soFar=concat(soFar,[soFar[pos]+vector[pos]]));

cumulativeRowSizes = cumulativeSums([for(i=[0:steps]) rowSize(i)]);

numCells = cumulativeRowSizes[steps+1];

numRandomPoints = steps * numCells;

rawRandomData = seed ? rands(0,1,numRandomPoints,seed) : rands(0,1,numRandomPoints);

function getRandom(step, i, j) =
    rawRandomData[step*numCells + cumulativeRowSizes[i] + j];

// This allows data to be got at points at one
// remove from the data by using symmetries.
function getExact(data,i,j) = 
    i >= len(data) ? 0 :
    i <= 1 ? data[i][0] :
    let(rs = rowSize(i)) (
    j == -1 ? data[i][1] :
    j == rs ? ( i%2 ? data[i][rs-1] : data[i][rs-2] )
    : data[i][j] );
    
function get(data,i,j) = 
    getExact(data,i,j) > 0 ? 1 : 0;
    
function getColor(n) =
    let(t=(steps+1-n)/steps) 
        (1-t)*color1+t*color2;

function neighborCount(data,i,j) =
    i == 0 ? 6*get(data,1,0) :
    j == 0 ? get(data,i,-1)+get(data,i,1)+get(data,i+1,-1)+get(data,i+1,0)+get(data,i+1,1)+get(data,i-1,0) :
    get(data,i,j-1)+get(data,i,j+1)+get(data,i+1,j)+get(data,i+1,j+1)+get(data,i-1,j)+get(data,i-1,j-1);
    
function evolve(data, n) = 
    n == 0 ? data :
    evolve(
     [ for(i=[0:len(data)]) 
        [ for(j=[0:rowSize(i)-1]) 
            rules[get(data,i,j)][neighborCount(data,i,j)] >= getRandom(n-1,i,j) * 0.999999 ? (getExact(data,i,j)>0 ? getExact(data,i,j) : n) : 0 ] ], n-1);
        
function getCoordinates(i,j) = 
        hexSize*([0,i]+[cos(30),-sin(30)]*j);

module show(i,j,n) {
    color(getColor(n))
    linear_extrude(height=thickness)
    foldout() 
    translate(getCoordinates(i,j)) circle(r=1.001*hexSize/sqrt(3)*filledFraction,$fn=6);
}

module visualize(data) {
    for(i=[0:len(data)-1]) for(j=[0:rowSize(i)-1]) 
        if(data[i][j] > 0) show(i,j,data[i][j]);
}    

module visualizeJoined(data) {
    for(i=[0:len(data)-1]) for(j=[0:rowSize(i)-1])
        if(data[i][j]) {
           if(get(data,i,j+1))
                hull() { show(i,j); show(i,j+1); }
           if(get(data,i+1,j))
                hull() { show(i,j); show(i+1,j); }
           if (get(data,i+1,j+1))
                hull() { show(i,j); show(i+1,j+1); }
        }
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
        if (joinMode)
            linear_extrude(height=thickness)
            visualizeJoined(evolve(data,steps));
        else
            visualize(evolve(data,steps));
}
