// This file was processed by resolve-include.py [https://github.com/arpruss/miscellaneous-scad/blob/master/scripts/resolve-include.py] 
// to include  all the dependencies inside one file.

snapLength = 32;
transitionAngle = 8;
snapWall = 1.5;
snapAngle = 230;
switchOffset = 1.25;
switchAreaLength = 6;
preSwitchLength = 3;
switchAreaAngularSize = 20;
cutLength = 4;
laserDiameter = 14.13;
laserTolerance = 0;
screwHole = 4;
screwOffsetFromEdge = 3;
hotshoe = true;
hotshoeWidthTolerance = 0.4;
hotshoeThicknessTolerance = 0.3;
mountWidth = 30; // irrelevant in hotshoe mode
mountWall = 2;  // irrelevant in hotshoe mode
mountOffset = 0;  // irrelevant in hotshoe mode
mountBarThickness = 10;  // irrelevant in hotshoe mode
mountRadiusOfCurvature = 0;  // 0 for flat; irrelevant in hotshoe mode
switchOnRight = true;
layers = 60;

module end_of_parameters_dummy() {}


//BEGIN DEPENDENCY: use <tubemesh.scad>;

//BEGIN DEPENDENCY: use <eval.scad>;
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
    [ "interpolate", 1, -1, 1, true, "interpolate" ],
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

// TODO: remove the need for this
function _removeDup(v,soFar=[],pos=0) = [for(i=[0:len(v)-1]) if(i==0 || v[i-1][0]!=v[i][0]) v[i]];

function _interpolate1(a,b,x) = (x-a[0])/(b[0]-a[0])*(b[1]-a[1])+a[1];

function _isInterp(v) = is_list(v) && is_list(v[0]) && is_num(v[0][0]);

function _interpolate(x,f,pos=-1) =
    pos < 0 ? _interpolate(x,_removeDup(f),pos=0) :
    pos >= len(f)-1 ?
    _interpolate1(f[len(f)-2],f[len(f)-1],x) :
    pos == 0 && x < f[0][0] ? _interpolate1(f[1],f[0],x) :
    x <= f[pos+1][0] ? _interpolate1(f[pos],f[pos+1],x) : _interpolate(x,f,pos=pos+1);

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
    op == "interpolate" ? _interpolate(args[0],args[1]) :
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

//END DEPENDENCY: use <eval.scad>;


//BEGIN DEPENDENCY: use <triangulation.scad>;
function _furthestAwayFromPoint(points,poly,z,bestD=-1,bestPos=0,pos=0) =
    len(poly) <= pos ? bestPos :
    norm(points[poly[pos]]-z) > bestD ? _furthestAwayFromPoint(points,poly,z,bestD=norm(points[poly[pos]]-z),bestPos=pos,pos=pos+1) :
    _furthestAwayFromPoint(points,poly,z,bestD=bestD,bestPos=bestPos,pos=pos+1);

function _triangleArea(a,b,c) = norm(cross(b-a,c-a))/2;

function _furthestAwayFromLine(points,poly,z1,z2,bestArea=-1,bestPos=0,pos=0) =
    len(poly) <= pos ? bestPos :
    _triangleArea(z1,z2,points[poly[pos]]) > bestArea ? _furthestAwayFromLine(points,poly,z1,z2,bestArea=_triangleArea(z1,z2,points[poly[pos]]),bestPos=pos,pos=pos+1) :
    _furthestAwayFromLine(points,poly,z1,z2,bestArea=bestArea,bestPos=bestPos,pos=pos+1);

function normalize(v) = v/norm(v);

function _winding(points,poly,sum=0,pos=0) =
    pos >= len(poly) ? sum :
    _winding(points,poly,sum=sum+(points[poly[(pos+1)%len(poly)]][0]-points[poly[pos]][0])*(points[poly[(pos+1)%len(poly)]][1]+points[poly[pos]][1]),pos=pos+1);

function _isCCW(points,poly) =
_winding(points,poly) < 0;

