create = 1; // [0:lid, 1:box]
rounding = 5;
outerWidth = 38;
outerLength = 90;
sideWall = 1;
lip = 3;
baseThickness = 1.5;
lidThickness = 2.5;
lidThicknessTolerance = 0.25;
lidSideTolerance = 0.25;
height = 20;
portWidth = 11;
portHeight = 1.39;
screwHoleDiameter = 2.9;
screwHoleDepth = 12;
switchHoleDiameter = 6.8;
verticalSwitchTextOffset = 8;
horizontalSwitchTextOffset = 7.2;
switchLayout = [
    [ [-2/3, 0.4], "v", "WingDings 3", 5, ["\u00C5\u00C6", "\u00C6\u00C5"] ],
    [ [-1/3, 0.4], "v", "WingDings 3", 5, ["\u00C7", "\u00C8"] ],
    [ [1/3, 0.4], "v", "WingDings 3", 5, ["\u00C7", "\u00C8"] ],
    [ [2/3, 0.4], "v", "WingDings 3", 5, ["\u00C7", "\u00C8"] ],
    [ [0, -0.6], "h", "WingDings 3", 5, ["\u00C5", "\u00C6"] ],
    [ [2/3, -0.6], "h", "Arial Black", 5, ["0","1"] ]
    ];
textThickness = 1.3;
extraScrewHoles = [[0,0]];

module ribbon(points,closed=true) {
    for (i=[0:len(points)-(closed?1:2)]) {
        hull() {
            translate(points[i]) children();
            translate(points[(i+1)%len(points)]) children();
        }
    }
}

$fn = 24;
nudge = 0.01;

adjWidth = outerWidth - rounding - sideWall;
adjLength = outerLength - rounding - sideWall;

function arc(r,start,end,origin=[0,0]) = [ for(i=[0:$fn-1]) let(t=i/($fn-1), angle=(1-t)*start+t*end) origin+r*[cos(angle),sin(angle)] ];
    
innerCorners = [[adjLength/2,adjWidth/2],[-adjLength/2,adjWidth/2],[-adjLength/2,-adjWidth/2],[adjLength/2,-adjWidth/2]];

screwHoles = concat(innerCorners, [for (s=extraScrewHoles) [s[0]*adjLength/2,s[1]*adjWidth/2]]);

function rounded(inset=0) = 
    let(r=rounding-inset) 
    [for(a=[for (i=[0:3]) arc(r,i*90,i*90+90,origin=innerCorners[i])]) for(b=a) b];

mainOutline = rounded(inset=sideWall/2);

module filledBox(height=height) {
    linear_extrude(height=height) hull() ribbon(mainOutline) circle(d=sideWall);
}


module mainBox() {
    innerHeight = height-lidThicknessTolerance-lidThickness-lip;
    difference() {
        union() {
        filledBox(height=baseThickness);
        ribbon(mainOutline) cylinder(d=sideWall,h=height);
        intersection() {
            translate([0,0,innerHeight]) ribbon(mainOutline) cylinder(d1=sideWall,d2=sideWall+2*lip,h=lip);
            filledBox();
        }
        for (s=screwHoles) translate(s) cylinder(r=rounding-sideWall/2,h=innerHeight+lip);
        }
        for (s=screwHoles) translate([s[0],s[1],innerHeight+lip-screwHoleDepth]) cylinder(d=screwHoleDiameter,h=screwHoleDepth+nudge);
        translate([-portWidth/2,rounding-sideWall/2,innerHeight+lip-portHeight]) cube([portWidth,outerLength,portHeight+lidThickness+lidThicknessTolerance+nudge]);
    }
}

module lid() {
    difference() {
        linear_extrude(height=lidThickness) hull() ribbon(rounded(inset=sideWall+nudge+lidSideTolerance)) circle(d=nudge);
        union() {
            for (s=screwHoles) translate([s[0],s[1],-nudge]) cylinder(d=screwHoleDiameter,h=screwHoleDepth+2*nudge);
        for (switch=switchLayout) {
                x = switch[0][0]*adjLength/2;
                y = switch[0][1]*adjWidth/2;
                translate([x,y,-1]) cylinder(d=switchHoleDiameter,h=lidThickness+2);
            }
        }
    }
    for (switch=switchLayout) {
        x = switch[0][0]*adjLength/2;
        y = switch[0][1]*adjWidth/2;
        offset = switch[1] == "v" ? verticalSwitchTextOffset : horizontalSwitchTextOffset;
        t = switch[1] == "v" ? [ [x,y+offset], [x,y-offset] ] : [ [x-offset,y], [x+offset,y] ];
        for (i=[0:1]) {
            translate([t[i][0],t[i][1],lidThickness-nudge]) linear_extrude(height=textThickness) text(switch[4][i],font=switch[2],size=switch[3],valign="center",halign="center");
        }
    }
}

render(convexity=2) 
if (create == 1) mainBox();
    else lid();