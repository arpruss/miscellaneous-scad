// begin string to float library
// Jesse Campbell
// www.jbcse.com
// http://www.thingiverse.com/thing:2247435
// OpenSCAD ascii string to number conversion function atof
// atoi and substr are from http://www.thingiverse.com/roipoussiere
// licensed under the Creative Commons - Attribution license.

// modified to support scientific notation by Alexander Pruss

function atoi(str, base=10, i=0, nb=0) =
	i == len(str) ? (str[0] == "-" ? -nb : nb) :
	i == 0 && str[0] == "-" ? atoi(str, base, 1) :
	atoi(str, base, i + 1,
		nb + search(str[i], "0123456789ABCDEF")[0] * pow(base, len(str) - i - 1));

function substr(str, pos=0, len=-1, substr="") =
	len == 0 ? substr :
	len == -1 ? substr(str, pos, len(str)-pos, substr) :
	substr(str, pos+1, len-1, str(substr, str[pos]));
    
function atof(str) = 
    len(str) == 0 ? 0 : 
        let(
            expon1 = search("e", str),
            expon = len(expon1) ? expon1 : search("E", str))
           len(expon) ? atof(substr(str,pos=0,len=expon[0])) * pow(10, atoi(substr(str,pos=expon[0]+1))) :
        let(
            multiplyBy = (str[0] == "-") ? -1 : 1,
            str = (str[0] == "-" || str[0] == "+") ? substr(str, 1, len(str)-1) : str,    
            decimal = search(".", str),    
            beforeDecimal = decimal == [] ? str : substr(str, 0, decimal[0]),
            afterDecimal = decimal == [] ? "0" : substr(str, decimal[0]+1)
        )
        (multiplyBy * (atoi(beforeDecimal) + atoi(afterDecimal)/pow(10,len(afterDecimal))));
// end string to float library


function _tail(v) = len(v)>=2 ? [for(i=[1:len(v)-1]) v[i]] : [];
function _isspace(c) = (" " == c || "\t" == c || "\r" == c || "\n" == c );
function _isdigit(c) = ("0" <= c && c <= "9" );
function _isalpha(c) = ("a" <= c && c <= "z") || ("A" <= c && c <= "Z");
function _isalpha_(c) = _isalpha(c)  || c=="_";
function _isalnum_(c) = _isalpha(c) || _isdigit(c) || c=="_";
function _flattenLists(ll) = [for(a=ll) for(b=a) b];

function _spaceSequence(s, start=0) = 
    len(s)>start && _isspace(s[start]) ? 1+_spaceSequence(s, start=start+1) : 0;
function _digitSequence(s, start=0) =
    len(s)>start && _isdigit(s[start]) ? 1+_digitSequence(s, start=start+1) : 0;
function _alnum_Sequence(s, start=0) = 
    len(s)>start && _isalnum_(s[start]) ? 1+_alnum_Sequence(s, start=start+1) : 0;
function _identifierSequence(s, start=0) = 
    len(s)>start && _isalpha_(s[start]) ? 1+_alnum_Sequence(s, start=start+1) : 0;
function _signedDigitSequence(s, start=0) = 
    len(s) <= start ? 0 :
        (s[start] == "+" || s[start] == "-" ) ? 1+_digitSequence(s,start=start+1) : _digitSequence(s,start=start);
function _realStartingWithDecimal(s, start=0) =
    len(s)>start && s[start] == "." ?
        let(next = start+1+_digitSequence(s, start=start+1))
        (s[next] == "e" || s[next] == "E" ?
            next-start+1+_signedDigitSequence(s, start=next+1) : next-start)
        : 0;
function _realContinuation(s, start=0) = 
    len(s) <= start ? 0 :
        let(c1=_realStartingWithDecimal(s, start=start))
        c1 > 0 ? c1 :
        s[start] == "e" || s[start] == "E" ?
            1+_signedDigitSequence(s, start=start+1) : 0;
function _positiveRealSequence(s, start=0) = 
    len(s) <= start ? 0 :
        let(c1 = _realStartingWithDecimal(s, start=start))
            c1 > 0 ? c1 :
        let(c2 = _digitSequence(s, start=start))
            c2 > 0 ? c2 + _realContinuation(s, start=start+c2) : 0;

