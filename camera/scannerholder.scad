use <tubeMesh.scad>;

//<params>
doBack = true;
do120 = false;
doFoot = true;
doLight = false;

frameCenterFromBase = 41;
riser = 20;
cameraRider = 8;
baseHeight = cameraRider + riser;

film135 = [35,[36,24]];
film120 = [61.7,[56,56]];
frameMargin = 0.5;
filmTolerance = 0.5;
minimumThickness = 0.5;

thickness = 6;
thicknessTolerance = 0.85; // take into account film thickness, cloth thickness, and plastic creep
inset = 2.5;
plasticTolerance = 0.25;

margin = 1;
horizontalMargin = 18;
verticalMargin = 20;
legSpacing = 90;
legMinimumWidth = 15;

footLength = 40;
footHeight1 = 20;
footHeight2 = 5;
footWidth1 = 20;
footWidth2 = 10;
footTolerance = 0.07;
footChamfer = 3;

diffuserThickness = 2.73;
lightThickness = 11.5;
lightHolderHeight = 30;
lightSpacing = 8;
lightTolerance = 0.30;
lightFootLength = 50;
lightChamfer = 1.5;
//</params>

module dummy() {}
legHeight = riser;
nudge = 0.001;

module basicFoot(length1,length2,height) {
    footLength1 = max(length1,length2);
    footLength2 = min(length1,length2);
        hull() {
            translate([-footWidth2/2,-length1/2]) cube([footWidth2,length1,height]);
            translate([-footWidth1/2,-length2/2,0]) cube([footWidth1,length2,footHeight1]);
        }
}

module foot() {
    footIncut = 2 * thickness + footTolerance;
    incut = [[0,-footChamfer],[1.5*footChamfer,0],
        [legMinimumWidth,0],[legMinimumWidth,footIncut],[1.5*footChamfer,footIncut],[0,footIncut+footChamfer]];
    difference() {
        basicFoot(footLength,footIncut+footChamfer*2,footHeight2);
        translate([-footWidth1/2-nudge,-footIncut/2,-nudge]) linear_extrude(height=footHeight1+2*nudge) polygon(incut);
    }
}

module pyramid(base,h) {
    function layer(delta,z) = [
    [-delta,-delta,z],
    [base[0]+delta,-delta,z],
    [base[0]+delta,base[1]+delta,z],
    [-delta,base[1]+delta,z] ];
    tubeMesh([layer(h,0),layer(0,h)]);
}

module topReverseChamferedCube(size,chamfer) {
    function layer(delta,z) = [
    [-delta,-delta,z],
    [size[0]+delta,-delta,z],
    [size[0]+delta,size[1]+delta,z],
    [-delta,size[1]+delta,z] ];
    layers = [layer(0,0),layer(0,size[2]-chamfer),layer(chamfer,size[2])];
    tubeMesh(layers);
}
module side(film,back) {
    frame = [film[1][0]+frameMargin*2,film[1][1]+frameMargin*2];
    filmWidth = film[0] + 2 * filmTolerance;
    filmWidthPlus = film[0] + 2 * filmTolerance + 2 * plasticTolerance;
    w = max(frame[0] + 2*margin + 2*horizontalMargin,legSpacing+2*legMinimumWidth);
    h = baseHeight + frameCenterFromBase + frame[1]/2 + margin + verticalMargin;
    
    module profile() {
        difference() {
            square([w,h]);
            translate([w/2-legSpacing/2,0]) square([legSpacing,legHeight]);
            translate([w/2,baseHeight+frameCenterFromBase]) square(frame,center=true);
        }
    }
    
    insetMinus = inset-thicknessTolerance/2;
    insetPlus = inset+thicknessTolerance/2;
    
    if(back) {
        difference() {
            linear_extrude(height=thickness) profile();
            translate([-nudge,baseHeight+frameCenterFromBase-filmWidthPlus/2,thickness-insetPlus]) cube([w+2*nudge,filmWidthPlus,insetPlus+nudge]);
            translate([w/2-frame[0]/2,baseHeight+frameCenterFromBase-frame[1]/2,-nudge]) pyramid(frame,thickness-insetPlus-minimumThickness);
        }
    }
    else {
        difference() {
            union() {
                linear_extrude(height=thickness) profile();
                linear_extrude(height=thickness+insetMinus) intersection() {
                    profile();
                    translate([-nudge,baseHeight+frameCenterFromBase-filmWidth/2]) square([w+2*nudge,filmWidth]);
                }
            }
            translate([w/2-frame[0]/2,baseHeight+frameCenterFromBase-frame[1]/2,-nudge]) pyramid(frame,thickness+insetMinus-minimumThickness);
        }
    }
}

module light() {
    lightThickness1 = lightThickness + lightTolerance;
    diffuserThickness1 = diffuserThickness + lightTolerance;
    middle = diffuserThickness1 + lightThickness1 + lightSpacing;
    
    difference() {
        basicFoot(middle+2*lightChamfer,lightFootLength,lightHolderHeight+riser);
        translate([-footWidth1/2-nudge,-middle/2,riser]) topReverseChamferedCube([footWidth1+2*nudge,diffuserThickness1,lightHolderHeight+nudge],lightChamfer);
        translate([-footWidth1/2-nudge,-middle/2+diffuserThickness1+lightSpacing,riser]) topReverseChamferedCube([footWidth1+2*nudge,lightThickness1,lightHolderHeight+nudge],lightChamfer);
    }
}

if (doFoot) 
    foot();
else if (doLight) 
    light();
else side(do120?film120:film135,back=doBack);