function identifyPlane(points,poly) =
let(i=_furthestAwayFromPoint(points,poly,points[poly[0]]),
           j=_furthestAwayFromLine(points,poly,points[poly[0]],points[poly[i]]),
           normal = cross(points[poly[i]]-points[poly[0]],points[poly[j]]-points[poly[0]]),
           a = points[poly[i]]-points[poly[0]],
           b = cross(normal,a),
           cs = [points[poly[0]],normalize(a),normalize(b),normalize(normal)])
           cs;

function projectPoint(coordsys,p) = let(v=p-coordsys[0],
           vp=v-(v*coordsys[3])*coordsys[3]) [vp*coordsys[1],vp*coordsys[2]];

function projectPoints(coordsys,p) = [for(v=p) projectPoint(coordsys,v)];

function _removeDuplicates(points,poly)
    = [for (i=[0:len(poly)-1]) if (points[poly[(i+1)%len(poly)]] != points[poly[i]]) poly[i]];

function triangulate(points,poly=undef,holes=[]) =
    let(poly = poly==undef ? [for(i=[0:1:len(points)-1]) i] : poly)
    let(poly = _removeDuplicates(points,poly),
        holes = [for(h=holes) _removeDuplicates(points,h)])
    len(points[poly[0]]) == 2 ?triangulate2D(points,poly,holes) : triangulate2D(projectPoints(identifyPlane(points,poly),points),poly,holes);

function _leftMostHoleData(points,holes,indexOfHole=0,indexInHole=0,bestData=undef,) =
    indexOfHole >= len(holes) ? bestData[1] :
    indexInHole >= len(holes[indexOfHole]) ? _leftMostHoleData(points,holes,indexOfHole=indexOfHole+1,indexInHole=0,bestData=bestData) :
    bestData==undef || points[holes[indexOfHole][indexInHole]][0] < bestData[0] ? _leftMostHoleData(points,holes,indexOfHole=indexOfHole,indexInHole=indexInHole+1,bestData=[points[holes[indexOfHole][indexInHole]][0], [indexOfHole, indexInHole]]) :
    _leftMostHoleData(points,holes,indexOfHole=indexOfHole,indexInHole=indexInHole+1,bestData=bestData);

function _rightMostPrimaryData(points,primary,limitX,pos=0,bestData=undef) =
    pos >= len(primary) ?  bestData[1] :
    points[primary[pos]][0] < limitX && (bestData==undef || points[primary[pos]] > bestData[0]) ?  _rightMostPrimaryData(points,primary,limitX,pos=pos+1,bestData=[points[primary[pos]][0],pos]) :
    _rightMostPrimaryData(points,primary,limitX,pos=pos+1,bestData=bestData);

function _makeLoop(start,loop,index) = concat([start],[for(i=[0:len(loop)]) loop[(i+index)%len(loop)]],[start]);

function _addLoop(primary,holes,indexWithinPrimary,indexOfHole,indexWithinHole) =
    let(hole=holes[indexOfHole],
        newHoles=[for(i=[0:len(holes)-1]) if(i!=indexOfHole) holes[i]],
        newPrimary=[for(i=[0:len(primary)-1]) for(p= i!=indexWithinPrimary ? [primary[i]] : _makeLoop(primary[i],hole,indexWithinHole)) p])
       [newPrimary,newHoles];

function _removeHoles1(points,primary,holes) =
    len(holes) == 0 ? primary :
    let(holeData=_leftMostHoleData(points,holes),
        indexOfHole=holeData[0],
        indexWithinHole=holeData[1],
        holePointIndex=holes[indexOfHole][indexWithinHole],
        hp=points[holePointIndex],
        indexWithinPrimary=_rightMostPrimaryData(points,primary,hp[0]),
        primaryAndHoles=_addLoop(primary,holes,indexWithinPrimary,indexOfHole,indexWithinHole)) _removeHoles1(points,primaryAndHoles[0],primaryAndHoles[1]);

function _removeHolesAndReorient(points,primary,holes) =    let(points=_isCCW(points,primary)?points:[for(p=points) [p[0],-p[1]]])
        [points,_removeHoles1(points,primary,[for(h=holes) _orient(newPoints,h,ccw=false)])];

