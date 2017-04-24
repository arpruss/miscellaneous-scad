// based on work of janssen86
// http://www.thingiverse.com/thing:2072364
// Zahnstange mit Ritzel / Gear Rack and Pinion by janssen86 is licensed under the Creative Commons - Attribution - Non-Commercial - Share Alike license.
// https://creativecommons.org/licenses/by-nc-sa/3.0/

// Fake gears draw a solid rectangular prism and cylinder with axial hole, up to the pitch level, for ease of layout.
$fakeGears = false; 
herringbone = 1; // [1:yes, 0:no]
materialSavingInset = 0;
removeCircles = 1; // [1:yes, 0:no]
// Kopfspiel (pinion play)
spiel = 0.05;
// Höhe des Zahnkopfes über dem Teilkreis (height of the tooth above the pitch line)
modul=1;
// Laenge der Zahnstange
laenge_stange=50;
// Anzahl der Radzähne (number of pinion teeth)
zahnzahl_ritzel=15;
// Höhe der Zahnstange bis zur Wälzgeraden (height from bottom to the pitch line)
hoehe_stange=4; 
// Durchmesser der Mittelbohrung des Stirnrads (axial hole diameter)
bohrung_ritzel=4;
// Breite der Zähne (face width)
breite=7;
// Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
eingriffswinkel=20;
// Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung)
schraegungswinkel=20;
// Komponenten zusammengebaut für Konstruktion oder auseinander zum 3D-Druck 
zusammen_gebaut=0;
// Löcher zur Material-/Gewichtsersparnis bzw. Oberflächenvergößerung erzeugen, wenn Geometrie erlaubt
optimiert = 1;

/* Bibliothek für ein Zahstangen-Radpaar für Thingiverse Customizer

Enthält die Module
zahnstange(modul, laenge, hoehe, breite, eingriffswinkel = 20, schraegungswinkel = 0)
stirnrad(modul, zahnzahl, breite, bohrung, eingriffswinkel = 20, schraegungswinkel = 0, optimiert = true)
zahnstange_und_ritzel (modul, laenge_stange, zahnzahl_ritzel, hoehe_stange, bohrung_ritzel, breite, eingriffswinkel=20, schraegungswinkel=0, zusammen_gebaut=true, optimiert=true)

Autor:		Dr Jörg Janssen
Stand:		6. Januar 2017
Version:	2.0
Lizenz:		Creative Commons - Attribution, Non Commercial, Share Alike

Erlaubte Module nach DIN 780:
0.05 0.06 0.08 0.10 0.12 0.16
0.20 0.25 0.3  0.4  0.5  0.6
0.7  0.8  0.9  1    1.25 1.5
2    2.5  3    4    5    6
8    10   12   16   20   25
32   40   50   60

*/


/* [Hidden] */
pi = 3.14159;
rad = 57.29578;
$fn = 96;
nudge = 0.001;

/*	Wandelt Radian in Grad um */
function grad(eingriffswinkel) =  eingriffswinkel*rad;

/*	Wandelt Grad in Radian um */
function radian(eingriffswinkel) = eingriffswinkel/rad;

/*	Wandelt 2D-Polarkoordinaten in kartesische um
    Format: radius, phi; phi = Winkel zur x-Achse auf xy-Ebene */
function pol_zu_kart(polvect) = [
	polvect[0]*cos(polvect[1]),  
	polvect[0]*sin(polvect[1])
];

/*	Kreisevolventen-Funktion:
    Gibt die Polarkoordinaten einer Kreisevolvente aus
    r = Radius des Grundkreises
    rho = Abrollwinkel in Grad */
function ev(r,rho) = [
	r/cos(rho),
	grad(tan(rho)-radian(rho))
];

/*  Wandelt Kugelkoordinaten in kartesische um
    Format: radius, theta, phi; theta = Winkel zu z-Achse, phi = Winkel zur x-Achse auf xy-Ebene */
function kugel_zu_kart(vect) = [
	vect[0]*sin(vect[1])*cos(vect[2]),  
	vect[0]*sin(vect[1])*sin(vect[2]),
	vect[0]*cos(vect[1])
];

/*	prüft, ob eine Zahl gerade ist
	= 1, wenn ja
	= 0, wenn die Zahl nicht gerade ist */
function istgerade(zahl) =
	(zahl == floor(zahl/2)*2) ? 1 : 0;