_multiSymbolOperators = [ "<=", ">=", "==", "&&", "||" ]; // must be in order of decreasing length

function _multiSymbolOperatorSequence(s, start=0) =
    (s[start]=="<" && s[start+1]=="=") ||
    (s[start]==">" && s[start+1]=="=") ||
    (s[start]=="=" && s[start+1]=="=") ||
    (s[start]=="&" && s[start+1]=="&") ||
    (s[start]=="|" && s[start+1]=="|") ? 2 : 0;
    
function _tokenize(s, start=0) =
    start >= len(s) ? [] :
    let(c1=_spaceSequence(s, start=start)) c1>0 ?
        concat([" "], _tokenize(s, start=start+c1)) :
    let(c2=_identifierSequence(s, start=start)) c2>0 ? 
        concat([substr(s, pos=start, len=c2)], _tokenize(s, start=start+c2)) :
    let(c3=_positiveRealSequence(s, start=start)) c3>0 ? 
        concat([substr(s, pos=start, len=c3)], _tokenize(s, start=start+c3)) :
    let(c4=_multiSymbolOperatorSequence(s, start=start)) c4>0 ? 
        concat([substr(s, pos=start, len=c4)], _tokenize(s, start=start+c4)) :
        concat([s[start]], _tokenize(s, start=start+1));

        
function _endParens(list,start=0,openCount=0,_stop=undef) = 
    let(stop = _stop==undef ? len(list) : _stop)
    start >= stop ? (openCount?undef:stop) :
    list[start][0] == ")" ? 
            (openCount==1 ? start+1 : _endParens(list,start+1,_stop=stop, openCount=openCount-1)) : 
    _endParens(list,start+1,_stop=stop, openCount=
        list[start][0] == "(" ? 
            openCount+1 : openCount);
        
function _indexInTable(string, table, column=0) =
    let (s=search([string], table, index_col_num=column))
        s[0] == [] ? -1 : s[0][0];

_NAME = 0;
_ARITY = 1;
_PREC = 2;
_LEFT_ASSOC = 3;
_ARGUMENTS_FROM_VECTOR = 4;
_OPERATOR = 5;

function _func(op) = [ op, 1, 1.5, true, false, op ];

_operators = [
    [ "#", 2, 0, true, false, "#" ],
    [ "^", 2, 0, false, false, "^" ],
    [ "*", 2, 1, true, false, "*" ],
    [ "/", 2, 1, true, false, "/" ],
    [ "%", 2, 1, true, false, "%" ],
    [ "[", 1, 1.5, true, true, "[" ],
    [ "atan2", 1, 1.5, true, true, "atan2" ],
    [ "ATAN2", 1, 1.5, true, true, "ATAN2" ],
    [ "max", 1, 1.5, true, true, "max" ],
    [ "min", 1, 1.5, true, true, "min" ],
    [ "pow", 1, 1.5, true, true, "pow" ],
    [ "cross", 1, 1.5, true, true, "cross" ],
    _func("sqrt"),
    _func("cos"),
    _func("sin"),
    _func("tan"),
    _func("acos"),
    _func("asin"),
    _func("atan"),
    _func("COS"),
    _func("SIN"),
    _func("TAN"),
    _func("ACOS"),
    _func("ASIN"),
    _func("ATAN"),
    _func("abs"),
    _func("ceil"),
    _func("exp"),
    _func("floor"),
    _func("ln"),
    _func("log"),
    _func("round"),
    _func("sign"),
    _func("norm"),
    [ "#-",1, 1.5, true, false, "-" ],
    [ "+", 2, 2, true, false, "+" ],
    [ "-", 2, 2, true, false, "-" ],
    [ ",", 2, 100, true, false, "," ]
   ];
    
_binary_or_unary = [ ["-", "#-"], ["#", "["] ];

