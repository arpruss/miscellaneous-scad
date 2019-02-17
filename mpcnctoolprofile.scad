mpcncToolProfile0 = [ [28.891,3.350+0.258],
             [26.284,1.817+0.258],
             [18.539,0],
             [11.794,3.025+0.258],
             [11.001,3.299+0.258],
             [4.502,4.788+0.258],
             [3.072,4.944+0.258] ];
mpcncToolProfile = concat([for(p=mpcncToolProfile0) p],[for(i=[0:len(mpcncToolProfile0)-1]) [-mpcncToolProfile0[len(mpcncToolProfile0)-1-i][0],mpcncToolProfile0[len(mpcncToolProfile0)-1-i][1]]]);
mpcncRightScrewCoordinates = (mpcncToolProfile[1]+mpcncToolProfile[2])/2;
mpcncLeftScrewCoordinates = [-mpcncRightScrewCoordinates[0],mpcncRightScrewCoordinates[1]];
mpcncFirstScrewHeight = 6;
mpcncScrewVerticalSpacing = 25;
mpcncScrewDiameter = 4.25;
mpcncScrewInwardTiltAngle = atan2(mpcncToolProfile[1][1]-mpcncToolProfile[2][1],mpcncToolProfile[1][0]-mpcncToolProfile[2][0]);

module drawMPCNCToolProfile(minimumThickness=10,base=55,corner=1) {
    adjustedmpcncToolProfile = concat([[base/2,-minimumThickness],[mpcncToolProfile[0][0]+corner,mpcncToolProfile[0][1]-corner]],
        mpcncToolProfile,
        [[-mpcncToolProfile[0][0]-corner,mpcncToolProfile[0][1]-corner],
    [-base/2,-minimumThickness]]);
    polygon(adjustedmpcncToolProfile);
}


//drawToolProfile();