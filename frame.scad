show = 0; // [0:back, 1:front]
pictureSizeUnits = 25.4; // [1:mm, 25.4:inches]
pictureHeightInUnits = 7;
pictureWidthInUnits = 5;
frameFrontThickness = 4;
frameWidth=12;
framePictureOverlap=5;
frameBackingThickness=3;
frameStandWidth=45;
tolerance=0.2;
backPieceFillFraction=0.1;
frameStandThickness=6;

module dummy() {}

pictureHeight = pictureHeightInUnits * pictureSizeUnits;
pictureWidth = pictureWidthInUnits * pictureSizeUnits;

module front() {
wOut = pictureWidth+2*frameWidth-2*framePictureOverlap;
hOut = pictureHeight+2*frameWidth-2*framePictureOverlap;
wIn = pictureWidth-2*framePictureOverlap;
hIn = pictureHeight-2*framePictureOverlap;
    frameStandAngle=acos(frameStandWidth/hOut);

    linear_extrude(height=frameFrontThickness)
    difference() {
        square([wOut,hOut], center=true);
        square([wIn,hIn], center=true);
    }
    linear_extrude(height=frameFrontThickness+frameBackingThickness)
    difference() {
        square([wOut,hOut], center=true);
        square([pictureWidth+4*tolerance,pictureHeight+4*tolerance], center=true);
    }
    intersection() {
        translate([-wOut/2,-hOut/2,0]) cube([wOut,hOut,frameFrontThickness+frameBackingThickness+frameStandWidth]);
        translate([0,-hOut/2,frameFrontThickness+frameBackingThickness])
        rotate(-[90-frameStandAngle,0,0])
        translate([-wOut/2,0,0])
        cube([wOut,frameStandThickness,frameStandWidth]);
    }
}

module back() {
    
    dim = min(pictureWidth,pictureHeight)*backPieceFillFraction;
    linear_extrude(height=frameBackingThickness) {
        difference() {
            square([pictureWidth-2*tolerance,pictureHeight-2*tolerance], center=true);
            square([pictureWidth-2*tolerance-2*dim,pictureHeight-2*tolerance-2*dim], center=true);
        }
        intersection() {
            square([pictureWidth-2*tolerance,pictureHeight-2*tolerance], center=true);
            union() {
                rotate(atan2(pictureHeight,pictureWidth)) square([2*pictureWidth,dim], center=true);
                rotate(-atan2(pictureHeight,pictureWidth)) square([2*pictureWidth,dim], center=true);
            }
    }
}
}

if (show==1) {
    render(convexity=2)
    front();
}
else {
    render(convexity=2)
    back();
}