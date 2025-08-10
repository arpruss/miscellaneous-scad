defaultKerf = .12;
defaultThickness = 6;

module teeth(thickness=defaultThickness,numTeeth=4,length=40,kerf=defaultKerf) {
    toothSize = length / (2*numTeeth+1);
    for (i=[0:numTeeth-1])
        translate([(2*i+1)*toothSize-kerf,-thickness]) square([toothSize+2*kerf,thickness+0.01]);
}

module toothSockets(thickness=defaultThickness,numTeeth=4,length=40,kerf=defaultKerf) {
        toothSize = length / (2*numTeeth+1);
        for (i=[0:numTeeth-1])
            translate([(2*i+1)*toothSize,0]) square([toothSize,thickness-kerf]);
}

module teethFemale(thickness=defaultThickness,numTeeth=4,length=40,kerf=defaultKerf) {
    toothSize = length / (2*numTeeth+1);
    for (i=[0:numTeeth])
        translate([(2*i)*toothSize,-thickness]) square([toothSize,thickness+0.01]);
}

module teeth_test1() {
    length = 100;
    woodThickness = 6;
    square([length,20]);
    teeth(length=length,thickness=woodThickness);
    
    translate([0,-20]) difference() {
        translate([0,-10]) square([length,20]);
        translate([0,-woodThickness/2]) toothSockets(length=length,thickness=woodThickness);
    }
}

module teeth_test2() {
    length = 100;
    woodThickness = 6;
    square([length,20]);
    teeth(length=length,thickness=woodThickness);
    
    translate([0,-30]) {
        square([length,20]);
        teethFemale(length=length,thickness=woodThickness);
    }
}

teeth_test2();