function _fixBrackets(pretok,start=0) =
    start >= len(pretok) ? [] :
    pretok[start] == "[" ?
        concat(["#", "("], _fixBrackets(pretok,start=start+1)) :
    pretok[start] == "]" ?
        concat([")"], _fixBrackets(pretok,start=start+1)) :
        concat(pretok[start], _fixBrackets(pretok,start=start+1));

function _fixUnaries(pretok) =
    [ for (i=[0:len(pretok)-1]) 
         let (
            a = pretok[i],
            j=_indexInTable(a, _binary_or_unary)) 
            (0 <= j && (i == 0 || pretok[i-1] == "(" ||
                0 <= _indexInTable(pretok[i-1], _operators)))? _binary_or_unary[j][1] : a ];

function _parsePass1(s) =
    let (pretok=_fixUnaries(_fixBrackets(_tokenize(s))))
    [ for (i=[0:len(pretok)-1])
        let (a=pretok[i])
        if (a[0] != " ")
        let (j=_indexInTable(a, _operators))
            j >= 0 ? _operators[j] : [a] ];
    
function _prec(op1, pos1, op2, pos2) =
    op1 != undef && op2 == undef ? false :
    op1 == undef && op2 != undef ? true :
    op1[_PREC] < op2[_PREC] ? true :
        op2[_PREC] < op1[_PREC] ? false :
            op1[_LEFT_ASSOC] ? pos1 < pos2 :
                op2[_LEFT_ASSOC] ? pos2 < pos1 :
                    pos2 < pos1;
    
function _parseLiteralOrVariable(s) = 
        _isalpha_(s[0]) ? ["$", s] : atof(s);
        
function _isoperator(token) = _PREC<len(token);
    
function _mainOperator(tok,start,stop) = 
        let (token = tok[start])
        stop <= start ? [undef,start] :
        stop == start+1 ? ( _isoperator(token) ? [token,start] : [undef,start] ) :
        let( rest = 
            token[0] == "(" ? _mainOperator(tok, _endParens(tok,start=start+1,_stop=stop, openCount=1), stop)
            : _mainOperator(tok, start+1, stop),
            adjToken = _isoperator(token) ? token : undef )
            _prec(rest[0], rest[1], adjToken, start) ? [adjToken, start] : rest; 
    
/* This takes a fully tokenized vector, each element of which is either a line from the _operators table or a vector containing a single non-operator string, and parses it using general parenthesis and operator parsing. Comma expressions for building vectors will be parsed in the next pass. */
function _parseMain(tok,start=0,_stop=undef) = 
    let( stop= _stop==undef ? len(tok) : _stop )
        stop <= start ? undef :
        tok[start][0] == "(" ? 
            _parseMain(tok,start=start+1,_stop=_endParens(tok,start=start+1,openCount=1,stop=stop)-1) : 
        let( lp = _mainOperator(tok,start,stop) )
            lp[0] == undef ? ( stop-start>1 ? undef : _parseLiteralOrVariable(tok[start][0]) ) :
            let( op = lp[0], pos = lp[1] )
                op[_ARITY] == 2 ?
                    [ op[_OPERATOR], _parseMain(tok,start=start,_stop=pos), _parseMain(tok,start=pos+1,_stop=stop) ]
                    : [ op[_OPERATOR], _parseMain(tok,start=pos+1,_stop=stop) ];  
            
           
// this upgrades sequences of binary commas to vectors            
function _fixCommas(expression) = 
    expression[0] == "," ? 
        let(a=_fixCommas(expression[1]),
            b=_fixCommas(expression[2])) 
            a[0] == "[[" ? 
                concat(["[["],concat(_tail(a), [b])) :
                ["[[",a,b]
        : 
    !(len(expression)>1) ? expression :
            concat([expression[0]], [for (i=[1:len(expression)-1]) _fixCommas(expression[i])]);

// fix arguments from vectors
function _fixArguments(expression) = 
    let(i=_indexInTable(expression[0], _operators, _OPERATOR)) 
            i >=0 && _operators[i][_ARGUMENTS_FROM_VECTOR] && expression[1][0] == "[[" ? concat([expression[0]], [for (i=[1:len(expression[1])-1]) _fixArguments(expression[1][i])]) : 
            len(expression)>1 ? 
                concat([expression[0]], [for (i=[1:len(expression)-1]) _fixArguments(expression[i])])
                    : expression;

