use <eval.scad>;

//<params>
expression = "1+(2*cos(45))^0.5";
//</params>

linear_extrude(height=2)
text(str(expression,"=",evaluateFunction(expression)));
