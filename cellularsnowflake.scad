hexSize = 10;
steps = 20;
animate = 1;

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
    let(rs = rowSize(i)) (
    j == -1 ? data[i][1] :
    j == rs ? ( i%2 ? data[i][rs-1] : data[i][rs-2] )
    : data[i][j] );
    

function neighborCount(data,i,j) =
    i == 0 ? 6*get(data,1,0) :
    j == 0 ? get(data,i,j-1)+get(data,i,j+1)+get(data,i+1,j-1)+get(data,i+1,j)+get(data,i+1,j+1)+get(data,i-1,j) :
    get(data,i,j-1)+get(data,i,j+1)+get(data,i+1,j)+get(data,i+1,j+1)+get(data,i-1,j)+get(data,i-1,j-1);
    
function evolve(data, n) = 
    n == 0 ? data :
    evolve(
     [ for(i=[0:len(data)]) 
        [ for(j=[0:rowSize(i)-1]) 
            get(data,i,j) || neighborCount(data,i,j) == 1 ? 1 : 0 ] ], n-1);
        
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
    foldout() visualize(evolve(data,round($t*steps)));
}
