use <roundedSquare.scad>

//<params>
tolerance = 0.2; // increase if you want soft cloth inside
wallThickness = 2;
cameraHeight = 57; // only the part you want encased
cameraThickness = 29.84;
cameraWidthNoHinge = 123;
baseThickness = 2;
leftHingeWidth = 11;
leftHingeStickout = 2.9;
rightHingeWidth = 0;
hingeRounding = 2.5;
tripodHoleFromRight = 46.36;
tripodHoleFromBack = 14.70;
tripodHoleDiameter = 12;
releaseButtonFromRight = 95.72;
releaseButtonFromBack = 22.76;
releaseButtonDiameter = 10.4; 
releasePullHoleDiameter = 12.6;
releasePullFromRight = 68.39;
lensWidth = 64;
lensFromRight = 28.5;
lipBelowLens = 2;
strapWidth = 6.4;
strapHolderRodDiameter = 5;
strapHolderSideMinimum = 3;
strapHolderHorizontalRatio = 1.5;
strapHolderVerticalRatio = 1.3;
strapHolderDown = 4;
strapOffset = 7.5;
topRounding = 10;
//</params>

module dummy(){}

$fn = 128;
nudge = 0.005;

// alignment: (0,0) = (right,center) of camera

module basicProfile(inner) {
    delta = inner ? tolerance : tolerance+wallThickness;
    hull() {
        translate([-cameraThickness/2,0]) circle(d=cameraThickness+delta*2);
        translate([-(inner?cameraWidthNoHinge:(cameraWidthNoHinge+leftHingeStickout))+cameraThickness/2,0]) circle(d=cameraThickness+delta*2);
    }
    if (inner) translate([-cameraWidthNoHinge,0]) roundedSquare([2*(leftHingeStickout+delta),leftHingeWidth+2*delta],center=true,radius=hingeRounding);
}

module wallProfile() {
    difference() {
        basicProfile(inner=false);
        basicProfile(inner=true);
    }
}

module chamferedHole(d) {
    translate([0,0,-nudge]) {
    cylinder(d1=d+baseThickness*2,d2=d,h=baseThickness+2*nudge);
    cylinder(d=d,h=baseThickness+2*nudge+lipBelowLens);
    }
}

module walls() {
    linear_extrude(height=baseThickness+cameraHeight)
    difference() {
        wallProfile();
        translate([-lensFromRight-lensWidth/2,cameraThickness/2]) square([lensWidth,wallThickness*4],center=true);
    }
    linear_extrude(height=baseThickness+lipBelowLens) 
    difference() {
        wallProfile();
    }
}

module mainPositive() {
    walls();
    linear_extrude(height=baseThickness) basicProfile(inner=false);
}


module main() {
    difference() {
        mainPositive();
        translate([-releasePullFromRight,cameraThickness/2+tolerance+wallThickness,0]) chamferedHole(releasePullHoleDiameter);
        translate([-releaseButtonFromRight,-cameraThickness/2+releaseButtonFromBack,0]) chamferedHole(releaseButtonDiameter);
        translate([-tripodHoleFromRight,-cameraThickness/2+tripodHoleFromBack,-nudge]) cylinder(d=tripodHoleDiameter,h=baseThickness+2*nudge);
        translate([-lensFromRight,0,0]) rounding();
        translate([-lensFromRight-lensWidth,0,0]) mirror([1,0,0]) rounding();
        }
    
    strapHolders();    
}

/*
strapWidth = 15;
strapHolderRodDiameter = 6;
strapHolderSideMinimum = 3;
strapHolderHorizontalRatio = 1.1;
strapHolderVerticalRatio = 1.3;
strapOffset = 3;
*/

module strapHolder() {
    cylinder(d=strapHolderRodDiameter,h=strapWidth+2*strapHolderSideMinimum,center=true);
    y0 = strapOffset + strapHolderRodDiameter/2 + cameraThickness/3;
    module edge() {
        hull() {
            cylinder(d=strapHolderRodDiameter+1.5,h=strapHolderSideMinimum);
            translate([-strapHolderRodDiameter/2,y0,0])
            cube([(y0+strapHolderRodDiameter)*strapHolderVerticalRatio,nudge,strapHolderSideMinimum*(1+(strapHolderHorizontalRatio-1)*y0/(strapOffset+strapHolderRodDiameter/2))]);
        }
    }
    translate([0,0,strapWidth/2]) edge();
    translate([0,0,-strapWidth/2]) mirror([0,0,1]) edge();
    
}

module rightStrapHolder() {
    translate([strapOffset+ strapHolderRodDiameter/2,0,baseThickness+cameraHeight-strapHolderRodDiameter/2-strapHolderDown]) rotate([0,90,0]) rotate([-90,0,0]) strapHolder();
}

module strapHolders() {
    difference() {
        union() {
            translate([wallThickness+tolerance,0,0]) rightStrapHolder();
            translate([-wallThickness-tolerance-cameraWidthNoHinge-leftHingeStickout,0,0]) mirror([1,0,0]) rightStrapHolder();
        }
        translate([0,0,baseThickness])
        linear_extrude(height=cameraHeight)
        basicProfile(inner=false);
    }
}

module rounding() {
    translate([topRounding-nudge,cameraThickness/2,cameraHeight+baseThickness-topRounding+nudge])
    rotate([0,0,180]) 
    rotate([90,0,0]) 
    linear_extrude(height=(wallThickness+tolerance)*2,center=true)
    intersection() {
        square(3*topRounding);
        difference() {
            square(3*topRounding);
            circle(d=2*topRounding);
        }
    }
}

main();

