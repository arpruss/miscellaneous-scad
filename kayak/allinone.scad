strapBarLength = 26.3;
strapSlitThickness = 3.45; // orig: 3.77
strapBarTopWidth = 4.06;
strapBarHeight = 8.5; // orig: 8.77
sideMinimum = 5;
toothWidth = 1.2;
toothDepth = .6;
rearSupportHeight = 6;
rearSupportWidth = 9;

attachmentOffset = 10;

bigHole = 21.5;
smallHole = 11.5;
smallHoleOffset = 10.5;
bigThickness = 8.5; // orig: 8
smallThickness = 5;
outerCircleOffset = 6.5;
frontBackOffset = 16;
rounding = 3;
bottomIncut = 3.5;
bottomSmallIncut = 1.5;

module dummy() {}

nudge = .01;
outerDiameter = 2*sideMinimum+strapBarLength; //37;

module strapHolderBasic() {
    strapBarProfile = [[0,0],[strapBarTopWidth,0],
        [strapBarTopWidth+strapBarHeight,strapBarHeight],[strapBarHeight,strapBarHeight]];
    toothCount0 = floor(strapBarLength / (2*toothWidth));
    toothCount = floor(toothCount0 / 2)*2;
    difference() {
        translate([0,0,-nudge]) linear_extrude(height=2*nudge+strapBarLength) polygon(strapBarProfile);
        for (i=[0:toothCount-1]) {
            z = strapBarLength/2+(i-toothCount/2+.5)/toothCount*strapBarLength;
            translate([0,strapBarHeight-toothDepth,z-toothWidth/2])
                cube([strapBarHeight+strapBarTopWidth+nudge,toothDepth+nudge,toothWidth]);
        }
    }
    
    function supportProfile(incut) = 
    [ [ strapBarTopWidth+strapSlitThickness, 0] , [ strapBarTopWidth+strapSlitThickness + rearSupportWidth-incut, 0],
    [ strapBarTopWidth+strapSlitThickness + rearSupportWidth, incut],
    [ strapBarTopWidth+strapSlitThickness + rearSupportWidth, rearSupportHeight],
    [ strapBarTopWidth+strapSlitThickness+rearSupportHeight,rearSupportHeight] ];
    translate([0,0,-sideMinimum])
    linear_extrude(height=strapBarLength+2*sideMinimum)
        polygon(supportProfile(bottomIncut));
    for (z=[-sideMinimum,strapBarLength]) 
        translate([0,0,z]) linear_extrude(height=sideMinimum) hull() {
        translate([0,0]) polygon(supportProfile(bottomSmallIncut));
        translate([0,0]) polygon(strapBarProfile);
        translate([-attachmentOffset,0]) polygon([[0,0],[0,bigThickness],[1,bigThickness],[1,0]]);
    }
    
}

module strapHolder() {
    intersection() {
        translate([-attachmentOffset+nudge, strapBarLength/2,0]) 
        mirror([1,0,0]) 
        rotate([90,0,0]) strapHolderBasic();
        linear_extrude(height=strapBarHeight+bigThickness) hull() {
            square([1,outerDiameter],center=true);
            for (s=[-1,1])
                translate([-attachmentOffset-strapBarHeight-strapBarTopWidth-strapSlitThickness+rounding,s*outerDiameter/2-s*rounding]) circle(r=rounding,$fn=36);
        }
    }
}

//strapHolder();

module attachment() {
    $fn = 120;
    translate([frontBackOffset,0,0]) 
    difference() {
        linear_extrude(height=bigThickness)
        difference() {
            hull() {
                translate([outerCircleOffset,0]) circle(d=outerDiameter);
                translate([-frontBackOffset,-outerDiameter/2]) square([1,outerDiameter]); 
            }
            circle(d=bigHole);
            translate([smallHoleOffset,0]) circle(d=smallHole);
        }
        hull() {
            translate([0,0,smallThickness])
            cylinder(d=bigHole,h=bigThickness);
            translate([smallHoleOffset,0,smallThickness]) 
            cylinder(d=bigHole,h=bigThickness);
        }
    }
}

attachment();

strapHolder();