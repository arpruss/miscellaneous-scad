needsSupport = 1; // [0:No, 1:Yes]
seatBungeeClip = 1; // [0:No, 1:Left, 2:Right]
sideReinforce = 3;

strapBarLength = 26.3;
strapSlitThickness = 3.45; // orig: 3.77
strapBarTopWidth = 4.06;
strapBarHeight = 9; // orig: 8.77
sideMinimum = 8.5;
toothWidth = 1.2;
toothDepth = 0.6;
rearBarHeight = 6;
rearBarWidth = 9;
outerMinorDiameter = 36.3;

attachmentOffset = 5;

bigHole = 21.5;
smallHole = 11.5;
smallHoleOffset = 10.5;
bigThickness = 11; 
smallThickness = 6.85;
outerCircleOffset = 6.5;
frontBackOffset = 16;
rounding = 3;
bottomIncut = 1.5;
bottomSmallIncut = 1.5;

fingerSpacing = 6;
fingerWidth = 5.5;
fingerSizeAdjust = 1;
fingerInset = 4;
fingerForwardShift = 1;
fingerInsideForwardShift = 1;
rearBungeeKeeperStickout = 7;

module dummy() {}

outerDiameter = strapBarLength + 2 * sideMinimum;
rearThickness = bigThickness;//was strapBarHeight

nudge = .01;

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
    [ [ strapBarTopWidth+strapSlitThickness, 0] , [ strapBarTopWidth+strapSlitThickness + rearBarWidth-incut, 0],
    [ strapBarTopWidth+strapSlitThickness + rearBarWidth, incut],
    [ strapBarTopWidth+strapSlitThickness + rearBarWidth, rearBarHeight],
    [ strapBarTopWidth+strapSlitThickness+rearBarHeight,rearBarHeight] ];
    translate([0,0,-sideMinimum])
    linear_extrude(height=strapBarLength+2*sideMinimum)
        polygon(supportProfile(bottomIncut));
    
    for (z=[-sideMinimum,strapBarLength]) 
        translate([0,0,z]) linear_extrude(height=sideMinimum) hull() {
        translate([0,0]) polygon(supportProfile(bottomSmallIncut));
        translate([0,0]) polygon(strapBarProfile);
        translate([0,rearThickness-strapBarHeight]) polygon(strapBarProfile);
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
    if (seatBungeeClip && rearBungeeKeeperStickout>0)  {
        translate([-attachmentOffset-strapBarTopWidth-nudge,0,0]) 
        linear_extrude(height=rearBarHeight) for(s=[-1,1]) translate([-10,s*(fingerWidth/2+fingerSpacing/2)]) hull() {
            square([nudge,fingerSpacing],center=true);
            translate([-rearBungeeKeeperStickout-3+fingerSpacing/2,0,0]) {
                circle(d=fingerSpacing,$fn=36);
                translate([-fingerSpacing/4,-s*fingerSpacing/4]) square(fingerSpacing/2,center=true);
            }
        }
    }
}

//strapHolder();

module attachment() {
    $fn = 120;
    
    module finger(inside=false) {
        translate([fingerForwardShift,0,0]) {
            r = fingerSpacing+fingerWidth+fingerSizeAdjust;
            if (!inside)
            translate([r*.2,-fingerInset]) intersection() {
                circle(r=r);
                square([2*r,2*r-2*fingerSizeAdjust],center=true);
            }
            else
            translate([0,fingerSpacing/2]) {
                translate([fingerInsideForwardShift,-fingerInset]) hull() {
                    circle(d=fingerSpacing);
                    translate([100,0]) circle(d=fingerSpacing);
                }
            }
        }
    }
    
    module main() {
        difference() {
            union() {
                hull() {
                    translate([outerCircleOffset,0]) scale([outerMinorDiameter/outerDiameter,1]) circle(d=outerDiameter);
                    translate([-frontBackOffset,-outerDiameter/2]) square([1,outerDiameter]); 
                }
                if (seatBungeeClip) {
                    translate([-6,outerDiameter/2]) finger(false);
                }
            }
            if (seatBungeeClip) {
                    translate([-6,outerDiameter/2]) finger(true);
            }
            circle(d=bigHole);
            translate([smallHoleOffset,0]) circle(d=smallHole);
        }
    }
    translate([frontBackOffset,0,0]) 
    difference() {
        linear_extrude(height=bigThickness) 
            if (!seatBungeeClip || 
                (!needsSupport && seatBungeeClip==1) ||
                (needsSupport && seatBungeeClip==2)) main(); 
            else mirror([0,1]) main();
        hull() {
            translate([0,0,smallThickness])
            cylinder(d=bigHole,h=bigThickness);
            translate([smallHoleOffset,0,smallThickness]) 
            cylinder(d=bigHole,h=bigThickness);
        }
    }
}

if (!needsSupport) {
    attachment();
}
else {
    translate([0,0,bigThickness])
    mirror([0,0,1]) 
    attachment();
}

strapHolder();
