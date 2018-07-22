use <maphershey.scad>;

mapHershey("Hello World!", f="let(angle=-u*180/(PI*r),r1=r+v) [r1*cos(angle),r1*sin(angle),0]", size=10, extraParameters=[["r",20]]) cylinder(d=1,h=5);
