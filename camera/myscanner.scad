centerFromBase = 41;
cameraRiser = 20;

frame135 = [35,[36,24]];
frame120 = [61.7,[58,58]];
margin = 2;
markerSize = 8;
horizontalMargin = 18;
verticalMargin = 20;
legSpacing = 90;
legMinimumWidth = 15;


legHeight = cameraRiser;
module side(frame) {
    w = max(frame[0] + 2*margin + 2*horizontalMargin,legSpacing+2*legMinimumWidth);
    h = cameraRiser + centerFromBase + frame[1]/2 + margin + verticalMargin;
    difference() {
        square([w,h]);
        translate([w/2-legSpacing/2,0]) square([legSpacing,legHeight]);
        translate([w/2,cameraRiser+centerFromBase]) square([frame[0]+2*margin,frame[1]+2*margin],center=true);
        delta = (w/2-frame[0]/2-margin)/2;
        for(y=[cameraRiser+centerFromBase-frame[1]/2,cameraRiser+centerFromBase+frame[1]/2]) for(x=[delta,w-delta]) translate([x,y]) rotate(45) square(markerSize,center=true);
    }
}

side(frame120);
