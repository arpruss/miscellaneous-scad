/* 
  
Atari 2600 Paddle Replacement Wheel by jtritell is licensed under the Creative Commons - Attribution - Share Alike license.
By downloading this thing, you agree to abide by the license: Creative Commons - Attribution - Share Alike

*/

LowestDiameter=44.5;
LowestRadius=LowestDiameter/2;
LowestHeight=3;
MiddleDiameter=46.5;
MiddleRadius=MiddleDiameter/2;
MiddleHeight=7;
TopDiameter1=47.5;
TopDiameter2=46.0;
TopRadius1=TopDiameter1/2;
TopRadius2=TopDiameter2/2;
TopHeight=13;
InnerDiameter=41.5;
InnerRadius=InnerDiameter/2;
CenterDiameter=12;
CenterRadius=CenterDiameter/2;
CenterDepth=6.19; // 0 for Atari
CenterInset = 2.6; // 0 for Atari
Flat=false; // true for Atari
CenterInnerRadius=3; // 3.7 for Atari (determines fit on potentiometer)
Divots=45;
FullHeight=LowestHeight+MiddleHeight+TopHeight;
$fn=64;

module full() {
    difference(){
    union(){
    cylinder(LowestHeight,LowestRadius,LowestRadius);
    translate([0,0,LowestHeight])
    cylinder(MiddleHeight,MiddleRadius,MiddleRadius);
    translate([0,0,LowestHeight+MiddleHeight])
    cylinder(TopHeight,TopRadius1,TopRadius2);
    }

    translate([0,0,LowestHeight+MiddleHeight])
    for(i=[0 :Divots-1]){
        rotate(i*360/Divots, [0, 0 , 1])
        translate([0, TopRadius2-1 ,0])
        cube([1,2,TopHeight+10]);}

    translate([0,0,-0.1])
    cylinder(LowestHeight+MiddleHeight+TopHeight-3,InnerRadius,InnerRadius);


    translate([0,0,FullHeight-1])
    difference(){
    cylinder(2,19,19);
    cylinder(2,18.25,18.25);
    }}


    translate([0,0,CenterInset])
    difference(){
    cylinder(h=FullHeight-CenterInset-1.1,r=CenterRadius);
    translate([0,0,-0.1])
    difference(){
    cylinder(CenterDepth==0 ? FullHeight-CenterInset-1.1 : CenterDepth,CenterInnerRadius,CenterInnerRadius+0.1);
    if(Flat)
    translate([-CenterRadius,CenterRadius-3.5,0])
    cube([CenterDiameter,CenterDiameter,FullHeight]);
    }}

    translate([0,0,0])
    for(i=[0:3])
        rotate([0,0,45])
        rotate(i*360/4, [0,0,1])
        translate([-1,CenterRadius-0.5,5])
        cube([2,InnerRadius-CenterRadius+0.6,FullHeight-6.1]);
}

translate([0,0,FullHeight])
rotate([180,0,0])
full();