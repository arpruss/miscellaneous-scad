taper = 5;
diameter = 38;
height = 180;
twists = 1.75;
lobes = 1;
lobeOffset = 5;
slices = 40;
bottomAngle = 20;
bottomTension = 40;
topOffset = 60;
topTension = 50;
topAngle = 20;
bottomAngleFeatheringParameter = 0.5;
rotation = 0;
flipHorizontally = 0; // [0:no, 1:yes]
rescale = 1;
// set to zero for no slit
mountSlitThickness = 4;
mountSlitDepth = 10;
mountSlitHeight = 14;
mountSlitXOffset = 0;
mountSlitYOffset = 0;
tolerance = 0.25;

module end_of_parameters_dummy() {}


//BEGIN: use <tubemesh.scad>;

//BEGIN: use <eval.scad>;
function _isRange(v) = !is_list(v) && !is_string(v) && v[0] != undef;

$careful = false;

function _substr(s, start=0, stop=undef, soFar = "") =
    start >= (stop==undef ? len(s) : stop) ? soFar :
        _substr(s, start=start+1, stop=stop, soFar=str(soFar, s[start]));

function _parseInt(s, start=0, stop=undef, accumulated=0) =
    let( stop = stop==undef ? len(s) : stop )
        start >= stop ? accumulated :
        s[start] == "+" ? _parseInt(s, start=start+1, stop=stop) :
        s[start] == "-" ? -_parseInt(s, start=start+1, stop=stop) :
        let (digit = search(s[start], "0123456789"))
            digit == [] ? 0 : _parseInt(s, start=start+1, stop=stop, accumulated=accumulated*10+digit[0]);

function _findNonDigit(s, start=0) =
    start >= len(s) || s[start]<"0" || s[start]>"9" ? start :
    _findNonDigit(s, start=start+1);

function _replaceChar(s,c1,c2,pos=0,soFar="") =
    pos >= len(s) ? soFar :
    _replaceChar(s,c1,c2,pos=pos+1,soFar=str(soFar, s[pos]==c1 ? c2 : s[pos]));

function _parseUnsignedFloat(s) =
    len(s) == 0 ? 0 :
        let(
            firstNonDigit = _findNonDigit(s),
            decimalPart = s[firstNonDigit]!="." ?
                [firstNonDigit,firstNonDigit] : [firstNonDigit+1, _findNonDigit(s, start=firstNonDigit+1)],
            intPart = _parseInt(s,start=0,stop=firstNonDigit),
            fractionPart = _parseInt(s,start=decimalPart[0],stop=decimalPart[1]),
            baseExp = s[decimalPart[1]]=="e" || s[decimalPart[1]]=="E" ? pow(10,_parseInt(s, start=decimalPart[1]+1)) : 1)
            (intPart+fractionPart*pow(10,-(decimalPart[1]-decimalPart[0])))*baseExp;

function _tail(v) = len(v)>=2 ? [for(i=[1:len(v)-1]) v[i]] : [];
function _isspace(c) = (" " == c || "\t" == c || "\r" == c || "\n" == c );
function _isdigit(c) = ("0" <= c && c <= "9" );
function _isalpha(c) = ("a" <= c && c <= "z") || ("A" <= c && c <= "Z");
function _isalpha_(c) = _isalpha(c)  || c=="_";
function _isalnum_(c) = _isalpha(c) || _isdigit(c) || c=="_";
function _flattenLists(ll) = [for(a=ll) for(b=a) b];

function _spaceSequence(s, start=0, count=0) =
    len(s)>start && _isspace(s[start]) ? _spaceSequence(s, start=start+1, count=count+1) : count;
function _digitSequence(s, start=0, count=0) =
    len(s)>start && _isdigit(s[start]) ? _digitSequence(s, start=start+1,count=count+1) : count;
function _alnum_Sequence(s, start=0, count=0) =
    len(s)>start && _isalnum_(s[start]) ? _alnum_Sequence(s, start=start+1,count=count+1) : count;
function _identifierSequence(s, start=0, count=0) =
    len(s)>start && _isalpha_(s[start]) ? _alnum_Sequence(s, start=start+1, count=count+1) : count;
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
    (s[start]=="!" && s[start+1]=="=") ||
    (s[start]=="&" && s[start+1]=="&") ||
    (s[start]=="|" && s[start+1]=="|") ? 2 : 0;

function _tokenize(s, start=0) =
    start >= len(s) ? [] :
    let(c1=_spaceSequence(s, start=start)) c1>0 ?
        concat([" "], _tokenize(s, start=start+c1)) :
    let(c2=_identifierSequence(s, start=start)) c2>0 ?
        concat([_substr(s, start=start, stop=start+c2)], _tokenize(s, start=start+c2)) :
    let(c3=_positiveRealSequence(s, start=start)) c3>0 ?
        concat([_substr(s, start=start, stop=start+c3)], _tokenize(s, start=start+c3)) :
    let(c4=_multiSymbolOperatorSequence(s, start=start)) c4>0 ?
        concat([_substr(s, start=start, stop=start+c4)], _tokenize(s, start=start+c4)) :
        concat([s[start]], _tokenize(s, start=start+1));


function _endParens(list,start=0,openCount=0,stop=undef) =
    let(stop = stop==undef ? len(list) : stop)
    start >= stop ? (openCount?undef:stop) :
    list[start][0] == ")" ?
            (openCount==1 ? start+1 : _endParens(list,start+1,stop=stop, openCount=openCount-1)) :
    _endParens(list,start+1,stop=stop, openCount=
        list[start][0] == "(" ?
            openCount+1 : openCount);

function _indexInTable(string, table, column=0) =
    let (s=search([string], table, index_col_num=column))
        s[0] == [] ? -1 : s[0][0];

_NAME = 0;
_ARITY = 1;
_PREC = 2;
_ASSOC_DIR = 3;
_ARGUMENTS_FROM_VECTOR = 4;
_OPERATOR = 5;
_EXTRA_DATA = 6;

function _func(op) = [ op, 1, -1, 1, true, op ];

