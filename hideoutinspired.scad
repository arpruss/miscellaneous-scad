use <pointHull.scad>;

width = 36 * 25.4;
height = 7.25 * 25.4;
depth = 1.5 * 25.4;

valley = 0.875 * 25.4;
spacing = 1 * 25.4;

valleyDepths = [0.5 * 25.4, 0.75 * 25.4, 1 * 25.4];

jugAngle = 12;
jugFlat = 0.3 * 25.4;
sloperFrontAngle = 10.5;
sloperSideAngle = 13;
sloperWidth = 6 * 25.4;

nudge = 0.01;   

difference() {
    cube([width,height,depth]);
    for (i=[0:len(valleyDepths)-1]) 
        translate([0,(i+1)*spacing+i*valley,depth-valleyDepths[i]
    ]) translate([-nudge,0,0]) cube([width+2*nudge,valley,depth]);
    
    pointHull( [for(x=[-nudge,nudge+width]) for(p=[[ x, height+nudge, depth-jugFlat], [x, height+nudge-(depth-jugFlat)*tan(jugAngle), -nudge], [x, height+nudge, -nudge]]) p]);
        
    sloperX = [-nudge, nudge+width];
    sloperSign = [1, -1];
    dyFront = sloperWidth * tan(sloperFrontAngle);

    dySide = depth * tan(sloperSideAngle);
    
    echo(dyFront/25.4);
    
    for (i=[0:1]) {
        x = sloperX[i];
        s = sloperSign[i];
        pointHull([[x,height+nudge,-nudge],[x,height-dyFront,depth],[x,height+dySide-dyFront,-nudge],[x,height+nudge,depth+nudge],[x+s*sloperWidth,height+nudge,depth+nudge],[x+s*sloperWidth,height+tan(sloperSideAngle)*depth,0]]);
    }
}