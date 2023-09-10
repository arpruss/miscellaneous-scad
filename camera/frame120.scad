centerFromBase = 41;
cameraRiser = 20;

frame35 = [36,24];
frame120 = [58,58];
margin = 2;
horizontalMargin = 18;
verticalMargin = 20;
legHeight = 20;
legSpacing = 89.2;
legMinimumWidth = 15;

module side(frame) {
    w = max(frame[0] + 2*margin + 2*horizontalMargin,legSpacing+2*legMinimumWidth);
    h = cameraRiser + centerFromBase + frame[1]/2 + margin + verticalMargin;
    difference() {
        square([w,h]);
        translate([w/2-legSpacing/2,0]) square([legSpacing,legHeight]);
        translate([w/2-frame[0]/2-margin,cameraRiser + centerFromBase-frame[1]/2-margin]) square([frame[0]+2*margin,frame[1]+2*margin]);
    }
}

side(frame120);