_operators = [
    [ "[", 1, -1, 1, true, "[" ],
    [ "pow", 1, -1, 1, true, "^" ],
    [ "cross", 1, -1, 1, true, "cross" ],
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
    [ "atan2", 1, -1, 1, true, "atan2" ],
    [ "ATAN2", 1, -1, 1, true, "ATAN2" ],
    [ "max", 1, -1, 1, true, "max" ],
    [ "min", 1, -1, 1, true, "min" ],
    [ "concat", 1, -1, 1, true, "concat" ],
    [ "#", 2, 0, -1, false, "#" ],
    [ "^", 2, 0, -1, false, "^" ],
    [ "#-",1, 0.5, 0, true, "-" ],
    [ "#+",1, 0.5, 0, true, "+" ],
    [ "*", 2, 1, 1, false, "*" ],
    [ "/", 2, 1, 1, false, "/" ],
    [ "%", 2, 1, 1, false, "%" ],
    [ "+", 2, 2, 1, true, "+" ],
    [ "-", 2, 2, 1, true, "-" ],
    [ "!=", 2, 3, 1, true, "!=" ],
    [ "==", 2, 3, 1, true, "==" ],
    [ "<=", 2, 3, 1, true, "<=" ],
    [ ">=", 2, 3, 1, true, ">=" ],
    [ "<", 2, 3, 1, true, "<" ],
    [ ">", 2, 3, 1, true, ">" ],
    [ "!", 1, 4, 1, true, "!" ],
    [ "&&", 2, 5, 1, true, "&&" ],
    [ "||", 2, 5, 1, true, "||" ],
    [ "?", 2, 10, -1, true, "?" ],
    [ ":", 2, 10, -1, true, ":" ],
    [ "=", 2, 30, 1, true, "=" ], // for let()
    [ "let", 1, 25, 1, true, "let" ],
    [ ",", 2, 100, 1, true, "," ]
   ];

_binary_or_unary = [ ["-", "#-"], ["+", "#+"], ["#", "["] ];

// insert parentheses in some places to tweak the order of
// operations in those contexts
function _fixBrackets(pretok,start=0) =
    start >= len(pretok) ? [] :
    pretok[start] == "[" ?
        concat(["#", "("], _fixBrackets(pretok,start=start+1)) :
    pretok[start] == "]" ?
        concat([")"], _fixBrackets(pretok,start=start+1)) :
    pretok[start] == "?" ?
        concat([pretok[start],"("], _fixBrackets(pretok,start=start+1)) :
    pretok[start] == ":" ?
        concat([")",pretok[start]], _fixBrackets(pretok,start=start+1)) :
        concat(pretok[start], _fixBrackets(pretok,start=start+1));

// disambiguate operators that can be unary or binary
function _fixUnaries(pretok) =
    [ for (i=[0:len(pretok)-1])
         let (
            a = pretok[i],
            j=_indexInTable(a, _binary_or_unary))
            (0 <= j && (i == 0 || pretok[i-1] == "(" ||
                0 <= _indexInTable(pretok[i-1], _operators)))? _binary_or_unary[j][1] : a ];

function _fixLet1(tok, start=0, stop=undef) =
    let (stop = stop==undef ? len(tok) : stop)
        start >= stop ? [] :
        tok[start][0] == "let"?
           let(endP=_endParens(tok,start=start+1,stop=stop,openCount=0)) concat([concat(tok[start], [_fixLet1(tok,start=start+2,stop=endP-1)])], _fixLet1(tok,start=endP,stop=stop)) :
        concat([tok[start]], _fixLet1(tok,start=start+1,stop=stop));

function _parsePass1(s) =
    let (pretok=_fixUnaries(_fixBrackets(_tokenize(s))))
    _fixLet1(
    [ for (i=[0:len(pretok)-1])
        let (a=pretok[i])
        if (a[0] != " ")
            let (j=_indexInTable(a, _operators))
                j >= 0 ? _operators[j] : [a] ] );

function _prec(op1, pos1, op2, pos2) =
    op1 != undef && op2 == undef ? false :
    op1 == undef && op2 != undef ? true :
    op1 == undef && op2 == undef ? true :
    op1[_ARITY] == 1 && pos1 > pos2 ? true :
    op2[_ARITY] == 1 && pos2 > pos1 ? false :
    op1[_PREC] < op2[_PREC] ? true :
        op2[_PREC] < op1[_PREC] ? false :
            op1[_ASSOC_DIR] * pos1 < op2[_ASSOC_DIR] * pos2;

function _parseLiteralOrVariable(s) =
        s == "PI" ? PI :
        s == "true" ? true :
        s == "false" ? false :
        //s == "undef" ? undef : // TODO: better fix for undef than this hackish one
        _isalpha_(s[0]) ? s :
        _parseUnsignedFloat(s);

function _isoperator(token) = _PREC<len(token);

function _getCandidatesForMainOperator(tok,start,stop) =
   start >= stop ? [] :
   tok[start][0] == "(" ?
        _getCandidatesForMainOperator(tok,_endParens(tok,start=start+1,stop=stop,openCount=1),stop)
        :
        _isoperator(tok[start]) ? concat([[tok[start],start]],_getCandidatesForMainOperator(tok,start+1,stop)) :
        _getCandidatesForMainOperator(tok,start+1,stop);

// Find the operator with least precedence
function _findMainOperatorPos(candidates,start=0) =
    len(candidates) <= start ? undef :
    let(rest=_findMainOperatorPos(candidates,start+1))
    _prec(candidates[rest][0], rest, candidates[start][0], start) ? start : rest;

function _firstOccurrence(c,opName,start=0) =
    start >= len(c) ? undef :
    c[start][0][0] == opName ? c[start] :
        _firstOccurrence(c,opName,start=start+1);

function _mainOperator(tok,start,stop) =
    let(c=_getCandidatesForMainOperator(tok,start,stop),
        pos=_findMainOperatorPos(c),
        m=c[pos])
        m[0][0] == "?" ?
            concat(m, [_firstOccurrence(c,":",start=pos+1)[1]])
            : m;

function _doLets(assignments, final, start=0) =
    start >= len(assignments) ? final :
    assignments[start][0] == "=" ? ["let", ["'", assignments[start][1]], assignments[start][2], _doLets(assignments, final, start=start+1)] : _doLets(assignments, final, start=start+1);

function _letOperator(a,b) =
    let(rawAssignments=_fixCommas(a),
        assignments=rawAssignments[0] == "[[" ?
            _tail(rawAssignments) : [a])
    _doLets(assignments, b);

/* This takes a fully tokenized vector, each element of which is either a line from the _operators table or a vector containing a single non-operator string, and parses it using general parenthesis and operator parsing. Comma expressions for building vectors will be parsed in the next pass. */
function _parseMain(tok,start=0,stop=undef) =
    let( stop= stop==undef ? len(tok) : stop )
        stop <= start ? [] :
        tok[start][0] == "(" && _endParens(tok,start=start+1,stop=stop,openCount=1)==stop ?
            _parseMain(tok,start=start+1,stop=stop-1) :
        let( lp = _mainOperator(tok,start,stop) )
            lp[0] == undef ? ( stop-start>1 ? undef : _parseLiteralOrVariable(tok[start][0]) ) :
            let( op = lp[0], pos = lp[1] )
                op[_NAME] == "?" ?
                    [ op[_OPERATOR], _parseMain(tok,start=start,stop=pos), _parseMain(tok,start=pos+1,stop=lp[2]), _parseMain(tok,start=lp[2]+1,stop=stop) ] :
                op[_NAME] == "let" ?
                    _letOperator( _parseMain(op[_EXTRA_DATA]), _parseMain(tok,start=pos+1,stop=stop)) :
                let(rhs=_parseMain(tok,start=pos+1,stop=stop))
                op[_ARITY] == 2 ?
                    (start==pos ?
                    /* unary use of binary operator */
                    let(j=_indexInTable(op[_OPERATOR], _binary_or_unary)) [ _binary_or_unary[j][1],rhs] : [ op[_OPERATOR], _parseMain(tok,start=start,stop=pos), rhs])
                    : [ op[_OPERATOR], rhs ];


