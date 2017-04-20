hotshoeWidthTolerance = 0.4;
hotshoeThicknessTolerance = 0.3;
   
mountOffset = 2;

dovetailWidth = 13;
dovetailHeight = 3;
dovetailStemHeight = 3;
dovetailLength = 30;// the full length dovetail would be 51;
holeSpacing = 18;
holeDiameter = 4.5;

module dummy() {}

hotshoeLength = 18;
hotshoeInset = 3.2;
hotshoeTaper = 0.25;
hotshoeCorner = 1.5;   
hotshoeWidth = 18.52-hotshoeWidthTolerance;
hotshoeThickness = 1.95-hotshoeThicknessTolerance;

nudge = 0.001;    

extraWidth = dovetailWidth - 2*dovetailHeight;

module daisyDovetail() {

    render(convexity=2)
    translate([0,0,dovetailStemHeight+dovetailHeight])
    rotate([0,180,0])
    rotate([90,0,0])
    linear_extrude(height=dovetailLength)
    polygon([ [-extraWidth/2,0], [-extraWidth/2,dovetailStemHeight], [-extraWidth/2-dovetailHeight,dovetailStemHeight+dovetailHeight], [extraWidth/2+dovetailHeight,dovetailStemHeight+dovetailHeight], [extraWidth/2,dovetailStemHeight], [extraWidth/2,0]]);
}
    
module hotshoe(coverStickout = 2) {    
hotshoeProfile = [
    [-hotshoeWidth/2, 0],
    [-hotshoeWidth/2+hotshoeTaper, hotshoeThickness],
    [-hotshoeWidth/2+hotshoeInset, hotshoeThickness],
    [-extraWidth/2, hotshoeThickness+coverStickout],
    [extraWidth/2, hotshoeThickness+coverStickout],
    [hotshoeWidth/2-hotshoeInset, hotshoeThickness],
    [hotshoeWidth/2-hotshoeTaper, hotshoeThickness],
    [hotshoeWidth/2, 0] ];

    render(convexity=1)
    intersection() {
        rotate([0,0,180])
        rotate([90,0,0])
        linear_extrude(height=hotshoeThickness+coverStickout)
        polygon([[-hotshoeWidth/2,0],
            [-hotshoeWidth/2,hotshoeLength-hotshoeCorner],
            [-hotshoeWidth/2+hotshoeCorner,hotshoeLength],
            [hotshoeWidth/2-hotshoeCorner,hotshoeLength],
            [hotshoeWidth/2,hotshoeLength-hotshoeCorner],
            [hotshoeWidth/2,0]]);

        linear_extrude(height=hotshoeLength) polygon(hotshoeProfile);
    }
}

render(convexity=3)
hotshoe(coverStickout = mountOffset);
translate([0,dovetailHeight+dovetailStemHeight+mountOffset+hotshoeThickness-nudge,dovetailLength])
rotate([90,0,0])
daisyDovetail();