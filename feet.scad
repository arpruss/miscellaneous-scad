footLength = 25;
connectDiameter = 19.75;
standDiameter = 12;
connectorLength = 60;

foot = 0;

$fn = 96;

if (foot) {
    cylinder(d1=connectDiameter,d2=standDiameter,h=footLength);
}
else {
    cylinder(d=connectDiameter,h=connectorLength);
}