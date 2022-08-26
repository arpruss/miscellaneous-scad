use <eval.scad>;

//echo(compileFunction("let(a=3) a+b"));
echo(compileFunction("undef"));
//echo(compileFunction("[a]"));
echo(compileFunction("let(a=3) -[a,b,c]"));
//echo(compileFunction("[1,2,b]"));
echo(_fixCommas(_parseMain(_parsePass1("let(ab=4) u"))));
echo(compileFunction("abc"));
uo = compileFunction("let(ab=4) ab",optimize=true);
echo(uo);
//echo(_optimize(uo));
//echo(compileFunction("let(z=3) [80*cos(u*10),80*sin(u*10),20*(v-u*20/360)]")); // 80*cos(u*10),80*sin(u*10),20*(v-u*20/360)])"));