use <bezier.scad>;

//<params>
tubeID = 12;
tubeWall = 1.5;
tubeHeight = 20;
baseHeight = 13;
baseWidth = 29;
minimumWidth = 0.6;
tensionFactor1 = 0.2;
tensionFactor2 = 0.25;
//</params>

module dummy() {}
$fn = 36;

tube = tubeID + tubeWall*2;

module base() {
    polygon(Bezier([[-baseWidth/2,0],
    POLAR(minimumWidth/4,90),POLAR(minimumWidth/4,180),[-baseWidth/2+minimumWidth/2,minimumWidth/2],
    POLAR(baseWidth*tensionFactor1,0),POLAR(baseWidth*tensionFactor2,180),[0,tube/2],REPEAT_MIRRORED([1,0]),REPEAT_MIRRORED([0,-1])]));
}

difference() {
    union() {
        linear_extrude(height=baseHeight)
        base();
        cylinder(d=tube,h=tubeHeight+baseHeight);
    }
    cylinder(d=tubeID,h=4*(tubeHeight+baseHeight),center=true);
}