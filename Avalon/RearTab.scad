use <SideTab.scad>;

//<params>
left = true;
tabWidth = 25;
tabThickness = 7;
vaneThickness = 4;
vaneTolerance = 0.2;
extraBehindVane = 3;
extraInFrontOfVane = 1.5;
vaneSnapSize = 1.1;
vaneDepth = 12;
maxFrontOfVaneToGear = 20;
minFrontOfVaneToGear = 18.45;
axleFromFrontOfVane = 2.6;
gearTolerance = 0.2;
toothSpacing = 3.3;
numberOfTeeth = 5; 
topToothHeight = 4.4;
bottomToothHeight = 4.4;
blockerLength = 1;
blockerChamfer = 1.75;
toothPositioning = 0.5;
outerChamfer = 3;
//</params>

sideTab(
 left=left,
 tabWidth=tabWidth,
 tabThickness=tabThickness,
 vaneThickness=vaneThickness,
 vaneTolerance=vaneTolerance,
 extraBehindVane=extraBehindVane,
 extraInFrontOfVane=extraInFrontOfVane,
 vaneSnapSize=vaneSnapSize,
 vaneDepth=vaneDepth,
 maxFrontOfVaneToGear=maxFrontOfVaneToGear,
 minFrontOfVaneToGear=minFrontOfVaneToGear,
 axleFromFrontOfVane=axleFromFrontOfVane,
 gearTolerance=gearTolerance,
 toothPositioning=toothPositioning,
 toothSpacing=toothSpacing,
 numberOfTeeth=numberOfTeeth,
 topToothHeight=topToothHeight,
 bottomToothHeight=bottomToothHeight,
 blockerLength=blockerLength,
 blockerChamfer=blockerChamfer,
 outerChamfer=outerChamfer
);