function mod(a,b) = let(m=a%b) m < 0 ? m+b : m;

function _delPoint(v,i) = [for(j=[0:1:len(v)-1]) if(i!=j) v[j]];

function _isCCWTriangle(a,b,c) = cross(b-a,c-a) >= 0;

function _crosses(points,poly,a,b,ignore,pos=0) =
    pos >= len(poly) ? false :
    ignore != pos && ignore !=  mod(pos+1,len(poly)) && _isCross(points[poly[pos]],points[poly[mod(pos+1,len(poly))]],a,b) ? true : _crosses(points,poly,a,b,pos=pos+1);

function _isReflex(points,poly,i) =
    let(n=len(poly),
        a=points[poly[mod(i-1,n)]],
        b=points[poly[i]],
        c=points[poly[mod(i+1,n)]]) cross(b-a,c-b) < 0;

function _checkEar2(points,poly,a,b,c,j) =
   let(p=points[poly[mod(j,len(poly))]],
       c1=cross(p-a,b-a))
       ! ( c1*cross(p-b,c-b) >0 && c1*cross(p-c,a-c)>0 );

function _checkEar(points,poly,a,b,c,i,j) =
    mod(j,len(poly))==mod(i-1,len(poly)) ? true :
    _isReflex(points,poly,mod(j,len(poly))) && ! _checkEar2(points,poly,a,b,c,j) ? false :
    _checkEar(points,poly,a,b,c,i,j+1);

function _isEar(points,poly,i) =
    _isReflex(points,poly,i) ? false :
    let(n=len(poly),
        a=points[poly[mod(i-1,n)]],
        b=points[poly[i]],
        c=points[poly[mod(i+1,n)]],
        j=i+2)
        _checkEar(points,poly,a,b,c,i,i+2);

function _findEar(points,poly,pos=0) =
    assert(pos<len(poly))
    _isEar(points,poly,pos) ? pos : _findEar(points,poly,pos=pos+1);

function _cutEar(points,poly) =
    let(n=len(poly),
        i=_findEar(points,poly))
        _delPoint(poly,i);

function _getEar(points,poly) =
    let(n=len(poly),
        i=_findEar(points,poly))
        [poly[mod(i-1,n)],poly[i],poly[mod(i+1,n)]];

function _reverse(v) = [for(i=[len(v)-1:-1:0]) v[i]];

function _orient(points,poly,ccw=true) = !!_isCCW(points,poly) == ccw ? poly : _reverse(poly);

function triangulate2D(points,poly,holes=[],soFar=[]) =
    let(pp = _removeHolesAndReorient(points,poly,holes),
    points=pp[0],
    poly=pp[1])
    len(poly) == 3 ? concat(soFar,[poly]) :
    triangulate2D(points,_cutEar(points,poly),soFar=concat(soFar,[_getEar(points,poly)]));

module showMesh(points,tt,width=1)
{
    for(t=tt) {
        for(i=[0:1:len(t)-1]) {
            hull() {
                translate(points[t[i]]) sphere(d=width);
                translate(points[t[(i+1)%len(t)]]) sphere(d=width);
            }
        }
    }
}

function _find(needle,haystack) = let(f=search([needle], haystack)) f==[[]] ? undef : f[0];

function _refineTriangle(triangle,maxEdge) =
    let(a = triangle[0],
        b = triangle[1],
        c = triangle[2],
        ab = norm(a-b),
        bc = norm(b-c),
        ca = norm(c-a))
        ab <= maxEdge && bc <= maxEdge && ca <= maxEdge ? [triangle] :
        ab > maxEdge && bc > maxEdge && ca > maxEdge ? [[a,(a+b)/2,(a+c)/2],[b,(b+c)/2,(a+b)/2],[c,(a+c)/2,(b+c)/2],[(a+c)/2,(a+b)/2,(b+c)/2]] :
    ab > maxEdge && bc > maxEdge ? [[b,(b+c)/2,(a+b)/2],[a,(a+b)/2,(b+c)/2],[c,a,(b+c)/2]] :
    bc > maxEdge && ca > maxEdge ? [[c,(c+a)/2,(b+c)/2],[b,(b+c)/2,(c+a)/2],[a,b,(c+a)/2]] :
    ca > maxEdge && ab > maxEdge ? [[a,(a+b)/2,(c+a)/2],[c,(c+a)/2,(a+b)/2],[b,c,(a+b)/2]] :
    ab > maxEdge ? [[a,(a+b)/2,c],[(a+b)/2,b,c]] :
    bc > maxEdge ? [[b,(b+c)/2,a],[(b+c)/2,c,a]] :
    /*ca > maxEdge */ [[c,(c+a)/2,b],[(c+a)/2,a,b]];