/*	Kopiert und dreht einen Körper */
module kopiere(vect, zahl, abstand, winkel){
	for(i = [0:zahl-1]){
		translate(v=vect*abstand*i)
			rotate(a=i*winkel, v = [0,0,1])
				children(0);
	}
}


/*  Zahnstange
    modul = Höhe des Zahnkopfes über der Wälzgeraden
    laenge = Laenge der Zahnstange
    hoehe = Höhe der Zahnstange bis zur Wälzgeraden
    breite = Breite der Zähne
    eingriffswinkel = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    schraegungswinkel = Schrägungswinkel zur Zahnstangen-Querachse; 0° = Geradverzahnung */
module zahnstange(modul, laenge, hoehe, breite, eingriffswinkel = 20, schraegungswinkel = 0, $fakeGears=$fakeGears) {
    
    if ($fakeGears) {
        cube([laenge, hoehe, breite]);
    }
    else {
        // Dimensions-Berechnungen
        //modul=0.99;// modul*(1-spiel);
        c = modul / 6;												// Kopfspiel
        mx = modul/cos(schraegungswinkel);							// Durch Schrägungswinkel verzerrtes modul in x-Richtung
        a = 2*mx*tan(eingriffswinkel)+c*tan(eingriffswinkel);		// Flankenbreite
        b = pi*mx/2-2*mx*tan(eingriffswinkel);						// Kopfbreite
        x = breite*tan(schraegungswinkel);							// Verschiebung der Oberseite in x-Richtung durch Schrägungswinkel
        nz = ceil((laenge+abs(2*x))/(pi*mx));						// Anzahl der Zähne
        
        translate([-a-b/2/*-pi*mx*(floor(nz/2)-1)-a-b/2*/,hoehe-modul,0]){
            intersection(){
                kopiere([1,0,0], nz, pi*mx, 0){
                    render()
                    polyhedron(
                        points=[[0,-c,0], [a,2*modul,0], [a+b,2*modul,0], [2*a+b,-c,0], [pi*mx,-c,0], [pi*mx,modul-hoehe,0], [0,modul-hoehe,0],	// Unterseite
                            [0+x,-c,breite], [a+x,2*modul,breite], [a+b+x,2*modul,breite], [2*a+b+x,-c,breite], [pi*mx+x,-c,breite], [pi*mx+x,modul-hoehe,breite], [0+x,modul-hoehe,breite]],	// Oberseite
                        faces=[[6,5,4,3,2,1,0],						// Unterseite
                            [1,8,7,0],
                            [9,8,1,2],
                            [10,9,2,3],
                            [11,10,3,4],
                            [12,11,4,5],
                            [13,12,5,6],
                            [7,13,6,0],
                            [7,8,9,10,11,12,13],					// Oberseite
                        ]
                    );
                };
                translate([abs(x),-hoehe+modul-0.5,-0.5]){
                    cube([laenge,hoehe+modul+1,breite+1]);
                }	
            };
        };	
    }
}

function pinionPitchRadius(zahnzahl=zahnzahl_ritzel,modul=modul) = modul*zahnzahl_ritzel/2;

/*  Stirnrad
    modul = Höhe des Zahnkopfes über dem Teilkreis
    zahnzahl = Anzahl der Radzähne
    breite = Zahnbreite
    bohrung = Durchmesser der Mittelbohrung
    eingriffswinkel = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    schraegungswinkel = Schrägungswinkel zur Rotationsachse; 0° = Geradverzahnung
	optimiert = Löcher zur Material-/Gewichtsersparnis bzw. Oberflächenvergößerung erzeugen, wenn Geometrie erlaubt (= 1, wenn wahr) */
module stirnrad(modul, zahnzahl, breite, bohrung, eingriffswinkel = 20, schraegungswinkel = 0, optimiert = true, materialSavingInset = materialSavingInset, $fakeGears=$fakeGears) {
    
