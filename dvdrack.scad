n1=0;
spacing1 = 7;
n2=10;
spacing2 = 15;
n3=0;
spacing3 = 10;
n4=0;
spacing4 = 10;
minimum_width_for_plastic_removal = 10;

inside_thickness = 1.5;
base_thickness = 1.75;
rear_height = 50.8;
front_height = 19.05;
depth = 76.2;
rear_thickness = 1;

module endOfCustomizerData() {}

nudge = 0.01;

counts = [n1,n2,n3,n4];
spacings = [spacing1,spacing2,spacing3,spacing4];

function join(arrays,n) = n>=len(arrays) ? [] : concat(arrays[n], join(arrays,n+1));

dx_rev = join([for(i=[0:1:len(counts)-1]) [for(j=[0:1:counts[i]-1]) spacings[i]]],0);
dx = [for(i=[0:len(dx_rev)-1]) dx_rev[len(dx_rev)-1-i]];

function sum(v,n) = n<0 ? 0 : v[n]+sum(v,n-1);

width = sum(dx,len(dx)-1) + (len(dx)+1)*inside_thickness;
echo("Width",width);

function xpos(n) = sum(dx,n-1) + inside_thickness * n;

module base() {
    render(convexity=10)
    difference() {
        cube([width, depth, base_thickness]);
        for(i=[1:1:len(dx)-2]) {
            if (dx[i] >= minimum_width_for_plastic_removal) {
                x = width-xpos(i)-inside_thickness;
                color("red") translate([0,0,-nudge]) linear_extrude(height=base_thickness+2*nudge)
                polygon(points=[[x,.15*depth],[x-dx[i]/2,.15*depth],[x-dx[i],.85*depth],[x-dx[i]/2,.85*depth]]);
            }
        }
    }
}

module stand() {
translate([0,0,nudge]) base();
    
translate([0,depth-nudge,0])
cube([width, rear_thickness, rear_height+inside_thickness/2]);

for (i=[0:len(dx)]) {
    translate([width-(inside_thickness/2+xpos(i)),0,0])
    minkowski() {
    intersection() {
    sphere(r=inside_thickness/2,$fn=10);
        translate([-inside_thickness/2,-inside_thickness,0]) cube(inside_thickness);
    }
    rotate([0,-90,0])
    linear_extrude(height=0.001)
    difference() {
    polygon(points=[[0,0],[front_height,0],[rear_height,depth],[0,depth]]);
    polygon(points=[[0,0.1*depth],[0.7*rear_height,0.85*depth],[0,0.85*depth]]);
    }
    }
}
}

rotate([-90,0,0]) 
stand();