use <tubemesh.scad>;

baseDiameter = 19.04;
topDiameter = 11.4;
upperHeight = 8;
lowerHeight = 7.5;
endRibsFromTop = 2.24;
ribThickness = 1;
numberOfRibs = 24;
innerDiameter = 6;
innerIncut = 1.5;
tolerance = 0.3;

module dummy(){}

heights = [0,
    lowerHeight-ribThickness,
    lowerHeight,
    upperHeight-endRibsFromTop-ribThickness,
    upperHeight-endRibsFromTop,
    upperHeight];

innerRadii = [baseDiameter/2,
    baseDiameter/2,
    baseDiameter/2,
    undef,
    undef,
    upperHeight];

ribs = [0,
    0,
    ribThickness,
    ribThickness,
    0,
    0];

ribZero = [0,
    0,
    ribThickness,
    ribThickness,
    ribThickness,
    ribThickness];
    
function findDefined(r,i,delta) =
    r[i+delta] == undef ? findDefined(r,i+delta,delta) : i+delta;

function interpolate(r) =
    [ for(i=[0:len(r)-1]) 
    r[i] != undef ? r[i] :
    let(prev=findDefined(r,i,-1),
        next=findDefined(r,i,1))
        (heights[i]-heights[prev])/(heights[next]-heights[prev])*(r[next]-r[prev]) + r[prev] ];
 
innerRadii1 = interpolate(innerRadii);
ribs1 = interpolate(ribs);
ribZero1 = interpolate(ribZero);

profiles = 
    [ for(i=[0:len(heights)-1])
      join([ for(j=[0:numberOfRibs-1])
        [
          