function compileFunction(expression) = _fixArguments(_fixCommas(_parseMain(_parsePass1(expression))));

pi = 3.1415926535897932;

function _let(v, var, value) = concat([var, value], v);

function _lookupVariable(var, table) =
    let (s=search([var], table, index_col_num=0))
        s[0] == [] ? undef : table[s[0][0]][1];

function _generate(var, range, expr, v) =
    [ for(i=range) eval(expr, _let(v, var, i)) ];


// note: given the way variables are recognized, operators are not allowed to be a single alnum or underline
function eval(c,v=[]) = 
    c == "x" || c == "y" || c == "z" || c == "t" ? _lookupVariable(c,v) :
    let(op=c[0]) (
    op == undef ? c :
    op == "$" ? _lookupVariable(c[1],v) :
    op == "'" ? c[1] : 
    op == "+" ? eval(c[1],v)+eval(c[2],v) :
    op == "-" ? (len(c)==2 ? -eval(c[1],v) : eval(c[1],v)-eval(c[2],v)) :
    op == "*" ? eval(c[1],v)*eval(c[2],v) :
    op == "/" ? eval(c[1],v)/eval(c[2],v) :
    op == "%" ? eval(c[1],v)%eval(c[2],v) :
    op == "sqrt" ? sqrt(eval(c[1],v)) :
    op == "^" || op == "pow" ? pow(eval(c[1],v),eval(c[2],v)) :
    op == "cos" ? cos(eval(c[1],v)) :
    op == "sin" ? sin(eval(c[1],v)) :
    op == "tan" ? tan(eval(c[1],v)) :
    op == "acos" ? acos(eval(c[1],v)) :
    op == "asin" ? asin(eval(c[1],v)) :
    op == "atan" ? atan(eval(c[1],v)) :
    op == "atan2" ? atan2(eval(c[1],v),eval(c[2],v)) :
    op == "COS" ? cos(eval(c[1],v)*180/pi) :
    op == "SIN" ? sin(eval(c[1],v)*180/pi) :
    op == "TAN" ? tan(eval(c[1],v)*180/pi) :
    op == "ACOS" ? acos(eval(c[1],v))*pi/180 :
    op == "ASIN" ? asin(eval(c[1],v))*pi/180 :
    op == "ATAN" ? atan(eval(c[1],v))*pi/180 :
    op == "ATAN2" ? atan2(eval(c[1],v),eval(c[2],v))*pi/180 :
    op == "abs" ? abs(eval(c[1],v)) :
    op == "ceil" ? ceil(eval(c[1],v)) :
    op == "cross" ? cross(eval(c[1],v),eval(c[2],v)) :
    op == "exp" ? exp(eval(c[1])) :
    op == "floor" ? floor(eval(c[1])) :
    op == "ln" ? ln(eval(c[1])) :
    op == "len" ? len(eval(c[1])) :
    op == "log" ? log(eval(c[1])) :
    op == "max" ? (len(c) == 2 ? max(eval(c[1],v)) : max([for(i=[1:len(c)-1]) eval(c[i],v)])) :
    op == "min" ? (len(c) == 2 ? min(eval(c[1],v)) : min([for(i=[1:len(c)-1]) eval(c[i],v)])) :
    op == "norm" ? norm(eval(c[1],v)) :
    op == "rands" ? rands(eval(c[1],v),eval(c[2],v),eval(c[3],v),eval(c[4],v)) :
    op == "round" ? round(eval(c[1],v)) :
    op == "sign" ? sign(eval(c[1],v)) :
    op == "<" ? eval(c[1],v)<eval(c[2],v) :
    op == "<=" ? eval(c[1],v)<=eval(c[2],v) :
    op == "==" ? eval(c[1],v)==eval(c[2],v) :
    op == "!=" ? eval(c[1],v)!=eval(c[2],v) :
    op == ">=" ? eval(c[1],v)>=eval(c[2],v) :
    op == ">" ? eval(c[1],v)>=eval(c[2],v) :
    op == "&&" ? eval(c[1],v)&&eval(c[2],v) :
    op == "||" ? eval(c[1],v)||eval(c[2],v) :
    op == "!" ? !eval(c[1],v) :
    op == "?" ? (eval(c[1],v)?eval(c[2],v):eval(c[3],v)) :
    op == "[" ? [for (i=[1:len(c)-1]) eval(c[i],v)] :
    op == "#" ? eval(c[1],v)[eval(c[2],v)] :
    op == "concat" ? [for (i=[1:len(c)-1]) let(vect=eval(c[i],v)) for(j=[0:len(vect)-1]) vect[j]] : 
    op == "range" ? (len(c)==3 ? [eval(c[1],v):eval(c[2],v)] : [eval(c[1],v):eval(c[2],v):eval(c[3],v)]) :
    op == "let" ? eval(c[3],_let(v,c[1],c[2])) :
    op == "gen" ? _generate(eval(c[1],v),eval(c[2],v),c[3],v) :
    undef
    );
    