// this upgrades sequences of binary commas to vectors
function _fixCommas(expression) =
    expression[0] == "," ?
        let(a=_fixCommas(expression[1]),
            b=_fixCommas(expression[2]))
            a[0] == "[[" ?
                concat(["[["],concat(_tail(a), [b])) :
                ["[[",a,b]
        :
    is_list(expression) ?
            (expression[1] == [] ? [expression[0]] :
            concat([expression[0]], [for (i=[1:1:len(expression)-1]) _fixCommas(expression[i])]) ) :
            expression;

// fix arguments from vectors
function _fixArguments(expression) =
    let(i=_indexInTable(expression[0], _operators, _OPERATOR))
            i >=0 && _operators[i][_ARGUMENTS_FROM_VECTOR] && expression[1][0] == "[[" ? concat([expression[0]], [for (i=[1:len(expression[1])-1]) _fixArguments(expression[1][i])]) :
/*            expression[0] == "?" ?
                concat([expression[0],expression[1]],[for (i=[1:len(expression[2])-1]) _fixArguments(expression[2][i])]) : */
            is_list(expression) && len(expression)>1 ?
                concat([expression[0]], [for (i=[1:len(expression)-1]) _fixArguments(expression[i])])
                    : expression;

function _optimizedLiteral(x) =
    is_num(x) || is_bool(x) || is_undef(x) ? x : ["'", x];

function _wellDefined(x) =
    is_undef(x) ? false :
    is_num(x) || is_bool(x) ? true :
    x[0] == "'" ? true :
    len(x)==1 ? x[0]!=undef :
    len([for (a=x) if(!_wellDefined(a)) true])==0;

function _optimize(expression) =
    let(x=eval(expression,$careful=true))
        _wellDefined(x) ? _optimizedLiteral(x) :
        expression[0] == "'" ? _optimizedLiteral(x) :
        ! is_string(expression) ?
            concat([expression[0]], [for(i=[1:len(expression)-1]) (i>1 || expression[0] != "let") ?  _optimize(expression[i]) : expression[i]]) :
        expression;

function compileFunction(expression,optimize=true) =
            is_list(expression) ? expression :
            is_num(expression) ? expression :
            let(unoptimized = _fixArguments(_fixCommas(_parseMain(_parsePass1(expression)))))
        optimize ? _optimize(unoptimized) : unoptimized;

function evaluateFunction(expression,variables) = eval(compileFunction(expression,optimize=false),variables);

function _let(v, var, value) = concat([var, value], v);

function _lookupVariable(var, table) =
    let (s=search([var], table, index_col_num=0))
        s[0] == [] ? undef : table[s[0][0]][1];

function _generate(var, range, expr, v) =
    [ for(i=range) eval(expr, _let(v, var, i)) ];

function _haveUndef(v,n=0) =
    n >= len(v) ? false :
    is_undef(v[n]) ? true :
    _haveUndef(v,n=n+1);

function eval(c,v=[]) =
    is_string(c) ? _lookupVariable(c,v) :
    let(op=c[0]) (
    op == undef ? c :
    op == "'" ? c[1] :
    op == "&&" ? (!$careful ? eval(c[1],v)&&eval(c[2],v) :
        (let(c1=eval(c[1],v))
        c1==undef ? undef :
        !c1 ? false :
        let(c2=eval(c[2],v))
        c2==undef ? undef :
        c1 && c2) ) :
    op == "||" ? (!$careful ? eval(c[1],v)||eval(c[2],v) :
        (let(c1=eval(c[1],v))
        c1==undef ? undef :
        c1 ? true :
        let(c2=eval(c[2],v))
        c2==undef ? undef :
        c1 || c2) ) :
    op == "let" ? (!$careful ? eval(c[3],concat([[eval(c[1],v),eval(c[2],v)]], v)) :
            let(c1=eval(c[1],v),c2=eval(c[2],v))
                c1==undef || c2==undef ? undef :
                    eval(c[3],concat([[c1,c2]], v)) ) :
    op == "gen" ? _generate(eval(c[1],v),eval(c[2],v),c[3],v) :
    let(args = [for(i=[1:1:len(c)-1]) eval(c[i],v)])
        $careful && _haveUndef(args) ? undef :
    op == "+" ? (len(args)==1 ? args[0] : args[0]+args[1]) :
    op == "-" ? (len(args)==1 ? -args[0] : args[0]-args[1]) :
    op == "*" ? args[0]*args[1] :
    op == "/" ? args[0]/args[1] :
    op == "%" ? args[0]%args[1] :
    op == "sqrt" ? sqrt(args[0]) :
    op == "^" || op == "pow" ? pow(args[0],args[1]) :
    op == "cos" ? cos(args[0]) :
    op == "sin" ? sin(args[0]) :
    op == "tan" ? tan(args[0]) :
    op == "acos" ? acos(args[0]) :
    op == "asin" ? asin(args[0]) :
    op == "atan" ? atan(args[0]) :
    op == "atan2" ? atan2(args[0],args[1]) :
    op == "COS" ? cos(args[0]*180/PI) :
    op == "SIN" ? sin(args[0]*180/PI) :
    op == "TAN" ? tan(args[0]*180/PI) :
    op == "ACOS" ? acos(args[0])*PI/180 :
    op == "ASIN" ? asin(args[0])*PI/180 :
    op == "ATAN" ? atan(args[0])*PI/180 :
    op == "ATAN2" ? atan2(args[0],args[1])*PI/180 :
    op == "abs" ? abs(args[0]) :
    op == "ceil" ? ceil(args[0]) :
    op == "cross" ? cross(args[0],args[1]) :
    op == "exp" ? exp(args[0]) :
    op == "floor" ? floor(args[0]) :
    op == "ln" ? ln(args[0]) :
    op == "len" ? len(args[0]) :
    op == "log" ? log(args[0]) :
    op == "max" ? (len(args) == 1 ? max(args[0]) : max(args)) :
    op == "min" ? (len(args) == 1 ? min(args[1]) : min(args)) :
    op == "norm" ? norm(args[0]) :
    op == "rands" ? rands(args[0],args[1],args[2],args[3]) :
    op == "round" ? round(args[0]) :
    op == "sign" ? sign(args[0]) :
    op == "[" ? args :
    op == "#" ? args[0][args[1]] :
    op == "<" ? args[0]<args[1] :
    op == "<=" ? args[0]<=args[1] :
    op == ">=" ? args[0]>=args[1] :
    op == ">" ? args[0]>args[1] :
    op == "==" ? args[0]==args[1] :
    op == "!=" ? args[0]!=args[1] :
    op == "!" ? !args[0] :
    op == "?" ? (args[0]?args[1]:args[2]) :
    op == "concat" ? [for (a=args) for(v=a) v] :
    op == "range" ? (len(args)==2 ? [args[0]:args[1]] : [args[0]:args[1]:args[2]]) :
    undef
    );

