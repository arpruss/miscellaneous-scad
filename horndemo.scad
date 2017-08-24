use <horn.scad>;

//<params>
length = 100;
throatWidth = 45;
throatHeight = 40;
mouthWidth = 120;
mouthHeight = 60;
wallThickness = 1.4;
numSections = 20;
flangeLength = 4;
flangeFlare = 3;
rectangular = 1; // [1:yes, 0:no]
//</params>

horn(length=length, throat=[throatWidth,throatHeight], mouth=[mouthWidth,mouthHeight], wallThickness=wallThickness, numSections=numSections, flangeLength=flangeLength, flangeFlare=flangeFlare, rectangular=rectangular);
