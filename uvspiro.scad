use <pdgear.scad>;

toothSize = 6.4;
clearance = 0.5;
backlash = 1.25;
gearThickness = 3;
innerThickness = 1.5; // cannot exceed gearThickness
rimSize = 2;
holderDepth = 3.3;
holderWidth = 7;
holderRim = 2;
ringTeeth1=68;
ringTeeth2=92;
circleTeeth=28;
spikeHeight=8;
spikeDiameter=3;


module dummy(){}

nudge = 0.01;

module ring(outerTeeth=ringTeeth2, innerTeeth=ringTeeth1, outerClearance=0) {
    render(convexity=5)
    difference() {
        translate([0,0,gearThickness/2])
        gear(mm_per_tooth=toothSize, number_of_teeth=outerTeeth, hole_diameter=0, thickness=gearThickness, clearance=outerClearance,backlash=backlash);
        if(innerTeeth) {
            translate([0,0,gearThickness/2])
            gear(mm_per_tooth=toothSize, number_of_teeth=innerTeeth, hole_diameter=0, thickness=gearThickness+2*nudge, backlash=0);
        }
        if (innerThickness < gearThickness)
            translate([0,0,innerThickness])
            difference() {
                cylinder(r=rootRadius(mm_per_tooth=toothSize, number_of_teeth=outerTeeth)-rimSize, h=gearThickness-innerThickness+nudge); 
                if (innerTeeth) {
                    translate([0,0,-nudge]);
                    cylinder(r=outerRadius(mm_per_tooth=toothSize, number_of_teeth=innerTeeth)+rimSize, h=gearThickness-innerThickness+2*nudge); 
                }
            }
    }
}

function getHoles(holes, radius) =
    [for(i=[0:holes-1]) let(angle=i*360/(holes-1)) [cos(angle), sin(angle)] * ((radius-holderWidth-holderRim-spikeDiameter-holderRim) * i/(holes-1)+spikeDiameter+holderRim+holderWidth/2)];

module innerGear(holes=5) {
    holeCenters = getHoles(holes, rootRadius(number_of_teeth=circleTeeth, mm_per_tooth=toothSize));
    echo(holeCenters);
    render(convexity=3) {
        difference() {
            union() {
                for(i=[0:holes-1]) translate(holeCenters[i]) cylinder(r=holderWidth/2+holderRim, h=holderDepth);
                ring(outerTeeth=7*3, innerTeeth=0, outerClearance=clearance);
            }
            for (i=[0:holes-1]) translate(holeCenters[i]-[0,0,nudge]) cylinder(d=holderWidth, h=3*nudge+max(holderDepth, gearThickness));
            }
        }
    cylinder(d=2.5,h=spikeHeight+innerThickness,$fn=16);
}

ring();
innerGear();