// per 10,000 operations with "x^3*y-x*y^3"
// 24 sec compile
// 21 sec unoptimized compile
// 22 sec evaluateFunction()
// 0.7 sec eval

// pass1 10 seconds [tokenize: 4 seconds]
// parseMain 6
// fixCommas 0
// fixArguments 3
// optimize 3
/*
echo(compileFunction("x^(2*3)"));
fc = compileFunction("x^3*y-x*y^3",optimize=true);
echo(fc);
echo(eval(fc,[["x",1],["y",1]]));
z=[for(i=[0:9999]) compileFunction("x^3*y-x*y^3",optimize=false)];//fc,[ ["x",1],["y",2] ])];
*/

//z = [for(i=[1:10000]) compileFunction("x^3*y-x*y^3")];
// normal: 23

//function repeat(s, copies, soFar="") = copies <= 0 ? soFar : repeat(s, copies-1, soFar=str(soFar,s));

//END: use <eval.scad>;


// written for tail-recursion
// _subtotals[i] = list[0] + ... + list[i-1]
function _subtotals(list,soFar=[]) =
        len(soFar) >= 1+len(list) ? soFar :
        _subtotals(list,
            let(n1=len(soFar))
            concat(soFar, n1>0 ? soFar[n1-1]+list[n1-1] : 0));

function _flatten(list) = [for (a=list) for(b=a) b];

function _reverseTriangle(t) = [t[2], t[1], t[0]];

function _mod(a,b) =
    let (m=a%b)
    m < 0 ? b+m : m;

// smallest angle in triangle
function _minAngle(p1,p2,p3) =
    let(a = p2-p1,
        b = p3-p1,
        c = p3-p2,
        v1 = a*b,
        v2 = -(c*a))
        v1 == 0 || v2 == 0 ? 0 :
        let( na = norm(a),
             a1 = acos(v1 / (na*norm(b))),
             a2 = acos(v2 / (na*norm(c))) )
        min(a1,a2,180-(a1+a2));

// triangulate square to maximize smallest angle
function _doSquare(points,i11,i21,i22,i12,optimize=1) =
    points[i11]==points[i12] ? [[i11,i21,i22]] :
    points[i21]==points[i22] ? [[i22,i12,i11]] :
    !optimize ? [[i11,i21,i22], [i22,i12,i11]] :
    let (m1 = min(_minAngle(points[i11],points[i21],points[i22]), _minAngle(points[i22],points[i12],points[i11])),
        m2 = min(_minAngle(points[i11],points[i21],points[i12]),
                _minAngle(points[i21],points[i22],points[i12])) )
        m2 <= m1 ? [[i11,i21,i22], [i22,i12,i11]] :
                  [[i11,i21,i12], [i21,i22,i12]];

/*
function _inTriangle(v1,t) = (v1==t[0] || v1==t[1] || v1==t[2]);

function _findTheDistinctVertex(t1,t2) =
    let(in = [for(i=[0:2]) _inTriangle(t1[i],t2)])
    ! in[0] && in[1] && in[2] ? 0 :
    ! in[1] && in[0] && in[2] ? 1 :
    ! in[2] && in[0] && in[1] ? 2 :
    undef;

// make vertex i come first
function _rotateTriangle(t,i) =
    [for (j=[0:2]) t[(j+i)%3]];

function _optimize2Triangles(points,t1,t2) =
    let(i1 = _findTheDistinctVertex(t1,t2))
    i1 == undef ? [t1,t2] :
    let(i2 = _findTheDistinctVertex(t2,t1))
    i2 == undef ? [t1,t2] :
    _doSquare(points,t1[(i1+2)%3],t1[i1],t2[(i2+2)%3],t2[i2],optimize=1);

// a greedy optimization for a strip of triangles most of which adjoin one another; written for tail-recursion
function _optimizeTriangles(points,triangles,position=0,optimize=1,iterations=4) =
        !optimize || position >= iterations*len(triangles) ? triangles :
            _optimizeTriangles(points,
                let(
                    n = len(triangles),
                    position1=position%n,
                    position2=(position+1)%n,
                    opt=_optimize2Triangles(points,triangles[position1],triangles[position2]))
                    [for (i=[0:len(triangles)-1])
                        i == position1 ? opt[0] :
                        i == position2 ? opt[1] :
                            triangles[i]],
                position=position+1);
*/

function _removeEmptyTriangles(points,triangles) =
    [for(t=triangles)
        if(points[t[0]] != points[t[1]] && points[t[1]] != points[t[2]] && points[t[2]] != points[t[0]]) t];

// tail recursion
function _getClosest(points,index,count,ref,best=[undef,undef])
        = count <= 0 ? (best[0]==undef ? index : best[0]) :
          _getClosest(points,index+1,count-1,ref,
            best = best[0] == undef ||
            norm(points[index]-ref) < best[1] ?
            [index,norm(points[index]-ref)] : best);

function _getIndices(points,index1,n1,index2,n2,shift,i,optimize) =
        let (i1=[index2+_mod(i+shift,n2),
                 index2+_mod(i+1+shift,n2)])
        optimize < 0 ?
        [[_getClosest(points,index1,n1,points[i1[0]]),
          _getClosest(points,index1,n1,points[i1[1]])],
          i1] :
        [[index1+floor(i*n1/n2+0.5)%n1,
         index1+floor(((i+1)%n2)*n1/n2+0.5)%n1],
         i1];

// n1 and n2 should be fairly small, so this doesn't need
// tail-recursion
// this assumes n1<=n2
function _tubeSegmentTriangles0(points,index1,n1,index2,n2,shift=0,i=0,soFar=[],optimize=1)
    = i>=n2 ? _removeEmptyTriangles(points,soFar) :
            let(ii = _getIndices(points,index1,n1,index2,n2,shift,i,optimize),
                add = ii[0][0] == ii[0][1] ? [[ii[0][0],ii[1][0],ii[1][1]]] :
                    _doSquare(points,ii[0][0],ii[1][0],ii[1][1],ii[0][1],optimize=optimize))
                _tubeSegmentTriangles0(points,index1,n1,index2,n2,i=i+1,soFar=concat(soFar,add),shift=shift,optimize=optimize);

function _measureQuality(points, triangles, pos=0, sumThinnest=1e100) =
    pos >= len(triangles) ? sumThinnest :
        _measureQuality(points, triangles, pos=pos+1, sumThinnest=min(sumThinnest,_minAngle(points[triangles[pos][0]],points[triangles[pos][1]],points[triangles[pos][2]])));

