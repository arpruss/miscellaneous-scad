screw = 2.5;
tubeOD = 268.5;
tubeID = 237.5;
filter = 8 * 25.4;
outerRim = 8;
innerRim = 9;

$fn = 64;

id = filter - innerRim*2;

module screws() {
    for (angle=[45,135,-45,-135]) rotate(angle) translate([(id+tubeID)/4,0,0]) circle(d=screw);
}

module outer() {
    difference() {
        circle(d=tubeOD+2*outerRim);
        circle(d=id);
        screws();
    }
}

module inner() {
    difference() {
        circle(d=tubeID);
        circle(d=id);
        screws();
    }
}

//outer();
inner();