    if ($fakeGears) {
        difference() {
            cylinder(r=pinionPitchRadius(zahnzahl, modul), h=breite);
            translate([0,0,-nudge]) cylinder(r=bohrung/2, h=breite+2*nudge);
        }
    }
    else {
        // Dimensions-Berechnungen	
        d = modul * zahnzahl;											// Teilkreisdurchmesser
        r = d / 2;														// Teilkreisradius
        alpha_stirn = atan(tan(eingriffswinkel)/cos(schraegungswinkel));// Schrägungswinkel im Stirnschnitt
        db = d * cos(alpha_stirn);										// Grundkreisdurchmesser
        rb = db / 2;													// Grundkreisradius
        da = (modul <1)? d + modul * 2.2 : d + modul * 2;				// Kopfkreisdurchmesser nach DIN 58400 bzw. DIN 867
        ra = da / 2;													// Kopfkreisradius
        c =  (zahnzahl <3)? 0 : modul/6;								// Kopfspiel
        df = d - 2 * (modul + c);										// Fußkreisdurchmesser
        rf = df / 2;													// Fußkreisradius
        rho_ra = acos(rb/ra);											// maximaler Abrollwinkel;
                                                                        // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
        rho_r = acos(rb/r);												// Abrollwinkel am Teilkreis;
                                                                        // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
        phi_r = grad(tan(rho_r)-radian(rho_r));							// Winkel zum Punkt der Evolvente auf Teilkreis
        gamma = rad*breite/(r*tan(90-schraegungswinkel));				// Torsionswinkel für Extrusion
        schritt = rho_ra/16;											// Evolvente wird in 16 Stücke geteilt
        tau = 360/zahnzahl;												// Teilungswinkel
        
        r_loch = (2*rf - bohrung)/8;									// Radius der Löcher für Material-/Gewichtsersparnis
        rm = bohrung/2+2*r_loch;										// Abstand der Achsen der Löcher von der Hauptachse
        z_loch = floor(2*pi*rm/(3*r_loch));								// Anzahl der Löcher für Material-/Gewichtsersparnis
        
        optimiert = (optimiert && r >= breite*1.5 && d > 2*bohrung);	// ist Optimierung sinnvoll?

        // Zeichnung
        union(){
            rotate([0,0,-phi_r-90*(1-spiel)/zahnzahl]){						// Zahn auf x-Achse zentrieren;
                                                                            // macht Ausrichtung mit anderen Rädern einfacher

                linear_extrude(height = breite, twist = gamma){
                    difference(){
                        union(){
                            zahnbreite = (180*(1-spiel))/zahnzahl+2*phi_r;
                            circle(rf);										// Fußkreis	
                            for (rot = [0:tau:360]){
                                rotate (rot){								// "Zahnzahl-mal" kopieren und drehen
                                    polygon(concat(							// Zahn
                                        [[0,0]],							// Zahnsegment beginnt und endet im Ursprung
                                        [for (rho = [0:schritt:rho_ra])		// von null Grad (Grundkreis)
                                                                            // bis maximalen Evolventenwinkel (Kopfkreis)
                                            pol_zu_kart(ev(rb,rho))],		// Erste Evolventen-Flanke

                                        [pol_zu_kart(ev(rb,rho_ra))],		// Punkt der Evolvente auf Kopfkreis

                                        [for (rho = [rho_ra:-schritt:0])	// von maximalen Evolventenwinkel (Kopfkreis)
                                                                            // bis null Grad (Grundkreis)
                                            pol_zu_kart([ev(rb,rho)[0], zahnbreite-ev(rb,rho)[1]])]
                                                                            // Zweite Evolventen-Flanke
                                                                            // (180*(1-spiel)) statt 180 Grad,
                                                                            // um Spiel an den Flanken zu erlauben
                                        )
                                    );
                                }
                            }
                        }			
                        circle(r = rm+r_loch*1.49);							// "Bohrung"
                    }
                }
            }
            // mit Materialersparnis
            if (optimiert) {
                linear_extrude(height = breite){
                    difference(){
                            circle(r = (bohrung+r_loch)/2);
                            circle(r = bohrung/2);							// Bohrung
                        }
                    }
                linear_extrude(height = breite-materialSavingInset){
                    difference(){
                        circle(r=rm+r_loch*1.51);
                        union(){
                            circle(r=materialSavingInset< 0 ? bohrung/2 : (bohrung+r_loch)/2);
                            if (removeCircles)
                                for (i = [0:1:z_loch]){
                                    translate(kugel_zu_kart([rm,90,i*360/z_loch]))
                                        circle(r = r_loch);
                                }
                        }
                    }
                }
            }
            // ohne Materialersparnis
            else {
                linear_extrude(height = breite){
                    difference(){
                        circle(r = rm+r_loch*1.51);
                        circle(r = bohrung/2);
                    }
                }
            }
        }
    }
}