function _bestTriangles(points,tt, pos=0, best=[0,-1/0]) =
        pos >= len(tt) || len(tt)<=1 ? tt[best[0]] :
        _bestTriangles(points, tt, pos=pos+1,
            best = let(q=_measureQuality(points,tt[pos]))
                        q>best[1] ? [pos,q] : best);

function _getMaxShift(o) = (!o || o==true || o < 0) ? 0 : o-1;

function _tubeSegmentTriangles(points,index1,n1,index2,n2,optimize=1) =
    _bestTriangles(points,[for (shift=[-_getMaxShift(optimize):_getMaxShift(optimize)]) _tubeSegmentTriangles0(points,index1,n1,index2,n2,shift=shift,optimize=optimize)]);

function _tubeSegmentFaces(points,index,n1,n2,optimize=1)
    = n1<n2 ? _tubeSegmentTriangles(points,index,n1,index+n1,n2,optimize=optimize) :
        [for (f=_tubeSegmentTriangles(points,index+n1,n2,index,n1,optimize=optimize)) _reverseTriangle(f)];

function _tubeMiddleFaces(points,counts,subtotals,optimize=1) = [ for (i=[1:len(counts)-1])
           for (face=_tubeSegmentFaces(points,subtotals[i-1],counts[i-1],counts[i],optimize=optimize)) face ];

function _endCaps(counts,subtotals,startCap=true,endCap=true) =
    let( n = len(counts),
         cap1 = counts[0]<=2 || !startCap ? undef : [for(i=[0:counts[0]-1]) i],
         cap2 = counts[n-1]<=2 || !endCap ? undef : [for(i=[counts[n-1]-1:-1:0]) subtotals[n-1]+i] )
       [for (c=[cap1,cap2]) if (c!=undef) c];

function _tubeFaces(sections,startCap=true,endCap=true,optimize=1) =
                let(
        counts = [for (s=sections) len(s)],
        points = _flatten(sections),
        subtotals = _subtotals(counts))
            concat(_tubeMiddleFaces(points,counts,subtotals,optimize=optimize),_endCaps(counts,subtotals,startCap=startCap,endCap=endCap));

function _removeDuplicates1(points,soFar=[[],[]]) =
        len(soFar[0]) >= len(points) ? soFar :
            _removeDuplicates1(points,
               let(
                mapSoFar=soFar[0],
                pointsSoFar=soFar[1],
                j=len(mapSoFar),
                k=search([points[j]], pointsSoFar)[0])
                k == []? [concat(mapSoFar,[len(pointsSoFar)]),
                            concat(pointsSoFar,[points[j]])] :
                           [concat(mapSoFar,[k]),pointsSoFar]);

function _removeDuplicates(points, faces) =
    let(fix=_removeDuplicates1(points),
        map=fix[0],
        newPoints=fix[1],
        newFaces=[for(f=faces) [for(v=f) map[v]]])
            [newPoints, newFaces];

function pointsAndFaces(sections,startCap=true,endCap=true,optimize=1) =
        let(
            points0=_flatten(sections),
            faces0=_tubeFaces(sections,startCap=startCap,endCap=endCap,optimize=optimize))
        _removeDuplicates(points0,faces0);

function sectionZ(section,z) = [for(xy=section) [xy[0],xy[1],z]];
function sectionX(section,x) = [for(yz=section) [x,yz[0],yz[1]]];
function sectionY(section,y) = [for(xz=section) [xz[0],y,xz[1]]];


function shiftSection(section,delta) = [for(p=section) [for(i=[0:len(delta)-1]) (p[i]==undef?0:p[i])+delta[i]]];

// the optimize parameter can be:
//   -1: nearest neighbor mesh optimization; this can produce meshes that are not watertight, and hence is not recommended unless you know what you are doing
//   0: no optimization at all
//   1: minimal optimization at the quad level
//   n>1: shift corresponding points in different layers by up to n-1 points to try to have the best triangles
module tubeMesh(sections,startCap=true,endCap=true,optimize=1) {
    pAndF = pointsAndFaces(sections,startCap=startCap,endCap=endCap,optimize=optimize);
    polyhedron(points=pAndF[0],faces=pAndF[1]);
}

// increase number of points from len(section) to n
function _interpolateSection(section,n) =
        let(m=len(section))
        n == m ? section :
        n < m ? undef :
            [for(i=[0:m-1])
                let(cur=floor(i*n/m),
                    k=floor((i+1)*n/m)-cur,
                    i2=(i+1)%m)
                    for(j=[0:k-1])
                        let(t=j/k)
                            section[i]*(1-t)+section[i2]*t];

function arcPoints(r=10,d=undef,start=0,end=180,z=undef) =
            let(r=d==undef?r:d/2,
                n=getPointsAround(abs(end-start)))
                    r*[for(i=[0:n])
                        let(angle=start+i*(end-start)/n) [cos(angle),sin(angle)]];

function ngonPoints(n=4,r=10,d=undef,rotate=0,z=undef) =
            let(r=d==undef?r:d/2)
            z==undef ?
            r*[for(i=[0:n-1]) let(angle=i*360/n+rotate) [cos(angle),sin(angle)]] :
            [for(i=[0:n-1]) let(angle=i*360/n+rotate) [r*cos(angle),r*sin(angle),z]];

function starPoints(n=10,r1=5,r2=10,rotate=0,z=undef) =
          z==undef ?
            [for(i=[0:2*n-1]) let(angle=i*180/n+rotate) (i%2?r1:r2) * [cos(angle),sin(angle)]] :
            [for(i=[0:2*n-1]) let(angle=i*180/n+rotate, r=i%2?r1:r2) [r*cos(angle),r*sin(angle),z]];

function roundedSquarePoints(size=[10,10],radius=2,z=undef) =
    let(n=$fn?$fn:32,
        x=len(size)>=2 ? size[0] : size,
        y=len(size)>=2 ? size[1] : size,
        centers=[[x-radius,y-radius],[radius,y-radius],[radius,radius],[x-radius,radius]],
        section=[for(i=[0:n-1])
            let(center=centers[floor(i*4/n)],
                angle=360*i/n)
            center+radius*[cos(angle),sin(angle)]])
        z==undef ? section : sectionZ(section,z);

function getPointsAround(radius, angle=360) =
    max(3, $fn ? ceil($fn*angle/360) :
        max(floor(0.5+angle/$fa), floor(0.5+2*radius*PI*angle/360/$fs)));

// warning: no guarantee of perfect convexity
module mySphere(r=10,d=undef) {
    GA = 2.39996322972865332 * 180 / PI;
    radius = d==undef ? r : d/2;
    pointsAround = getPointsAround(radius);
    numSlices0 = (pointsAround + pointsAround % 2)/2;
    numSlices = numSlices0 + (numSlices0%2);
    sections = radius*[for(i=[0:numSlices])
                    i == 0 ? [[0,0,-1]] :
                    i == numSlices ? [[0,0,1]] :
                    let(
                        lat = (i-numSlices/2)/(numSlices/2)*90,
                        z1 = sin(lat),
                        r1 = cos(lat),
                        count = max(3,floor(0.5 + pointsAround * abs(r1))))
                        ngonPoints(count,r=r1,z=z1)];
    data = pointsAndFaces(sections,optimize=-1);
    polyhedron(points=data[0], faces=data[1]);
}

