neckWidth = 1.45;
neckLength = 3.4;
neckHeight = 4.1;
overlap = 1.5;
attachmentWidth = 4.5;
attachmentDepth = 3;
attachmentThickness = 1.5;

module cubeCX(c) {
    translate([-0.5*c[0],0,0]) cube(c);
}

cubeCX([attachmentWidth,attachmentDepth+overlap,attachmentThickness]);
translate([0,attachmentDepth,0]) cubeCX([neckWidth,neckHeight,attachmentThickness+neckLength]);