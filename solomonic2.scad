use <quickthread.scad>;

verticalPeriod = 25;
horizontalAmplitude = 5;
slicesPerPeriod = 24;
innerDiameter = 14;
height = 100;

threadProfile = 
    [for(t=[0:slicesPerPeriod])
        let (angle=t/slicesPerPeriod*360,
             z=t/slicesPerPeriod*verticalPeriod)
        [horizontalAmplitude*(1+sin(angle-90))/2,z]];
    
rawThread(threadProfile, d=innerDiameter, h=height, clip=true);