function twistSectionXY(section,theta,autoShift=false) =
    let(
    n = len(section),
    shift=autoShift ? floor(n*_mod(theta,360)/360) : 0)
    [for (a=[0:len(section)-1])
        let(p=section[_mod(a-shift,n)])
        [for(i=[0:len(p)-1])
        i == 0 ? p[0]*cos(theta)-p[1]*sin(theta) :
        i == 1 ? p[0]*sin(theta)+p[1]*cos(theta) :
        p[i]]];

module morphExtrude(section1,section2=undef,height=undef,twist=0,numSlices=10,curve="t",curveParams=[[]],startCap=true,endCap=true,optimize=1) {

    section2 = section2==undef ? section1 : section2;

    fc = compileFunction(curve);
    function getCurve(t) = (curve=="t" ? t : eval(fc,concat([["t",t]],curveParams)));

    n = max(len(section1),len(section2));

    section1interp = _interpolateSection(section1,n);
    section2interp = _interpolateSection(section2,n);
    sections = height == undef ?
                      [for(i=[0:numSlices])
                        let(t=i/numSlices)
                        (1-t)*section1interp+t*section2interp] :
                      [for(i=[0:numSlices])
                        let(t=i/numSlices,
                            t1=getCurve(t),
                            theta = -t*twist,
                            section=(1-t1)*section1interp+t1*section2interp)
                        twistSectionXY(sectionZ(section,height*t),theta)];

    tubeMesh(sections,startCap=startCap,endCap=endCap,optimize=optimize);
}

module cone(r=10,d=undef,height=10) {
    radius = d==undef ? r : d/2;

    pointsAround = getPointsAround(radius);

    morphExtrude(ngonPoints(n=pointsAround,r=radius), [[0,0]], height=height,optimize=0);
}

module prism(base=[[0,0,0],[1,0,0],[0,1,0]], vertical=[0,0,1]) {
    morphExtrude(base,[for(v=base) v+vertical],numSlices=1);
}


//END: use <tubemesh.scad>;


//BEGIN: use <bezier.scad>;
/*
Copyright (c) 2017 Alexander R. Pruss.

Licensed under any Creative Commons Attribution license you like or under the
following MIT License.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/


// Public domain Bezier stuff from www.thingiverse.com/thing:8443
function BEZ03(u) = pow(1-u, 3);
function BEZ13(u) = 3*u*pow(1-u,2);
function BEZ23(u) = 3*pow(u,2)*(1-u);
function BEZ33(u) = pow(u,3);
function PointAlongBez4(p0, p1, p2, p3, u) =
	BEZ03(u)*p0+BEZ13(u)*p1+BEZ23(u)*p2+BEZ33(u)*p3;
// End public domain Bezier stuff
function d2BEZ03(u) = 6*(1-u);
function d2BEZ13(u) = 18*u-12;
function d2BEZ23(u) = -18*u+6;
function d2BEZ33(u) = 6*u;

function worstCase2ndDerivative(p0, p1, p2, p3, u1, u2)
    = norm([
        for(i=[0:len(p0)-1])
            max([for(u=[u1,u2])
                d2BEZ03(u)*p0[i]+d2BEZ13(u)*p1[i]+
                d2BEZ23(u)*p2[i]+d2BEZ33(u)*p3[i]]) ]);

function neededIntervalLength(p0,p1,p2,p3,u1,u2,tolerance)
    = let(d2=worstCase2ndDerivative(p0,p1,p2,p3,u1,u2))
        d2==0 ? u2-u1+1 : sqrt(2*tolerance/d2);

function REPEAT_MIRRORED(v,angleStart=0,angleEnd=360) = ["m",v,angleStart,angleEnd];
function SMOOTH_REL(x) = ["r",x];
function SMOOTH_ABS(x) = ["a",x];
function SYMMETRIC() = ["r",1];
function OFFSET(v) = ["o",v];
function SHARP() = OFFSET([0,0,0]);
function LINE() = ["l",0];
function POLAR(r,angle) = OFFSET(r*[cos(angle),sin(angle)]);
function POINT_IS_SPECIAL(v) = (v[0]=="r" || v[0]=="a" || v[0]=="o" || v[0]=="l");

// this does NOT handle offset type points; to handle those, use DecodeBezierOffsets()
function getControlPoint(cp,node,otherCP,otherNode,nextNode) =
    let(v=node-otherCP) (
    cp[0]=="r" ? node+cp[1]*v:
    cp[0]=="a" ? (
        norm(v)<1e-9 ? node+cp[1]*(node-otherNode)/norm(node-otherNode) : node+cp[1]*v/norm(v) ) :
    cp[0]=="l" ? (2*node+nextNode)/3 :
        cp );

function onLine2(a,b,c,eps=1e-4) =
    norm(c-a) <= eps ? true
        : norm(b-a) <= eps ? false /* to be safe */
            : abs((c[1]-a[1])*(b[0]-a[0]) - (b[1]-a[1])*(c[0]-a[0])) <= eps * eps && norm(c-a) <= eps + norm(b-a);

function isStraight2(p1,c1,c2,p2,eps=1e-4) =
    len(p1) == 2 &&
    onLine2(p1,p2,c1,eps=eps) && onLine2(p2,p1,c2,eps=eps);

function Bezier2(p,index=0,precision=0.05,rightEndPoint=true,optimize=true) = let(nPoints=
        max(1, precision < 0 ?
                    ceil(1/
                        neededIntervalLength(p[index],p[index+1],p[index+2],p[index+3],0,1,-precision))
                    : ceil(1/precision)) )
    optimize && isStraight2(p[index],p[index+1],p[index+2],p[index+3]) ? (rightEndPoint?[p[index+0],p[index+3]]:[p[index+0]] ) :
    [for (i=[0:nPoints-(rightEndPoint?0:1)]) PointAlongBez4(p[index+0],p[index+1],p[index+2],p[index+3],i/nPoints)];

function flatten(listOfLists) = [ for(list = listOfLists) for(item = list) item ];


// p is a list of points, in the format:
// [node1,control1,control2,node2,control3, control4,node3, ...]
// You can replace inner control points with:
//   SYMMETRIC: uses a reflection of the control point on the other side of the node
//   SMOOTH_REL(x): like SYMMETRIC, but the distance of the control point to the node is x times the distance of the other control point to the node
//   SMOOTH_ABS(x): like SYMMETRIC, but the distance of the control point to the node is exactly x
// You can also replace any control point with:
//   OFFSET(v): puts the control point at the corresponding node plus the vector v
//   SHARP(): equivalent to OFFSET([0,0])
//   LINE(): when used for both control points between two nodes, generates a straight line
//   POLAR(r,angle): like OFFSET, except the offset is specified in polar coordinates

