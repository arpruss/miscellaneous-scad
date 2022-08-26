use <eval.scad>;

f = ["pow", "x", 2];

plot(f, 0, 1, 0.1);

module plot(f, _min, _max, _res){
for(i = [_min : _res : _max])
translate([i, eval(f,[i]), 0])
sphere(d = 1);
}