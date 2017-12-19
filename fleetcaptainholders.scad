output = 1; // [0:round pieces, 1:other pieces]
cover = 0; // [0:no, 1:yes (only for non-solid)]

solidMode = 0; // [1:yes, 0:no]
testMode = 0; // [1:yes, 0:no]

wallThickness = 1.25;
horizontalTolerance = 0.7;
verticalExtra = 3;
diameterMultiplier = 1.4;
stickOutCircular = 2.2;
stickOutOther = 3;
baseVerticalOffset1 = 1.5;
baseVerticalOffset2 = 1.5;
coverTolerance = 0;
coverLooseTolerance = 1.2;
coverThinWall = 1;
coverWall = 1.25;
coverTopWall = 2;
coverExtraStickout = 3;

module dummy() {}

roundModifiers = output == 0;

nudge = 0.01;

function ngon(n,extra) = [ for (i=[0:n-1]) [cos(-90+i*360/n+extra),sin(-90+i*360/n+extra)] ];
function radiusBySide(n,s) = s/(2*sin(180/n));
function sum_(list,count) = (count <= 0 ? 0 : list[count-1] + sum_(list,count-1));
function sum(list) = sum_(list,len(list));
function d2(v1,v2) = sqrt((v1[0]-v2[0])*(v1[0]-v2[0])+(v1[1]-v2[1])*(v1[1]-v2[1]));
function diameter(points) = max( [for (i=[0:len(points)-1]) max([for (j=[0:len(points)-1]) d2(points[i],points[j])])]);
function horizontalDiameter(points) = max( [for (i=[0:len(points)-1]) max([for (j=[0:len(points)-1]) abs(points[i][0]-points[j][0])])]);
function shift(v,vv) = [for(i=[0:len(vv)-1]) v+vv[i]];

circleR = 19.4/2;

circlePoints = circleR * shift([0,1],ngon(20,0));

pi = 3.14159265;

// name1, name2, height, points, extra_diameter, extra_stickout
sensorsD_shieldsD = [ "D Sensors", "D Shields", 11.7,  circlePoints, 0, 0 ];
enginesD_weaponsD = [ "D Engines", "D Weapons", 11.7, circlePoints, 0, 0 ];
three_four = [ "+3", "+4", 6.72, circlePoints, 0, 0 ];
weapons_one = [ "-1 Weapons", "+1 Weapons", 11.7, circlePoints, 0, 0 ];
weapons_two = [ "-2 Weapons", "+2 Weapons", 11.7, circlePoints, 0, 0 ];
sensors1_engines1 = [ "+1 Sensors", "+1 Engines", 10.2, circlePoints, 0, 0 ];
shields = [ "+1 Shields", "+2 Shields", 11.7, circlePoints, 0, 0 ];
miscCircles = ["Misc.", "", 18.4, circlePoints, 0, 0 ];

circlePieces = [ sensorsD_shieldsD, enginesD_weaponsD, three_four, weapons_one, weapons_two, sensors1_engines1, shields, miscCircles ];

smallSquarePoints = radiusBySide(4,19.3)*shift([0,1],ngon(4,0));
vpPoints = [[0,0], [12, 23-14.5], [12, 23], [-12,23], [-12, 23-14.5]];
controlTokenDiameter = 28;
controlTokenPoints = (controlTokenDiameter/2)*shift([-.5,sin(60)],concat([for (i=[-60:20:60]) [cos(i),sin(i)]],[[0,0]]));

triangle_extra_stickOut = 3;

