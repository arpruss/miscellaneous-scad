in = 25.4;
linear_extrude(height=2*in) 
difference() {
    circle(d=1.3125*in);
    circle(d=1.28*in);
}