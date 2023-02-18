n=10;
minD=1.003409520;
bumpR = 2*sin((1/2)*asin(minD/2)) - 0.01;
points = [[-0.769576327,0.076025611,-0.634012920],[0.171896680,0.094007448,-0.980619259],[-0.735899412,-0.596589376,0.320208012],[-0.142999142,-0.889220618,-0.434554872],[-0.787435960,0.567494600,0.240612732],[0.769576327,-0.076025611,0.634012920],[-0.171896680,-0.094007448,0.980619259],[0.735899412,0.596589376,-0.320208012],[0.142999142,0.889220618,0.434554872],[0.787435960,-0.567494600,-0.240612732]];
difference() {
 sphere(r=1,$fn=36);
 for(i=[0:len(points)-1]) translate(points[i]) #sphere(r=minD/2,$fn=36);
}
