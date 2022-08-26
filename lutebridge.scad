w1 = 136.19;
w2 = 133.43;
h = 15.73;
h0 = 7.11;
stringArea = 95;
numStrings = 12;
d = 1;

difference() {
    polygon([[-w1/2,0],[w1/2,0],[w2/2,h],[-w2/2,h]]);
    dx = stringArea / (numStrings-1);
    for(i=[0:numStrings-1])
        translate([-stringArea/2 + dx * i, h0]) circle(d=d);
}