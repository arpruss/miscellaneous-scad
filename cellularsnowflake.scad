hexSize = 10;
// If you use join mode, it is recommended you set filledRatio to 0.5 or less.
joinMode = 0; // [0:no, 1:yes]
// How much of the hex to fill.
filledFraction = 1;
steps = 30;
thickness = 2;
// Generation rule. A sequence of probabilities depending on how many neighbors there are, between 0 and 6. The first entry is the probability of generating with zero neighbors. The last entry is the probability of generating with six neighbors.
generationRule = [0,1,0,0,0,0,1];
// Survival rule. A sequence of probabilities depending on how many neighbors there are, between 0 and 6. The first entry is the probability of surviving with zero neighbors. The last entry is the probability of surviving with six neighbors.
survivalRule = [1,1,1,1,1,1,1];

module dummy(){}

rules = 
    [ generationRule, survivalRule ];

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
    
function evolve(data, n, randOffset=0) = 
    n == 0 ? data :
    evolve(
     [ for(i=[0:len(data)]) 
        [ for(j=[0:rowSize(i)-1]) 
            rules[get(data,i,j)][neighborCount(data,i,j)] >= rands(0,1,1)[0] * 0.999999 ? 1 : 0 ] ], n-1);

function getCoordinates(i,j) = 
        hexSize*([0,i]+[cos(30),-sin(30)]*j);

module show(i,j) {
    foldout() 
    translate(getCoordinates(i,j)) circle(r=1.001*hexSize/sqrt(3)*filledFraction,$fn=6);
}

module visualize(data) {
    for(i=[0:len(data)-1]) for(j=[0:rowSize(i)-1]) 
        if(data[i][j] ) show(i,j);
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
    linear_extrude(height=thickness)
        if (joinMode)
            visualizeJoined(evolve(data,steps));
        else
            visualize(evolve(data,steps));
}
