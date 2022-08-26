width = 12;
end = 11;
length = 100;

angle = 2 * atan(end/2/length);
echo(angle);

linear_extrude(height=width) {
    polygon([[0,0],[length,0],length*[cos(angle),sin(angle)]]);
}