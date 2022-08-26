// Spur Gears
// Catarina Mota
// catarinamfmota@gmail.com
// 20091122


//GEAR PARAMETERS
gearHeight=5; //gear depth

pitchDiam=45; //pitch diameter

shaftDiam=5; //shaft diameter

//TEETH PARAMETERS
teethNum=30; //number of teeth (int)

addendum=2;

dedendum=2;

toothWidth=2;

//involute gear (work in progress)
involute=0; //int: 0=no, 1=yes
pressAngle=5; //pressure angle

//CENTER SHAPE PARAMETERS
centerShape=1; //int: solid=1, star=2, circle=3

starNum=6; //number of lines for star shape (int)
starWidth=2; //width of star lines

circleNum=7; //number of circles (int)
circleDiam=7; //diameter of circles

//CENTER CIRCLE PARAMETERS
extrudeOut=1; //int: 0=no, 1=yes
extrudeOutHeight=5;
extrudeOutWidth=5; //in relationship to shaft

extrudeIn=0; //int: 0=no, 1=yes
extrudeInDiam=pitchDiam/2-dedendum*2;
extrudeInHeight=2.5;

//ROME (extrudeIn must be set to 0)
rome=1; //int: 0=no, 1=yes
romeDiam=pitchDiam/2; //pitch diameter for top gear
romeHeight=gearHeight; //top gear height
romeTeeth=romeDiam*2/3;
romeAdd=2; //top gear addendum
romeDed=2; //top gear dedendum
romeToothWidth=2; //teeth width for top gear
romeAngle=5; //rotate top gear (angle)

//----------------------

gear();

//----------------------

//TOOTH
module tooth(heightGear, diamPitch) {

	toothHeight=addendum+dedendum*2;

	if (involute == 1) {
		translate([0,toothHeight/2,0]) involute(heightGear, toothHeight);
	}

	if (involute == 0) {
		translate([0,toothHeight/2,0]) box(toothWidth,toothHeight,heightGear);
	}

}

//INVOLUTE
module involute(heightGear, toothHeight) {

	difference() {
		box(toothWidth,toothHeight,heightGear);
		translate([toothWidth/2,-toothHeight/2+dedendum*2,0]) {
			rotate([0,0,pressAngle]) dislocateBoxRight(toothWidth, toothHeight, heightGear);
		}
		translate([-toothWidth/2,-toothHeight/2+dedendum*2,0]) {
			rotate([0,0,-pressAngle]) dislocateBoxLeft(toothWidth, toothHeight, heightGear);
		}
	}
}

//SPUR
module spur(numTeeth, diamPitch, heightGear) {
	rootRad=diamPitch/2-dedendum;
	for (i = [1:numTeeth]) {
		translate([sin(360*i/numTeeth)*(rootRad-dedendum), cos(360*i/numTeeth)*(rootRad-dedendum), 0 ]){
			rotate([0,0,-360*i/numTeeth]) tooth(heightGear, diamPitch);
		}
	}
}


//SOLID
module solid(heightGear, diamPitch) {
	rootRad=diamPitch/2-dedendum;
	cylinder(heightGear, rootRad, rootRad);
}

//STAR
module star() {
	starAngle=360/starNum;
	union(){
		for (s=[1:starNum]){
			translate([0,0,gearHeight/2]){
				rotate([0, 0, s*starAngle]) dislocateBox(starWidth, (pitchDiam/2-dedendum*2)/2, gearHeight);
			}
		}
		tube(gearHeight, pitchDiam/2-dedendum, starWidth);
		tube(gearHeight, pitchDiam/4+dedendum, starWidth);
		//cylinder(gearHeight, pitchDiam/4+dedendum, pitchDiam/4+dedendum);
		cylinder(gearHeight, shaftDiam/2+starWidth, shaftDiam/2+starWidth);
	}
}

//CIRCLE
module circle() {
	rootRad=pitchDiam/2-dedendum;
	difference(){
		solid(gearHeight, pitchDiam);
		for (c=[1:circleNum]){
			translate([sin(360*c/circleNum)*(rootRad/2+shaftDiam/2), cos(360*c/circleNum)*(rootRad/2+shaftDiam/2), 0]){
				cylinder(gearHeight, circleDiam/2, circleDiam/2);
			}
		}
	}
}

//ROME
module romeGear(){
	translate([0,0,romeHeight/2+gearHeight]){
		rotate([0,0,romeAngle]){
			union(){
				spur(romeTeeth, romeDiam, romeHeight);
				translate ([0,0,-romeHeight/2]) solid(romeHeight, romeDiam);
			}
		}
	}
}

