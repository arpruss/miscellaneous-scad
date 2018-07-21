use <maphershey.scad>;

//<params>
radius = 50;
textSize = 10;
topLatitude = 75;
latitudeSpacing = 16;
stylusWidth = 0.75;
stylusThickness = 5;
includeSphere = 1; //[0:No,1:Yes]
font = 0; // [0:cursive, 1:futural, 2:futuram, 3:gothgbt, 4:gothgrt, 5:gothiceng, 6:gothicger, 7:gothicita, 8:gothitt, 9:rowmand, 10:rowmans, 11:rowmant, 12:scriptc, 13:scripts, 14:timesi, 15:timesib, 16:timesr, 17:timesrb]
text = "Arma virumque cano, Troiae qui primus ab oris / Italiam, fato profugus, Laviniaque venit / litora, multum ille et terris iactatus et alto / vi superum saevae memorem Iunonis ob iram; / multa quoque et bello passus, dum conderet urbem, / inferretque deos Latio, genus unde Latinum, / Albanique patres, atque altae moenia Romae.";
//</params>

fonts=["cursive","futural","futuram","gothgbt","gothgrt","gothiceng","gothicger","gothicita","gothitt","rowmand","rowmans","rowmant","scriptc","scripts","timesi","timesib","timesr","timesrb"];

module sphericalWrap(text,r=50,startLatitude=70,textHeight=10,latitudeSpacing=20,font="timesr") {
    angularHeight = 360 * textHeight / (2 * PI * r);
    topAngle = 90-startLatitude;
// cap of angle theta has area 2pi r(1-cos(theta))
// approximate spiral length from top = 2pi r(1-cps(theta)) / (pi latitudeSpacing/180) = 360 r(1-cos(theta)) / latitudeSpacing
// l = 360 r (1-cos(theta))/latitudeSpacing - 360 r (1-cos(topAngle))/latitudeSpacing
// 1-cos(theta) = latitudeSpacing * l / 360r + (1-cos(topAngle))
// theta = acos(1-latitudeSpacing * l / 360r - (1-cos(topAngle)))
// longitude = 360 * (theta-topAngle) / latitudeSpacing
    
    // params: ls,r,top,hs
    f = "let(theta=acos(1-ls*u/(360*r)-(1-cos(top))),long=360*(theta-top)/ls,theta1=theta-hs*v) r*[cos(long)*sin(theta1),sin(long)*sin(theta1),cos(theta1)]";
    extras = [["ls",latitudeSpacing],["top",topAngle],["r",r],["hs",180/(PI*r)]];
    mapHershey(text,f=f,font=font,size=textHeight,extraParameters=extras) cylinder(d=1,h=3,$fn=8);
}

//demo();
sphericalWrap(text, font=fonts[font], r=radius, startLatitude=topLatitude,latitudeSpacing=latitudeSpacing,textHeight=textSize)
cylinder(d=stylusWidth,h=stylusThickness,$fn=8);
if (includeSphere) sphere(r=radius+0.25,$fn=72);