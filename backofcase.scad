width = 82;
height = 128;
edge = 5.4;
leftExtra = 1;
toButtonLeft = 70.5;
toButtonRight = 66;
afterButtonRight = 99;
toCamera = 90;
rightOfCamera = 43;
standHeight = 46;
standWidth = 13;
standFromBottom = 6.6;
standFromRight = 14.5;

difference() {
    union() {
    translate([-leftExtra,0]) square([leftExtra+edge+1,toButtonLeft]);
    square([width,toButtonRight]);
    translate([edge,0]) square([width-2*edge,toCamera]);
    translate([width-rightOfCamera,0]) square([rightOfCamera-edge,height]);
    translate([width-rightOfCamera,afterButtonRight]) square([rightOfCamera,height-afterButtonRight]);
    }
    translate([width-standFromRight-standWidth,standFromBottom]) square([standWidth,standHeight]);
   
}