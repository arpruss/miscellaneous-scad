s = 1;

linear_extrude(height=1.7) {
    text("Happy Birthday,", font="Times New Roman", size=s*15, halign="center", valign="bottom");
    text("Clare!", font="Times New Roman", size=s*15, halign="center", valign="top");
}
linear_extrude(height=0.4)
polygon(s*[[-70,0],[-70,20],[70,20],[70,0],[30,0],[30,-15],[-30,-15],[-30,0]]);