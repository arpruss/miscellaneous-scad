include <pixellyfont.scad>;

//<params>
dots = false;
line1 = "Happy Birthday,";
line2 = "Name!";
size = 15;
letterHeight = 2;
backgroundHeight = 0.4;
equalizeWidth = false;
font = 14; // [0:6pt,1:6ptmono,2:7pt,3:8x8,4:9pt,5:9ptbold,6:10pt,7:10ptbold,8:architectlg,9:architectsm,10:bigfoot,11:casual,12:casualbold,13:macfont,14:mactall,15:metrix7pt,16:nicefont,17:nicefontbold,18:palmboldeu,19:palmnormeu,20:pda,21:pdabold,22:script,23:squat8pt,24:squat11pt,25:squatcaps8pt,26:tallfont,27:thin9pt,28:thin11pt]
//</params>

fontData = pixelly_fonts[font];

_len1 = getStringWidth(line1,font=fontData,size=size);
_len2 = getStringWidth(line2,font=fontData,size=size);

len1 = equalizeWidth ? max(_len1,_len2) : _len1;
len2 = equalizeWidth ? max(_len1,_len2) : _len2;

translate([-len1/2-1,-1,0]) cube([len1+2,size+2,backgroundHeight]);
    translate([-len2/2-1,-size+1,0]) 
    cube([len2+1,size+2,backgroundHeight]);

if (!dots) {
    color("blue")
    renderString(line1,halign="center",valign="bottom",font=fontData,size=size,pixelScale=1.01,height=letterHeight);
    color("blue")
    translate([0,-size]) 
renderString(line2,halign="center",valign="bottom",font=fontData,pixelScale=1.01,size=size,height=letterHeight);
}
else {
    renderString(line1,halign="center",valign="bottom",font=font_mactall,size=size)
        color("blue") translate([0,0,letterHeight/2]) cylinder(d=.9*size/getFontHeight(font_mactall), h=letterHeight, $fn=12, center=true);
        translate([0,-size]) 
renderString(line2,halign="center",valign="bottom",font=font_mactall,size=size)
        color("blue") translate([0,0,letterHeight/2]) cylinder(d=.9*size/getFontHeight(font_mactall), h=letterHeight, $fn=12, center=true);
}