function _refineMesh1(triangles,maxEdge,pos=0,newTriangles=[]) =
    pos >= len(triangles) ? newTriangles :
    _refineMesh1(triangles,maxEdge,pos=pos+1,newTriangles=concat(newTriangles,_refineTriangle(triangles[pos],maxEdge)));

function _maxEdge(faces) = max([for(f=faces) for(i=[0:len(f)-1]) norm(f[(i+1)%len(f)]-f[i])]);

function _refineMeshN(triangles,maxEdge,n=0) =
    n <= 0 ? triangles : _refineMeshN(_refineMesh1(triangles,maxEdge),maxEdge,n=n-1);

function _newPointsAndFaces(pointsAndFaces,face,faceSoFar=[]) =
    let(pos=len(faceSoFar),
        points=pointsAndFaces[0],
        faces=pointsAndFaces[1]
    )
    pos >= len(face) ? [points,concat(faces,[faceSoFar])] :
    let(v=face[pos],
        i=_find(v,points)) i==undef ? _newPointsAndFaces([concat(points,[v]),faces],face,faceSoFar=concat(faceSoFar,[len(points)])) : _newPointsAndFaces(pointsAndFaces,face,faceSoFar=concat(faceSoFar,[i]));

function _toPointsAndFaces(faces,pointsAndFaces=[[],[]], pos=0) =
    pos >= len(faces) ? pointsAndFaces :
    _toPointsAndFaces(faces,_newPointsAndFaces(pointsAndFaces,faces[pos]),pos=pos+1);

function refineMesh(points=[],triangles=[],maxEdge=5) =
    let(tris = [for (t=triangles) [for (v=t) points[v]]],
        longestEdge = _maxEdge(tris),
        n = ceil(ln(longestEdge/maxEdge)/ln(2)),
        newTris = _refineMeshN(tris, maxEdge, n)) _toPointsAndFaces(newTris);


//END DEPENDENCY: use <triangulation.scad>;


// written for tail-recursion
// _subtotals[i] = list[0] + ... + list[i-1]
function _subtotals(list,soFar=[]) =
        len(soFar) >= 1+len(list) ? soFar :
        _subtotals(list,
            let(n1=len(soFar))
            concat(soFar, n1>0 ? soFar[n1-1]+list[n1-1] : 0));

function _flatten(list) = [for (a=list) for(b=a) b];

function _reverseTriangle(t) = [t[2], t[1], t[0]];

function _reverse(v) = [for(i=[len(v)-1:-1:0]) v[i]];

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

function _endCap(points,indices,triangulate) = triangulate ? triangulate(points,indices) : [indices];

function _endCaps(points,counts,subtotals,startCap=true,endCap=true,triangulate=false) =
    let( n = len(counts),
         cap1 = counts[0]<=2 || !startCap ? [] : _endCap(points, [for(i=[0:counts[0]-1]) i], triangulate),
         cap2 = counts[n-1]<=2 || !endCap ? [] : _endCap(points, [for(i=[counts[n-1]-1:-1:0]) subtotals[n-1]+i], triangulate))
         concat(cap1,cap2);

function _tubeFaces(sections,startCap=true,endCap=true,optimize=1,triangulateEnds=false) =
                let(
        counts = [for (s=sections) len(s)],
        points = _flatten(sections),
        subtotals = _subtotals(counts))
            concat(_tubeMiddleFaces(points,counts,subtotals,optimize=optimize),_endCaps(points,counts,subtotals,startCap=startCap,endCap=endCap,triangulate=triangulateEnds));

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