function DecodeBezierOffset(control,node) = control[0] == "o" ? node+control[1] : control;

function _mirrorMatrix(normalVector) = let(v = normalVector/norm(normalVector)) len(v)<3 ? [[1-2*v[0]*v[0],-2*v[0]*v[1]],[-2*v[0]*v[1],1-2*v[1]*v[1]]] : [[1-2*v[0]*v[0],-2*v[0]*v[1],-2*v[0]*v[2]],[-2*v[0]*v[1],1-2*v[1]*v[1],-2*v[1]*v[2]],[-2*v[0]*v[2],-2*v[1]*v[2],1-2*v[2]*v[2]]];

function _correctLength(p,start=0) =
    start >= len(p) || p[start][0] == "m" ? 3*floor(start/3)+1 : _correctLength(p,start=start+1);

function _trimArray(a, n) = [for (i=[0:n-1]) a[i]];

function _transformPoint(matrix,a) =
    let(n=len(a))
        len(matrix[0])==n+1 ?
            _trimArray(matrix * concat(a,[1]), n)
            : matrix * a;

function _transformPath(matrix,path) =
    [for (a=path) _transformPoint(matrix,a)];

function _reverseArray(array) = let(n=len(array)) [for (i=[0:n-1]) array[n-1-i]];

function _stitchPaths(a,b) = let(na=len(a)) [for (i=[0:na+len(b)-2]) i<na? a[i] : b[i-na+1]-b[0]+a[na-1]];

// replace all OFFSET/SHARP/POLAR points with coordinates
function DecodeBezierOffsets(p) = [for (i=[0:_correctLength(p)-1]) i%3==0?p[i]:(i%3==1?DecodeBezierOffset(p[i],p[i-1]):DecodeBezierOffset(p[i],p[i+1]))];

function _mirrorPaths(basePath, control, start) =
    control[start][0] == "m" ? _mirrorPaths(_stitchPaths(basePath,_reverseArray(_transformPath(_mirrorMatrix( control[start][1] ),basePath))), control, start+1) : basePath;

function DecodeSpecialBezierPoints(p0) =
    let(
        l = _correctLength(p0),
        doMirror = len(p0)>l && p0[l][0] == "m",
        p=DecodeBezierOffsets(p0),
        basePath = [for (i=[0:l-1]) i%3==0?p[i]:(i%3==1?getControlPoint(p[i],p[i-1],p[i-2],p[i-4],p[i+2]):getControlPoint(p[i],p[i+1],p[i+2],p[i+4],p[i-2]))])
        doMirror ? _mirrorPaths(basePath, p0, l) : basePath;

function Distance2D(a,b) = sqrt((a[0]-b[0])*(a[0]-b[0])+(a[1]-b[1])*(a[1]-b[1]));

function RemoveDuplicates(p,eps=0.00001) = let(safeEps = eps/len(p)) [for (i=[0:len(p)-1]) if(i==0 || i==len(p)-1 || Distance2D(p[i-1],p[i]) >= safeEps) p[i]];

function Bezier(p,precision=0.05,eps=0.00001,optimize=true) = let(q=DecodeSpecialBezierPoints(p), nodes=(len(q)-1)/3) RemoveDuplicates(flatten([for (i=[0:nodes-1]) Bezier2(q,optimize=optimize,index=i*3,precision=precision,rightEndPoint=(i==nodes-1))]),eps=eps);

function GetSplineAngle(a,b,c) =
    a==c && b==a ? 0 :
    a==c ? let(ba=b-a) atan2(ba[1],ba[0]) :
    let(ca=c-a) atan2(ca[1],ca[0]);

/*    let(ba=norm(b-a),cb=norm(c-b))
        ba == 0 && cb == 0 ? 0 :
    let(v = ba == 0 ? c-b :
            cb == 0 ? b-a :
            (c-b)*norm(b-a)/norm(c-b)+(b-a))
    atan2(v[1],v[0]); */

// do a spline around b
function SplineAroundPoint(a,b,c,tension=0.5,includeLeftCP=true,includeRightCP=true) =
    includeLeftCP && includeRightCP ?
        [POLAR(tension*norm(a-b),GetSplineAngle(c,b,a)),b,POLAR(tension*norm(c-b),GetSplineAngle(a,b,c))] :
    includeLeftCP ?
        [POLAR(tension*norm(a-b),GetSplineAngle(c,b,a)),b] :
    includeRightCP ?
        [b,POLAR(tension*norm(c-b),GetSplineAngle(a,b,c))] :
        [b];

function BezierSmoothPoints(points,tension=0.5,closed=false)
    = let (n=len(points))
        flatten(
        closed ? [ for (i=[0:n]) SplineAroundPoint(points[(n+i-1)%n],points[i%n],points[(i+1)%n],tension=tension,includeLeftCP=i>0,includeRightCP=i<n) ] :
        [ for (i=[0:n-1])
            SplineAroundPoint(
            i==0 ? 2*points[0]-points[1] : points[(n+i-1)%n],
            points[i],
            i==n-1 ? 2*points[n-1]-points[n-2] : points[(i+1)%n],tension=tension,includeLeftCP=i>0,includeRightCP=i<n-1  ) ]);

module BezierVisualize(p,precision=0.05,eps=0.00001,lineThickness=0.25,controlLineThickness=0.125,nodeSize=1) {
    $fn = 16;
    dim = len(p[0]);
    module point(size) {
        if (dim==2)
            circle(d=size);
        else
            sphere(d=size);
    }
    p1 = DecodeSpecialBezierPoints(p);
    l = Bezier(p1,precision=precision,eps=eps);
    for (i=[0:len(l)-2]) {
        hull() {
            translate(l[i]) point(lineThickness);
            translate(l[i+1]) point(lineThickness);
        }
    }
    for (i=[0:len(p1)-1]) {
        if (i%3 == 0) {
            color("black") translate(p1[i]) point(nodeSize);
        }
        else {
            node = i%3 == 1 ? i-1 : i+1;
            color("red") translate(p1[i]) point(nodeSize);
            color("red") hull() {
                translate(p1[node]) point(controlLineThickness);
                translate(p1[i]) point(controlLineThickness);
            }
        }
    }
}


//END: use <bezier.scad>;


//BEGIN: use <paths.scad>;
function sumTo(v,n) = n<=0 ? 0 : v[n-1]+sumTo(v,n-1);
function sum(v) = sumTo(v,len(v));
function interpolationData(v) = let(
    n=len(v)-1,
    d=[for (i=[0:n-1]) norm(v[i]-v[i+1])],
    sumD=[for (i=[0:n]) sumTo(d,i)],
    totalD=sumD[n])
        [d,sumD,v,totalD];
