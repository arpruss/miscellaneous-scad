mpcncToolProfile0 = [ [28.891,3.350],
             [26.284,1.817],
             [18.539,-0.258],
             [11.794,3.025],
             [11.001,3.299],
             [4.502,4.788],
             [3.072,4.944] ];
minY = min([for(p=mpcncToolProfile0) p[1]]);
mpcncToolProfile = concat([for(p=mpcncToolProfile0) p-[0,minY]],[for(i=[0:len(mpcncToolProfile0)-1]) [-mpcncToolProfile0[len(mpcncToolProfile0)-1-i][0],mpcncToolProfile0[len(mpcncToolProfile0)-1-i][1]-minY]]);
rightScrewCoordinates = (mpcncToolProfile[1]+mpcncToolProfile[2])/2;
screwInwardTiltAngle = atan2(mpcncToolProfile[1][1]-mpcncToolProfile[2][1],mpcncToolProfile[1][0]-mpcncToolProfile[2][0]);

module drawToolProfile(minimumThickness=10,corner=1,inCut=3) {
    adjustedmpcncToolProfile = concat([[mpcncToolProfile[0][0]+corner-inCut,-minimumThickness],[mpcncToolProfile[0][0]+corner,mpcncToolProfile[0][1]-corner]],
        mpcncToolProfile,
        [[-mpcncToolProfile[0][0]-corner,mpcncToolProfile[0][1]],
    [-mpcncToolProfile[0][0]-corner+inCut,-minimumThickness]]);
    polygon(adjustedmpcncToolProfile);
}


drawToolProfile();