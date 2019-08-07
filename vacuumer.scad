use <bezier.scad>;

//<params>
tubeID = 10;
tubeWall = 1.5;
tubeHeight = 30;
baseHeight = 13;
baseWidth = 27;
holeAspectRatio = 0.65;
minimumWidth = 0.6;
tensionFactor1 = 0.2;
tensionFactor2 = 0.25;
//</params>

module dummy() {}
$fn = 36;

tubeH = tubeID * holeAspectRatio + tubeWall*2;
tubeW = tubeID + tubeWall*2;

module base() {
    polygon(Bezier([[-baseWidth/2,0],
    POLAR(minimumWidth/4,90),POLAR(minimumWidth/4,180),[-baseWidth/2+minimumWidth/2,minimumWidth/2],
    POLAR(baseWidth*tensionFactor1,0),POLAR(baseWidth*tensionFactor2,180),[0,tubeH/2],REPEAT_MIRRORED([1,0]),REPEAT_MIRRORED([0,-1])]));
}

difference() {
    union() {
        linear_extrude(height=baseHeight)
        base();
        scale([1,tubeH/tubeW,1])
        cylinder(d=tubeW,h=tubeHeight+baseHeight);
    }
    scale([1,holeAspectRatio,1])
    cylinder(d=tubeID,h=4*(tubeHeight+baseHeight),center=true);
}