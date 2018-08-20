tolerance = 0.2;
innerWidth = 7.2+2*tolerance;
innerHeight = 8.6+2*tolerance;
length = 20;
innerWall = 1;
outerWall = 1.5;

difference() {
    cube([length, innerWidth+innerWall+outerWall, innerHeight+outerWall*2]);
    translate([-1,innerWall,outerWall]) cube([length+2, innerWidth, innerHeight]);   
}