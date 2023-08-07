hotshoeWidth = 18.52;
hotshoeThickness = 1.95;
hotshoeLength = 18;
hotshoeInset = 3.2;
hotshoeTaper = 0.25;

    
    
module hotshoe(coverStickout = 0) {    
hotshoeProfile = [
    [-hotshoeWidth/2, 0],
    [-hotshoeWidth/2+hotshoeTaper, hotshoeThickness],
    [-hotshoeWidth/2+hotshoeInset, hotshoeThickness],
    [-hotshoeWidth/2+hotshoeInset, hotshoeThickness+coverStickout],
    [hotshoeWidth/2-hotshoeInset, hotshoeThickness++coverStickout],
    [hotshoeWidth/2-hotshoeInset, hotshoeThickness],
    [hotshoeWidth/2-hotshoeTaper, hotshoeThickness],
    [hotshoeWidth/2, 0] ];

    rotate([90,0,0])
    linear_extrude(height=hotshoeLength) polygon(hotshoeProfile);
}

hotshoe(coverStickout = 3);