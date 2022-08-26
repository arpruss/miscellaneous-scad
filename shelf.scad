use <roundedSquare.scad>;

width = 290;
depth = 190;

roundedRadius = 15;
holeDiameter = 18;
legDiameter = 20;
legFromEdge = 10;
holeSpacing = 10;

$fn = 64;

function positions(start,end,diameter,minSpacing) =
    let(l=end-start,
        n=floor((l-minSpacing-diameter)/(diameter+minSpacing)),
        spacing=(l-diameter*n)/(n+1))
        echo(start+spacing+diameter/2-start)
        echo(end-(start+spacing*n+diameter*(n-1)+diameter/2))
        [for(i=[0:n-1]) start+spacing*(i+1)+diameter*i+diameter/2];
            //first = start+spacing+diameter/2
            //last = start+spacing*n+diameter*(n-1)+diameter/2 // last = end-(spacing+diameter/2)
    // start+spacing*n+diameter*(n-1)+diameter/2 = end-(spacing+diameter/2)
        //spacing*(n+1)+diameter*n=l

difference() {
    roundedSquare([width,depth],radius=roundedRadius);
    smallInset = legFromEdge+legDiameter/2;
    translate([width/2,depth/2]) for (sx=[-1,1]) for (sy=[-1,1]) translate([sx*(width/2-smallInset),sy*(depth/2-smallInset)]) circle(d=legDiameter);
    bigInset = holeSpacing+legFromEdge/2+legDiameter;
    translate([0,depth/2]) for (sy=[-1,1]) for (x=positions(bigInset,width-bigInset,holeDiameter,holeSpacing)) translate([x,sy*(depth/2-smallInset)]) circle(d=holeDiameter);
    translate([width/2,0]) for (sx=[-1,1]) for (y=positions(bigInset,depth-bigInset,holeDiameter,holeSpacing)) translate([sx*(width/2-smallInset),y]) circle(d=holeDiameter);
        for (x=positions(bigInset,width-bigInset,holeDiameter,holeSpacing))
            for(y=positions(bigInset,depth-bigInset,holeDiameter,holeSpacing)) translate([x,y]) circle(d=holeDiameter);
}