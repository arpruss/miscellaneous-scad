use <mapHershey.scad>;
use <eval.scad>;


fontSize = 5;
mapHershey("My line of text",f="[50*cos(360*u/(2*PI*50)),50*sin(360*u/(2*PI*50)),v]",font="timesr",halign="left",valign="baseline",size=10) { cylinder(d=1,h=1); }