away_team = [ "Away Team", "",10.28,smallSquarePoints, -4.2, 2 ];
scan_df = [ "Scan Dominion", "Scan Federation", 20.3, radiusBySide(3,23.07)*shift([0,1],ngon(3,0)), -0.8, triangle_extra_stickOut ];
scan_kf = [ "Scan Klingon", "Scan Federation", 20.3, radiusBySide(3,23.07)*shift([0,1],ngon(3,0)), -0.8, triangle_extra_stickOut ];
action = [ "Action", "", 30.2, radiusBySide(4,25.6)*shift([0,1],ngon(4,0)), -3.8, 3 ];
colony_outpost = [ "Colony", "Outpost", 25.5, smallSquarePoints, -3, 2 ];
starbase = [ "Starbase", "", 17, smallSquarePoints, -3, 2 ];
cloak = [ "Cloak", "", 23.21, radiusBySide(5,14.83)*shift([0,1],ngon(5,0)), -4.2, 0 ];
vp_3_4 = [ "VP +3", "VP +4", 10.07, vpPoints, 2, 1 ];
vp_1_2 = [ "VP +1", "VP +2", 16.68, vpPoints, 1.8, 1 ];
control_fd = [ "Control Dominion", "Control Federation", 1.664*60/2, controlTokenPoints, -1.5, 0 ]; // old:24
control_fk = [ "Control Klingon", "Control Federation", 1.664*60/2, controlTokenPoints, -0.6, 0 ];
control_fk2 = [ "Control Klingon", "Control Federation", 1.664*60/2, controlTokenPoints, -1.2, 0 ];

otherPieces = [ away_team, scan_df, scan_kf, action, colony_outpost, starbase, cloak, vp_3_4, vp_1_2, control_fd, control_fk, control_fk2 ];

module holeProfile(points) {
    minkowski() {
        polygon(points);
        circle(r=horizontalTolerance,$fn=8);
    }
}

function sum2d(list,n=0,soFar=[0,0]) = 
    n == len(list) ? soFar :
    sum2d(list,n=n+1,soFar=soFar+list[n]);
function center2d(list) =
    sum2d(list) / len(list);

module circularHolder(pieces,stickOut,equalize=false) {
    n = len(pieces);
    
    diameters = [for (i=[0:n-1]) pieces[i][4]+horizontalDiameter(pieces[i][3])];
    scaledDiameters = diameterMultiplier*shift(horizontalTolerance*(solidMode?2:1), diameters);
    circumference = sum(scaledDiameters,n);
    maxHeight = max([for (i=[0:n-1]) pieces[i][2]]);
    heights = equalize ? [for (i=[0:n-1]) maxHeight] : [for (i=[0:n-1]) pieces[i][2]];
    minHeight = min(heights);
    r = circumference / (2*pi);
    radii = [for (i=[0:n-1]) r+stickOut+pieces[i][5]];
    maxRadii = max(radii);
    minInset = min( [for (i=[0:n-1]) min([for (j=[0:len(pieces[i][3])-1]) radii[i]-pieces[i][3][j][1]])] ) - horizontalTolerance - wallThickness;
  
    
    baseVerticalOffset = baseVerticalOffset1 + baseVerticalOffset2;
    angles = [for(i=[0:n-1]) sum_(scaledDiameters,i)/circumference*360+scaledDiameters[i]*0.5];
    module base(addH) {
        cylinder(r = maxRadii, h = baseVerticalOffset1, $fn=72);
        linear_extrude(height=baseVerticalOffset+addH)
        difference() {
            circle(r=r, $fn=72);
            circle(r=minInset, $fn=72);
        }
    }
    
    module hole(i) {
        translate(radii[i]*[cos(angles[i]),sin(angles[i])]) rotate(angles[i]+90) holeProfile(pieces[i][3]);
    }
    
    if (! solidMode) {
        base(0);
        difference() {
            intersection() {
                base(maxHeight + verticalExtra);
                union() {
                    cylinder(h=baseVerticalOffset+minHeight+verticalExtra, r=minInset+wallThickness, $fn=72);
                    for(i=[0:n-1]) {
                        linear_extrude(height=heights[i]+verticalExtra+baseVerticalOffset)
                        difference() {
                            minkowski() {
                                hole(i);
                                circle(r=wallThickness,$fn=16);
                            }
                            hole(i);
                        }
                    } 
                }
            }
            translate([0,0,baseVerticalOffset])  linear_extrude(height=maxHeight+verticalExtra) for(i=[0:n-1]) hole(i);
        }
    }
    else {
        difference() {
            base(maxHeight + verticalExtra);
            for (i=[0:n-1]) {
               translate([0,0,baseVerticalOffset+maxHeight-heights[i]]) linear_extrude(height=verticalExtra+heights[i]+nudge) hole(i);
            }
        }
    }    
}