/*	Zahnstange und Ritzel
    modul = Höhe des Zahnkopfes über dem Teilkreis
    laenge_stange = Laenge der Zahnstange
    zahnzahl_ritzel = Anzahl der Radzähne am Ritzel
	hoehe_stange = Höhe der Zahnstange bis zur Wälzgeraden
    bohrung_ritzel = Durchmesser der Mittelbohrung des Ritzels
	breite = Breite der Zähne
    eingriffswinkel = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    schraegungswinkel = Schrägungswinkel, Standardwert = 0° (Geradverzahnung)
	optimiert = Löcher zur Material-/Gewichtsersparnis bzw. Oberflächenvergößerung erzeugen, wenn Geometrie erlaubt (= 1, wenn wahr) */
module zahnstange_und_rad (modul, laenge_stange, zahnzahl_ritzel, hoehe_stange, bohrung_ritzel, breite, eingriffswinkel=20, schraegungswinkel=0, zusammen_gebaut=true, optimiert=true, $fakeGears=$fakeGears) {

	abstand = zusammen_gebaut? modul*zahnzahl_ritzel/2 : modul*zahnzahl_ritzel;
	
    zahnstange(modul, laenge_stange, hoehe_stange, breite, eingriffswinkel, -schraegungswinkel, $fakeGears=$fakeGears);
	translate([0,abstand,0])
    if (istgerade(zahnzahl_ritzel)) {
        rotate(90 + 180/zahnzahl_ritzel)
            stirnrad (modul, zahnzahl_ritzel, breite, bohrung_ritzel, eingriffswinkel, schraegungswinkel, optimiert, $fakeGears=$fakeGears);
    }
    else {
        rotate(a=90) 
            stirnrad (modul, zahnzahl_ritzel, breite, bohrung_ritzel, eingriffswinkel, schraegungswinkel, optimiert, $fakeGears=$fakeGears);
    }
}

module doherringbone(herringbone=herringbone, faceWidth=breite) {
    if (herringbone) {
        translate([0,0,faceWidth/2])
            union() {
                translate([0,0,-nudge]) scale([1,1,1+nudge/(faceWidth/2)]) children();
                translate([0,0,nudge]) mirror([0,0,-1]) scale([1,1,1+nudge/(faceWidth/2)]) children();
            }
        }
    else {
        children();
    }
}

module rack(faceWidth=breite, herringbone=herringbone, $fakeGears=$fakeGears, length=laenge_stange, toothHeightAbovePitch=modul) {
    doherringbone(herringbone=herringbone, faceWidth=faceWidth) 
        render(convexity=2)
        zahnstange(toothHeightAbovePitch, length, hoehe_stange, herringbone?faceWidth/2:faceWidth, eingriffswinkel, -schraegungswinkel, $fakeGears=$fakeGears);
}

// By default in herringbone mode, this is flipped.
// The reason for that is it makes for a more
// symmetric fit when printed with the first layer
// smooshed against the print bed.
module pinion(faceWidth=breite, herringbone=herringbone, flipherringbone=true, $fakeGears=$fakeGears, toothCount=zahnzahl_ritzel, toothHeightAbovePitch=modul, holeDiameter=bohrung_ritzel) {
    module basePinion() {
        translate([0,0,materialSavingInset<0?-materialSavingInset:0])
        doherringbone(herringbone=herringbone, faceWidth=faceWidth)
            if (istgerade(toothCount)) {
                rotate(90 + 180/toothCount)
                    stirnrad (toothHeightAbovePitch, toothCount, herringbone?faceWidth/2:faceWidth, holeDiameter, eingriffswinkel, schraegungswinkel, optimiert, $fakeGears=$fakeGears);
            }
            else {
                rotate(a=90) 
                    stirnrad (toothHeightAbovePitch, toothCount, herringbone?faceWidth/2:faceWidth, holeDiameter, eingriffswinkel, schraegungswinkel, optimiert, $fakeGears=$fakeGears);
            }
        }
        
    if (herringbone && flipherringbone)
        mirror(0,1,0) basePinion();
    else
        basePinion();
}

render(convexity=2) {
    rack(herringbone=true, $fakeGears=$fakeGears);
    translate([laenge_stange/2,20,0]) 
        pinion(herringbone=true, $fakeGears=$fakeGears);
}

//zahnstange_und_rad (modul, laenge_stange, zahnzahl_ritzel, hoehe_stange, bohrung_ritzel, breite, eingriffswinkel, schraegungswinkel, zusammen_gebaut, optimiert);
