use <Bezier.scad>;
use <tubeMesh.scad>;

module overhang(radius=5,stickout=5,overhangAngle=45,nudge=0.001,$fn=16) {
    
    profile = Bezier(PathToBezier([
            [-nudge,0],
            [stickout,0],
            [0,[0,-stickout/tan(overhangAngle)]],
            [0,[-nudge,-stickout/tan(overhangAngle)]]],offset=stickout*0.2));
    function profileAt(angle)=
        [for(p=profile) [radius*cos(angle),-p[0],radius*sin(angle)+p[1]]];
    sections = [ 
    for (i=[0:$fn-1]) 
        profileAt(-180+180*(i/($fn-1))) 
    ];
    tubeMesh(sections);
    
}

overhang();