module asterisk() {
    for(i=[0:2])
        rotate(i*60) square([coverThinWall,40], center=true);
}

module cover(pieces,stickOut,equalize=false) {
    n = len(pieces);
    
    diameters = [for (i=[0:n-1]) pieces[i][4]+horizontalDiameter(pieces[i][3])];
    scaledDiameters = diameterMultiplier*shift(horizontalTolerance*(solidMode?2:1), diameters);
    circumference = sum(scaledDiameters,n);
    maxHeight = max([for (i=[0:n-1]) pieces[i][2]]);
    heights = equalize ? [for (i=[0:n-1]) maxHeight] : [for (i=[0:n-1]) pieces[i][2]];
    minHeight = min(heights);
    r = circumference / (2*pi);
    radii = [for (i=[0:n-1]) r+stickOut+pieces[i][5]];
    maxRadii = max(radii);
    minInset = min( [for (i=[0:n-1]) min([for (j=[0:len(pieces[i][3])-1]) radii[i]-pieces[i][3][j][1]])] ) - horizontalTolerance - wallThickness;
    baseVerticalOffset = baseVerticalOffset1 + baseVerticalOffset2;
    angles = [for(i=[0:n-1]) sum_(scaledDiameters,i)/circumference*360+scaledDiameters[i]*0.5];
        
    $fn=72;
    translate([0,0,maxHeight])
    cylinder(r=maxRadii, h=coverTopWall);
 
    difference() {
        union() {
            difference() {
                cylinder(r1=minInset-coverTolerance-1.5,r2=minInset-coverTolerance,h=4);
                translate([0,0,-nudge])
                cylinder(r1=minInset-coverTolerance-1.5-coverWall,r2=minInset-coverTolerance-coverWall,h=4+2*nudge);
            }
            
            translate([0,0,4-nudge])
            linear_extrude(height=maxHeight+2*nudge-4)
            difference() {
                circle(r=minInset-coverTolerance);
                circle(r=minInset-coverTolerance-coverWall);
            }
        }
        cube([minInset*.2,minInset*2,maxHeight*2+2*nudge], center=true);
        rotate([0,0,90]) cube([minInset*.2,minInset*2,maxHeight*2+2*nudge], center=true);
    }
    
    module aster(i) {
        translate(radii[i]*[cos(angles[i]),sin(angles[i])]) rotate(angles[i]+90) translate(center2d(pieces[i][3])) asterisk();
    }
    
    module hole(i) {
        translate(radii[i]*[cos(angles[i]),sin(angles[i])]) rotate(angles[i]+90) holeProfile(pieces[i][3]);
    }
    for(i=[0:n-1]) {
       translate([0,0,heights[i]-coverExtraStickout+nudge]) linear_extrude(height=maxHeight-heights[i]+coverExtraStickout)
       intersection() { 
           offset(delta=-coverLooseTolerance-wallThickness) hole(i);
           aster(i);
       }
    }
}

module go() {
    render(convexity=8) 
    if (roundModifiers) 
        circularHolder(circlePieces,stickOutCircular,equalize=true);
    else
        circularHolder(otherPieces,stickOutOther,equalize=false);
    }

module gocover() {
    render(convexity=8) 
    if (roundModifiers) 
        cover(circlePieces,stickOutCircular,equalize=true);
    else
        cover(otherPieces,stickOutOther,equalize=false);
    }

if (testMode) {
    intersection() {
        cylinder(r=100,h=7);
        translate([0,0,-1.5])
        go();
    }
}
else {
    if (cover)
    rotate([180,0,0])
        gocover();
    else
        go();
}