//GEAR
module gear(){

	difference () {

		union() {
			translate([0,0,gearHeight/2]) spur(teethNum, pitchDiam, gearHeight);

			if (centerShape==1) solid(gearHeight, pitchDiam);

			if (centerShape==2) star();

			if (centerShape==3) circle();

			//extrudeOut around shaft
			if (extrudeOut==1) {
				cylinder(gearHeight-(extrudeInHeight*extrudeIn)+extrudeOutHeight+romeHeight*rome, extrudeOutWidth/2+shaftDiam/2, extrudeOutWidth/2+shaftDiam/2);
			}

			if (rome==1){
				romeGear();
			}

		}

	//extrudeIn around shaft
		if (extrudeIn==1) {
			difference(){
				translate([0,0,gearHeight-extrudeInHeight]) cylinder(extrudeInHeight, extrudeInDiam, extrudeInDiam);
				cylinder(gearHeight+extrudeOutHeight, (extrudeOutWidth+shaftDiam)/2*extrudeOut, (extrudeOutWidth+shaftDiam)/2*extrudeOut);
			}
		}

	//shaft
	cylinder(gearHeight+extrudeOutHeight+romeHeight, shaftDiam/2, shaftDiam/2);
	}
}

//----------------------
 
//SILLY WAY TO GET AROUND ROTATION AXIS

module dislocateBox(xBox, yBox, zBox){
	translate([0,yBox,0]){
		difference(){
			box(xBox, yBox*2, zBox);
			translate([-xBox,0,0]) box(xBox, yBox*2, zBox);
		}
	}
}

module dislocateBoxRight(xBox, yBox, zBox){
	translate([xBox/2,yBox,0]){
		difference(){
			translate([0,-yBox/2,0]) box(xBox, yBox, zBox);
			translate([-xBox,-yBox/2,0]) box(xBox, yBox, zBox);
		}
	}
}

module dislocateBoxLeft(xBox, yBox, zBox){
	translate([xBox/2,yBox,0]){
		difference(){
			translate([-xBox,-yBox/2,0]) box(xBox, yBox, zBox);
			translate([0,-yBox/2,0]) box(xBox, yBox, zBox);
		}
	}
}

//----------------------

module box(xBox, yBox, zBox) {
	scale ([xBox, yBox, zBox]) cube(1, true);
}

module cone(height, radius) {
		cylinder(height, radius, 0);
}

module oval(xOval, yOval, zOval) {
	scale ([xOval/100, yOval/100, 1]) cylinder(zOval, 50, 50);
}

module tube(height, radius, wall) {
	difference(){
		cylinder(height, radius, radius);
		cylinder(height, radius-wall, radius-wall);
	}
}

module hexagon(height, depth) {
	boxWidth=height/1.75;
		union(){
			box(boxWidth, height, depth);
			rotate([0,0,60]) box(boxWidth, height, depth);
			rotate([0,0,-60]) box(boxWidth, height, depth);
		}
}

module octagon(height, depth) {
	intersection(){
		box(height, height, depth);
		rotate([0,0,45]) box(height, height, depth);
	}
}

module dodecagon(height, depth) {
	intersection(){
		hexagon(height, depth);
		rotate([0,0,90]) hexagon(height, depth);
	}
}

module hexagram(height, depth) {
	boxWidth=height/1.75;
	intersection(){
		box(height, boxWidth, depth);
		rotate([0,0,60]) box(height, boxWidth, depth);
	}
	intersection(){
		box(height, boxWidth, depth);
		rotate([0,0,-60]) box(height, boxWidth, depth);
	}
	intersection(){
		rotate([0,0,60]) box(height, boxWidth, depth);
		rotate([0,0,-60]) box(height, boxWidth, depth);
	}
}

module rightTriangle(adjacent, opposite, depth) {
	difference(){
		translate([-adjacent/2,opposite/2,0]) box(adjacent, opposite, depth);
		translate([-adjacent,0,0]){
			rotate([0,0,atan(opposite/adjacent)]) dislocateBox(adjacent*2, opposite, depth);
		}
	}
}

module equiTriangle(side, depth) {
	difference(){
		translate([-side/2,side/2,0]) box(side, side, depth);
		rotate([0,0,30]) dislocateBox(side*2, side, depth);
		translate([-side,0,0]){
			rotate([0,0,60]) dislocateBox(side*2, side, depth);
		}
	}
}

module 12ptStar(height, depth) {
	starNum=3;
	starAngle=360/starNum;
	for (s=[1:starNum]){
		rotate([0, 0, s*starAngle]) box(height, height, depth);
	}
}
