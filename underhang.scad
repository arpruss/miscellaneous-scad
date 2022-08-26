use <Bezier.scad>;

module underhangProfile(stickout,angle=30,nudge=0.01) {
    
    BezierVisualize(PathToBezier([
            [-nudge,0],
            [stickout,0],
            [0,[0,-stickout/tan(angle)]],
            [0,[-nudge,-stickout/tan(angle)]]],offset=stickout*0.2));
}

underhangProfile(10);
