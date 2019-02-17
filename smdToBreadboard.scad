// must be even
numberOfPads = 8; 
padToPadAcrossChip = 5.27;
chipLength = 5;
pitch = 1.27;
breadboardPitch = 2.54;
breadboardSpacesAcross = 6;
baseThickness = 4;
margin = 4;
topThickness = 3;
snapMinimumThickness = 2;
snapInset = 1.5;
snapWidth = 8;
wireChannelDepth = 0.45; 
wireChannelWidth = 0.61;
wireThickness = 0.61;
tolerance = 0.25;

module dummy() {}

length = chipLength + 2*tolerance + 2*margin;
holeYSpacing = breadboardSpacesAcross * breadboardPitch;
width = holeYSpacing + 2*margin;
padsPerSide = numberOfPads / 2;
smdPin1X = length/2 - (padsPerSide-1)/2*pitch;
bbPin1X = length/2 - (padsPerSide-1)/2*breadboardPitch;

wireChannelWidth0 = wireChannelWidth + 2*tolerance;
nudge = 0.001;

module trace(smd,bb) {
    $fn = 36;
    translate([0,0,baseThickness-wireChannelDepth])
    hull() {
        translate(smd) cylinder(d=wireChannelWidth0,h=wireChannelDepth+nudge);
        translate(bb) cylinder(d=wireChannelWidth0,h=wireChannelDepth+nudge);        
    }
    translate([bb[0],bb[1],-nudge])
    cylinder(d=wireThickness+2*tolerance,h=baseThickness+2*nudge);
}

        


module base() {
    render(convexity=4)
    difference() {
        mirror([0,1,0])
        rotate([90,0,0])
        linear_extrude(height=width)
        polygon([[snapInset, 0], [length-snapInset, 0],
            [length, baseThickness], [0,baseThickness]]);
        for (side=[-1:2:1]) {
            smdPinY = width/2+side*padToPadAcrossChip/2+wireChannelWidth/2;
            bbPinY = width/2+side*holeYSpacing/2;
            for (i=[0:padsPerSide-1]) {
                trace([smdPin1X+i*pitch,smdPinY],[bbPin1X+i*breadboardPitch,bbPinY]);
            }
        }
    }
}

base();