function pointsAndFaces(sections,startCap=true,endCap=true,optimize=1,triangulateEnds=false) =
        let(
            points0=_flatten(sections),
            faces0=_tubeFaces(sections,startCap=startCap,endCap=endCap,optimize=optimize,triangulateEnds=triangulateEnds))
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
module tubeMesh(sections,startCap=true,endCap=true,optimize=1,triangulateEnds=false) {
    pAndF = pointsAndFaces(sections,startCap=startCap,endCap=endCap,optimize=optimize,triangulateEnds=triangulateEnds);
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

module morphExtrude(section1,section2=undef,height=undef,twist=0,numSlices=10,curve="t",curveParams=[[]],startCap=true,endCap=true,optimize=1,triangulateEnds=false) {

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

    tubeMesh(sections,startCap=startCap,endCap=endCap,optimize=optimize,triangulateEnds=triangulateEnds);
}

module cone(r=10,d=undef,height=10) {
    radius = d==undef ? r : d/2;

    pointsAround = getPointsAround(radius);

    morphExtrude(ngonPoints(n=pointsAround,r=radius), [[0,0]], height=height,optimize=0);
}

module prism(base=[[0,0,0],[1,0,0],[0,1,0]], vertical=[0,0,1]) {
    morphExtrude(base,[for(v=base) v+vertical],numSlices=1);
}


//END DEPENDENCY: use <tubemesh.scad>;



module dummy() {}

hotshoeLength = 18;
hotshoeInset = 3.2;
hotshoeTaper = 0.25;
hotshoeCorner = 1.5;
hotshoeWidth = 18.52-hotshoeWidthTolerance;
hotshoeThickness = 1.95-hotshoeThicknessTolerance;

module hotshoe(coverStickout = 2) {
hotshoeProfile = [
    [-hotshoeWidth/2, 0],
    [-hotshoeWidth/2+hotshoeTaper, hotshoeThickness],
    [-hotshoeWidth/2+hotshoeInset, hotshoeThickness],
    [-hotshoeWidth/2+hotshoeInset, hotshoeThickness+coverStickout],
    [hotshoeWidth/2-hotshoeInset, hotshoeThickness+coverStickout],
    [hotshoeWidth/2-hotshoeInset, hotshoeThickness],
    [hotshoeWidth/2-hotshoeTaper, hotshoeThickness],
    [hotshoeWidth/2, 0] ];
    rotate([0,180,0])
    rotate([-90,0,0])
    intersection() {
        rotate([0,0,180])
        rotate([90,0,0])
        linear_extrude(height=hotshoeThickness+coverStickout)
        polygon([[-hotshoeWidth/2,0],
            [-hotshoeWidth/2,hotshoeLength-hotshoeCorner],
            [-hotshoeWidth/2+hotshoeCorner,hotshoeLength],
            [hotshoeWidth/2-hotshoeCorner,hotshoeLength],
            [hotshoeWidth/2,hotshoeLength-hotshoeCorner],
            [hotshoeWidth/2,0]]);

        linear_extrude(height=hotshoeLength) polygon(hotshoeProfile);
    }
}



nudge = 0.001;

function getR(angle,r1,arcAngle,r2,widerAngle,transitionAngle) =
    let(a0=arcAngle/2-widerAngle-transitionAngle)
    angle <= a0 ? r1 :
    angle <= a0+transitionAngle ? let(t=(angle-a0)/transitionAngle) (1-t)*r1+t*r2 : r2;

function arc(r1=10,arcAngle=230,r2=11,widerAngle=20,transitionAngle=15,steps=64) =
        [for (i=[0:steps]) let(angle=-arcAngle/2*(steps-i)/steps+arcAngle/2*i/steps)
            getR(angle,r1,arcAngle,r2,widerAngle,transitionAngle)*[cos(angle),sin(angle)]];

function reverse(v) = [for(i=[len(v)-1:-1:0]) v[i]];

function wallAt(z,r1=10,arcAngle=230,r2=11,widerAngle=20,transitionAngle=5,wall=1.5,switchLength=10,cutLength=8,cutArcAngle=30,height=30,insideOnly=false,steps=64) =
    let(d=1.5*(r2-r1),
        t=z<preSwitchLength?1:
          z<preSwitchLength+d?1-(z-preSwitchLength)/d:
          z<preSwitchLength+d+switchLength?0:
          z<preSwitchLength+switchLength+2*d?(z-switchLength-preSwitchLength-d)/d:
          1,
        r2_=r2*(1-t)+r1*t,
        u=z<height-cutLength?0:(z-(height-cutLength))/cutLength,
        arcAngle_=arcAngle*(1-u)+cutArcAngle*u,
        a2=arc(r1=r1,arcAngle=arcAngle_,r2=r2_,widerAngle=widerAngle,transitionAngle=transitionAngle,steps=steps))
        sectionZ(insideOnly?a2:concat(arc(r1=r1+wall,arcAngle=arcAngle_,r2=r2_+wall,widerAngle=widerAngle,transitionAngle=transitionAngle,steps=steps),
    reverse(a2)),z);

module snap(inside=false) {
    r1 = laserDiameter/2+laserTolerance;
    r2 = r1 + laserTolerance+switchOffset;
    h = inside?snapLength+2*nudge:snapLength;
    translate([0,0,inside?-nudge:0])
    rotate([0,0,90])
    translate([-r1-snapWall,0,0])
tubeMesh([for(z=[0:h/layers:h]) wallAt(z,arcAngle=snapAngle,widerAngle=switchAreaAngularSize,r1=r1,r2=r2, cutArcAngle=inside?snapAngle:30, height=h,transitionAngle=transitionAngle, insideOnly=inside, cutLength=cutLength, steps=layers)],triangulateEnds=false);
}

module mountPlate(plate=true) {
    if (plate && mountRadiusOfCurvature) {
        mountCurved();
        rotate([90,0,0])
            translate([-mountBarThickness/2,0,0]) cube([mountBarThickness,hotshoe?hotshoeLength:snapLength,mountOffset+laserDiameter/2+snapWall/2]);
    }
    else {
        rotate([90,0,0]) {
            if(plate)
            linear_extrude(height=mountWall+nudge)
            difference() {
                translate([-mountWidth/2,0]) square([mountWidth,snapLength]);
                for (s=[-1,1]) for(y=[screwOffsetFromEdge+screwHole,snapLength-(screwOffsetFromEdge+screwHole)]) translate([s*(mountWidth/2-screwOffsetFromEdge-screwHole/2),y]) circle(d=screwHole,$fn=16);
            }
            else
                hotshoe();
            translate([-mountBarThickness/2,0,0]) cube([mountBarThickness,hotshoe?hotshoeLength:snapLength,mountOffset+laserDiameter/2+snapWall/2]);
        }
    }
}

module mountCurved() {
    circum = 2 * PI * mountRadiusOfCurvature;
    angle = 360 * mountWidth / circum;
    off = screwOffsetFromEdge + screwHole/2;
    holeAngularOffset = 360 * off / circum;
    translate([0,mountRadiusOfCurvature,0])
    difference() {
        rotate([0,0,-angle/2-90]) rotate_extrude($fn=layers*360/angle,angle=angle) translate([mountRadiusOfCurvature,0]) square([mountWall,snapLength]);
    for(z=[snapLength-off,off]) translate([0,0,z]) for(a=[angle/2-holeAngularOffset,-angle/2+holeAngularOffset]) rotate(a) translate([0,-mountRadiusOfCurvature,0]) rotate([90,0,0]) cylinder(h=3*mountWall,$fn=16,center=true);
    }
}

//mountCurved();

module main(plate=!hotshoe) {
    translate([0,-mountOffset+nudge,0]) snap();
    difference() {
        mountPlate(plate);
        translate([0,-mountOffset+nudge,0]) snap(inside=true);
    }
}

if (switchOnRight) mirror([1,0,0])
 main();
else main();
//hotshoe();
