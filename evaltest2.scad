use <eval.scad>;

echo(compileFunction("[]"));
echo(_fixBrackets(_tokenize("[]")));
echo(eval(compileFunction("[]")));