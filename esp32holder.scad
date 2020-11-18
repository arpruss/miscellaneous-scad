pcbThicknessRear = 2.3;
pcbThickness = 1.47;
pcbWidth = 25.45;
pcbLength = 48.09;
rearSnapWidth = 12;
frontSnapWidth = 3;
frontSnapSpacing = 12;
sideSnapWidth = 8;
sideSnapSpacing = 12;
sideTolerance = 0.1;
thicknessTolerance = -0.1;
snapThickness = 2;
sideInset = 0.5;
frontInset = 0.75;
rearInset = 1.5;
baseThickness = 2;
snapSupportWidth = 2;
snapSupportHeight = 18;
snapSupportDepth = 4;

snapHeight = 20;

module dummy() {}

pcbWidth1 = pcbWidth + 2*sideTolerance;
pcbLength1 = pcbLength + 2*sideTolerance;
pcbThickness1 = pcbThickness + thicknessTolerance;
pcbThicknessRear1 = pcbThicknessRear + thicknessTolerance;

module snap(thickness=snapThickness,inset=2,height=snapHeight,pcbThickness=pcbThickness1,width=8,support=false) {
    translate([0,-snapThickness,0])
    rotate([0,0,90])
    translate([0,width/2,0])
    rotate([90,0,0]) {
    linear_extrude(height=width) 
        polygon([[0,0],[thickness,0],[thickness,height-inset],[thickness+inset,height],
    [thickness,height],
    [thickness,height+inset+pcbThickness],[thickness,height+inset+pcbThickness],[thickness+inset,height+inset+pcbThickness+inset],[thickness,height+inset+pcbThickness+inset+inset],[0,height+inset+pcbThickness+inset+inset]]);
        if (support) {
            translate([0,0,width/2-snapSupportWidth/2])
            linear_extrude(height=snapSupportWidth) polygon([[-snapSupportDepth,0],[thickness,0],[thickness,snapSupportHeight],[0,snapSupportHeight]]);
        }
    }
    
}

for (s=[-1,1]) translate([frontSnapSpacing/2*s,0,0]) snap(inset=frontInset,width=frontSnapWidth);
    
translate([0,pcbLength1,0])
rotate([0,0,180])
snap(inset=rearInset,width=rearSnapWidth,pcbThickness=pcbThicknessRear1,support=true);

for (s=[-1,1]) for(t=[-1,1]) translate([s*pcbWidth1/2,pcbLength1/2+t*sideSnapSpacing,0]) rotate([0,0,s*90]) snap(inset=sideInset,width=sideSnapWidth,support=true);
    
translate([-pcbWidth1/2-snapThickness,-snapThickness,0]) 
cube([pcbWidth1+2*snapThickness,pcbLength1+2*snapThickness,baseThickness]);