module plot3d(f,start,end,steps=20,height=1) {
    delta = (end-start)/steps;
    for(i=[0:steps-1])
       for(j=[0:steps-1]) {
           xy = [i*delta[0],j*delta[1]]+start;
           z = eval(f,[["x",xy[0]],["y",xy[1]]]);
           translate([xy[0],xy[1],z-height/2]) cube([delta[0],delta[1],height/2]);
       }
               
}   

module curve3d(f,t0,t1,steps=30,thickness=1,closed=false) {
    delta = (t1-t0)/(steps-1);
    values = [for (i=[0:steps-1]) eval(f,[["t", t0+i*delta]])];
        
    for(i=[0:steps-2]) {
        hull() {
            translate(values[i]) sphere(d=thickness);
            translate(values[i+1]) sphere(d=thickness);
        }
    }
}

module demo1() {
    // borromean knot parametrization by I.J. McGee
    r = sqrt(3)/3;
    // 30*[cos(t),sin(t)+r,-cos(3*t)/3];
    color("red") curve3d([ "*", 30, ["[", ["COS", "t"], ["+", ["SIN", "t"], r], ["-", ["/", ["COS", ["*", 3, "t"]], 3]]] ], 0, 2*pi, steps=60, thickness=10);
    // 30*[cos(t)+0.5,sin(t)-r/2,-cos(3*t)/3];
    color("green") curve3d([ "*", 30, ["[", ["+",["COS", "t"],0.5], ["-", ["SIN", "t"], r/2], ["-", ["/", ["COS", ["*", 3, "t"]], 3]]] ], 0, 2*pi, steps=60, thickness=10);
    // 30*[cos(t)-0.5,sin(t)-r/2,-cos(3*t)/3];
    color("blue") curve3d([ "*", 30, ["[", ["-",["COS", "t"],0.5], ["-", ["SIN", "t"], r/2], ["-", ["/", ["COS", ["*", 3, "t"]], 3]]] ], 0, 2*pi, steps=60, thickness=10);
    
       
}

module demo2() {
//plot3d(["*", 3, [ "-", ["*", "x", ["^", "y", 3]], ["*", ["^", "x", 3], "y"] ]], [-1,-1],[1,1], steps=200, height=0.5);
echo(compileFunction("3*(x*y^3-x^3*y)"));    
plot3d(compileFunction("3*(x*y^3-x^3*y)"), [-1,-1],[1,1], steps=200, height=0.5);
}

//demo1();
//demo2();
echo(compileFunction("(-1)^3")); // TODO: FIX
echo(compileFunction("1^2,3*4,5"));
echo(compileFunction("a,b,c,d"));
echo(compileFunction("[1^2,[3*4,5]]"));
//echo(compileFunction("1^2"));
echo(eval(compileFunction("[1,2]+[2,3]")));
echo(eval(compileFunction("atan2(1,0)")));
echo(compileFunction("cross([1,2],[3,4])"));
echo(eval(compileFunction("norm([1,1])")));
s="[1,2]+(z)";
echo(_fixBrackets(_tokenize(s)));
echo(_parsePass1(s));
echo(_parseMain(_parsePass1(s)));