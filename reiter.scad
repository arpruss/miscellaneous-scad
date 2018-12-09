use <starcylinder.scad>;

//<params>

/* [Simulation] */
alpha = 1.6;
beta = 0.7;
gamma = 0.002;
gamma_variation_amplitude_ratio = 0.2;
random_beta_variation = 0.3; 
steps = 100;
// in hexes
maximumRadius = 50;

/* [Rendering] */
color1 = [.26,.71,.9];
color2 = [1,1,1];
thickness = 10;
variableThickness = 1; // [0:no, 1:yes]
starProfile = 0; // [0:no, 1:yes (slow, monochrome)]
hexSize = 10;
// If you use join mode, it is recommended you set filledFraction to 0.5 or less. Also, variableThickness is ignored
joinMode = 0; // [0:no, 1:yes]
// How much of the hex to fill.
filledFraction = 1;
// set to 0 to get a different result each time
randomSeed = 20;

//</params>

module dummy(){}
//gamma_variation_degrees_per_step = 30;

// filamentary: a0.8,b0.7,g0.01,n100,r30
// pretty: 0.8,0.8,0.01
// very nice and classical: 0.8,0.8,0.002,n100,r30, also n20, n50 is very nice
// b0.7 is nice, too
// elegant 1.6,0.7,.002

animate = 0;

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

cumulativeRowSizes = cumulativeSums([for(i=[0:maximumRadius]) rowSize(i)]);
    
numCells = cumulativeRowSizes[maximumRadius+1];

numRandomPoints = (1+steps) * numCells;

rawRandomData = randomSeed ? rands(0,1,numRandomPoints,randomSeed) : rands(0,1,numRandomPoints);

startData = [for (i=[0:maximumRadius]) [for(j=[0:rowSize(i)-1]) i==0 ? 1 : beta-random_beta_variation/2+random_beta_variation*rawRandomData[cumulativeRowSizes[i]+j  ]]];
    
randomData = [for (step=[0:steps-1]) [for (i=[0:maximumRadius]) [for(j=[0:rowSize(i)-1]) rawRandomData[(1+step)*numCells+cumulativeRowSizes[i]+j  ]]]];

// This allows data to be got at points at one
// remove from the data by using symmetries.
function get(data,i,j) = 
    i < 0 ? data[1][0] :
    i > maximumRadius ? beta :
    i <= 1 ? data[i][0] :
    let(rs = rowSize(i)) (
    j < 0 ? data[i][-j] :
    j >= rs ? ( i%2 ? data[i][2*rs-1-j] : data[i][2*rs-2-j] )
    : data[i][j] );
    
function receptive(data,i,j) =
    i>=maximumRadius ? false :
    get(data,i,j)>=1 || (
    j == 0 ? get(data,i,1)>=1 || get(data,i+1,0)>=1 || get(data,i+1,1)>=1 || get(data,i-1,0)>=1 :
    get(data,i,j-1)>=1 || get(data,i,j+1)>=1 || get(data,i+1,j)>=1 || get(data,i+1,j+1)>=1 || get(data,i-1,j)>=1 || get(data,i-1,j-1)>=1);
    
function u(data,i,j) = 
    receptive(data,i,j) ? 0 : get(data,i,j);
    
function neighborUSum(u,i,j) =
    j == 0 ? 
    2*get(u,i,1)+get(u,i+1,0)+2*get(u,i+1,1)+get(u,i-1,0) :
    get(u,i,j-1)+get(u,i,j+1)+get(u,i+1,j)+get(u,i+1,j+1)+get(u,i-1,j)+get(u,i-1,j-1);

/*function evolveCell(data,i,j) =
    let(r=receptive(data,i,j))
        (r ? gamma : 0) + get(data,i,j) + (alpha/12)*(-6*u(data,i,j)+neighborUSum(data,i,j));
*/

function adjustedGamma(i,j,step) = (1+(randomData[step-1][i][j]-0.5)*gamma_variation_amplitude_ratio) * gamma;

//function adjustedGamma(i,j,step) = (1+sin(step*gamma_variation_degrees_per_step)*gamma_variation_amplitude_ratio/2) * gamma;

function evolveCell(data,u,i,j,step) =
        let(u0=get(u,i,j))
        (u0==0 ? adjustedGamma(i,j,step)+get(data,i,j) : (1-alpha/2)*u0) + (alpha/12)*neighborUSum(u,i,j);
    
function evolve(data, n) = 
    n == 0 ? data :
    let(u=
     [ for(i=[0:maximumRadius]) 
        [ for(j=[0:rowSize(i)-1]) 
            receptive(data,i,j) ? 0 : get(data,i,j) ] ])
        
    evolve(
     [ for(i=[0:maximumRadius]) 
        [ for(j=[0:rowSize(i)-1]) 
            evolveCell(data,u,i,j,n) ] ], n-1);

function getCoordinates(i,j) = 
        hexSize*([0,i]+[cos(30),-sin(30)]*j);
        
function getRadius(v,i,j) =
        v < 1 ? 0 :
        norm(getCoordinates(i,j))+1.001*hexSize*filledFraction/2;
        

function getColor(v) =
    let(t=min((v-1)*6,1)) 
        t*color1+(1-t)*color2;

module show(i,j) {
    foldout() 
    translate(getCoordinates(i,j)) circle(r=1.001*hexSize/sqrt(3)*filledFraction,$fn=6);
}

function getHeight(v) = (variableThickness || joinMode) ? (min(v,1.25)-1)*4*thickness : thickness;

module visualize(data) {
    for(i=[0:len(data)-1]) {
        for(j=[0:rowSize(i)-1]) { 
            v = data[i][j];
            if(v>=1) color(getColor(v)) linear_extrude(height=getHeight(v)) show(i,j);
        }
    }
}    

module visualizeJoined(data) {
    linear_extrude(height=thickness)
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

module draw(simulated) {
    if (joinMode)
        visualizeJoined(simulated);
    else
        visualize(simulated);
}

simulated = evolve(startData,animate ? round($t*steps) : steps);

if (starProfile) {
    maxRadius = max([for(i=[0:len(simulated)-1]) for(j=[0:rowSize(i)-1]) getRadius(simulated[i][j],i,j)]);
    maxHeight = max([for(i=[0:len(simulated)-1]) for(j=[0:rowSize(i)-1]) getHeight(simulated[i][j])]);
    echo(maxRadius,maxHeight);
        
    render(convexity=5)
    intersection() {
        draw(simulated);
        rotate([0,0,360/12]) starCylinder(points=12, bottomCenter=[0,0,0], bottomEvenRadius=maxRadius,bottomOddRadius=maxRadius*sqrt(3)/2,bottopCenter=[0,0,maxHeight], bottomEvenZ = 0, 
        bottomOddZ = 0, topEvenRadius=maxRadius, topOddRadius=maxRadius*sqrt(3)/2, topEvenZ=maxHeight, topOddZ=0.01);
    }
    
}
else {
    draw(simulated);
}

//echo(evolveCell(data,1,0));
//echo(receptive(data,3,0));
//echo(neighborCount(data,3,0));