function totalLength(interp) = interp[3];
function interpolatePoints(a,b,t) = (1-t)*a+(t)*b;
function findSegmentByDistance(sumD,distance) = let(
    found = [for(i=[0:len(sumD)-1]) if(sumD[i]<=distance && distance<sumD[i+1]) i])
        len(found)>0 ? found[0] : -1;
function interpolateByDistance(interp,distance) = let(
    n=len(interp[1])-1,
    d=interp[0],
    sumD=interp[1],
    v=interp[2],
    totalD=interp[3],
    i=findSegmentByDistance(sumD,distance))
        i<0 ? (distance<totalD/2 ? v[0] : v[n]) :
            interpolatePoints(v[i],v[i+1],(distance-sumD[i])/d[i]);
function get2DNormalBetweenPoints(a,b) = let(
    v = (b-a)/norm(b-a))
        [v[1],-v[0]];
function getTangentByDistance(interp,distance) = let(
    n=len(interp[1])-1,
    d=interp[0],
    sumD=interp[1],
    v=interp[2],
    totalD=interp[3],
    i0=findSegmentByDistance(sumD,distance),
    i = i0 < 0 ? (distance<totalD/2 ? 0 : n-1) : i0)
        (v[i+1]-v[i])/norm(v[i+1]-v[i]);

function interpolateByParameter(interp,t) = interpolateByDistance(interp,t*totalLength(interp));
function singleInterpolateByDistance(v,distance) = interpolateByDistance(interpolationData(v),distance);
function singleInterpolateByParameter(v,t) = interpolateByParameter(interpolationData(v),t);
function measurePath(v) = totalLength(interpolationData(v));

function findCoordinateIntersection2(a,b,index,value) =
    a[index] == value ? a :
        b[index] == value ? b :
            let( t=(value-a[index]) / (b[index]-a[index]))
                (1-t)*a+t*b;

function findCoordinateIntersections(path,index,value) =
    [for (i=[0:len(path)-2]) if ((path[i][index]-value)*(path[i+1][index]-value) <= 0) findCoordinateIntersection2(path[i],path[i+1],index,value)];

function mirrorMatrix(normalVector) = let(v = normalVector/norm(normalVector)) len(v)<3 ? [[1-2*v[0]*v[0],-2*v[0]*v[1]],[-2*v[0]*v[1],1-2*v[1]*v[1]]] : [[1-2*v[0]*v[0],-2*v[0]*v[1],-2*v[0]*v[2]],[-2*v[0]*v[1],1-2*v[1]*v[1],-2*v[1]*v[2]],[-2*v[0]*v[2],-2*v[1]*v[2],1-2*v[2]*v[2]]];

function trimArray(a, n) = [for (i=[0:n-1]) a[i]];

function transformPoint(matrix,a) =
    let(n=len(a))
        len(matrix[0])==n+1 ?
            trimArray(matrix * concat(a,[1]), n)
            : matrix * a;

function transformPath(matrix,path) =
    [for (a=path) transformPoint(matrix,a)];

function reverseArray(array) = let(n=len(array)) [for (i=[0:n-1]) array[n-1-i]];

function stitchPaths(a,b) = let(na=len(a)) [for (i=[0:na+len(b)-2]) i<na? a[i] : b[i-na+1]-b[0]+a[na-1]];

//interp = interpolationData([[1,2],[2,3],[1,2]]);
//echo(singleInterpolateByParameter([[1,1],[2,2],[3,1]],0.75));
//echo(measurePath([[1,2],[2,3],[1,2]]));


//END: use <paths.scad>;




module dummy() {}

module horn(taper=5,diameter=38,height=180,twists=1.75,lobes=1,lobeOffset=5,slices=40,bottomAngle=20,bottomTension=40,topOffset=60,topTension=50,topAngle=20,
    bottomAngleFeatheringParameter=0.5) {
    nudge = 0.01;

    r = diameter/2;
    precision = 1/slices;

    function base(twistAngle) = lobes == 1 ? [ for(i=[0:5:360]) r*[cos(i),sin(i)]] : [ for(i=[0:5:360]) (r+lobeOffset*abs(cos((i)*lobes/2)))*[cos(i-twistAngle),sin(i-twistAngle)]];

    edge = [ [r,0],SHARP(),SHARP(),
             [taper,height-1.5*taper],SMOOTH_ABS(.25*taper),OFFSET([taper,0]),
            [0,height] ];
    core = [ [0,0],POLAR(bottomTension,90+bottomAngle),POLAR(topTension,-90-topAngle),[topOffset,height] ];

    profile = Bezier(edge,precision=precision,optimize=false);
    corePath = Bezier(core,precision=precision,optimize=false);
    coreInterp = interpolationData(corePath);

    function coreAt(t) = interpolateByParameter(coreInterp,t);
    function angleAt(t) =
        let(b=coreAt(t+0.001),
            a=coreAt(t),
            angle=-atan2(b[0]-a[0],b[1]-a[1]),
            u=bottomAngleFeatheringParameter*bottomTension/height)
            t<=u ? angle*t/u : angle;

    function xzRotate(angle,point) =
        let(m=[[cos(angle),0,-sin(angle)],
               [0,1,0],
               [sin(angle),0,cos(angle)]])
           m*point;

    function tiltSection(section,fakeHeight) =
        let(t = fakeHeight/height,
            p = coreAt(t))
            [for(v=section) [p[0],0,p[1]] + xzRotate(angleAt(t), [v[0],v[1],0])];

    sections = [for(p=profile) tiltSection(p[0]/r*base(p[1]/height*360*twists),p[1])];

    tubeMesh(sections);
}

module mountSlit(mountSlitThickness=4, mountSlitDepth=10, mountSlitHeight=14) {
    if (mountSlitThickness>0) {
        nudge = 0.01;
        hull() {
            cube([mountSlitThickness+2*tolerance,mountSlitDepth+2*tolerance,2*mountSlitHeight+2*tolerance+nudge],center=true);
            translate([0,0,2*tolerance+mountSlitHeight+max(mountSlitThickness/2,mountSlitDepth/2)]) cube([nudge,nudge,nudge],center=true);
        }
    }
}

difference() {
    scale(rescale)
        mirror([flipHorizontally?1:0,0,0])
            rotate([0,0,rotation])
                horn(taper=taper,diameter=diameter,height=height,twists=twists,lobes=lobes,lobeOffset=lobeOffset,slices=slices,bottomAngle=bottomAngle,bottomTension=bottomTension,topOffset=topOffset,topTension=topTension,topAngle=topAngle,bottomAngleFeatheringParameter=bottomAngleFeatheringParameter);

    translate([mountSlitXOffset,mountSlitYOffset,0])
        mountSlit(mountSlitThickness=mountSlitThickness,mountSlitDepth=mountSlitDepth,mountSlitHeight=mountSlitHeight);
}
