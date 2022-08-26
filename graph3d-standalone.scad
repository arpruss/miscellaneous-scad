// specify function of x and y in standard OpenSCAD notation, plus you can use all-caps functions for radian-based trigonometry, and you can use the constants "pi" (or "PI") and "e"
/*z="20*COS(norm([x,y]))/(1+norm([x,y]))";
minX=-10;
maxX=10;
minY=-10;
maxY=10; */
resolution=50;
style=0; // [0:flat bottom, 1:surface]
// zero for automatic
thickness=0;

module end_of_parameters_dummy() {}

//use <eval.scad>;
function _isString(v) = v >= "";
function _isVector(v) = !(v>="") && len(v) != undef;
function _isFloat(v) = v+0 != undef;

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
        s == "undef" ? undef :
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

// We know the main operator is a ? or a :. We now need to find out which.
function _mainQuestionOperator(c) =
    let(fq = _firstOccurrence(c,"?"),
        fc = _firstOccurrence(c,":"))
        fq[1] != undef && (fc[1] == undef || fq[1] < fc[1]) ? fq : fc;

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
        stop <= start ? undef :
        tok[start][0] == "(" && _endParens(tok,start=start+1,stop=stop,openCount=1)==stop ?
            _parseMain(tok,start=start+1,stop=stop-1) :
        let( lp = _mainOperator(tok,start,stop) )
            lp[0] == undef ? ( stop-start>1 ? undef : _parseLiteralOrVariable(tok[start][0]) ) :
            let( op = lp[0], pos = lp[1] )
                op[_NAME] == "?" ?
                    [ op[_OPERATOR], _parseMain(tok,start=start,stop=pos), _parseMain(tok,start=pos+1,stop=lp[2]), _parseMain(tok,start=lp[2]+1,stop=stop) ] :
                op[_NAME] == "let" ?
                    _letOperator( _parseMain(op[_EXTRA_DATA]), _parseMain(tok,start=pos+1,stop=stop)) :
                op[_ARITY] == 2 ?
                    [ op[_OPERATOR], _parseMain(tok,start=start,stop=pos), _parseMain(tok,start=pos+1,stop=stop) ]
                    : [ op[_OPERATOR], _parseMain(tok,start=pos+1,stop=stop) ];


// this upgrades sequences of binary commas to vectors
function _fixCommas(expression) =
    expression[0] == "," ?
        let(a=_fixCommas(expression[1]),
            b=_fixCommas(expression[2]))
            a[0] == "[[" ?
                concat(["[["],concat(_tail(a), [b])) :
                ["[[",a,b]
        :
    _isVector(expression) ?
            concat([expression[0]], [for (i=[1:len(expression)-1]) _fixCommas(expression[i])]) :
            expression;

// fix arguments from vectors
function _fixArguments(expression) =
    let(i=_indexInTable(expression[0], _operators, _OPERATOR))
            i >=0 && _operators[i][_ARGUMENTS_FROM_VECTOR] && expression[1][0] == "[[" ? concat([expression[0]], [for (i=[1:len(expression[1])-1]) _fixArguments(expression[1][i])]) :
/*            expression[0] == "?" ?
                concat([expression[0],expression[1]],[for (i=[1:len(expression[2])-1]) _fixArguments(expression[2][i])]) : */
            len(expression)>1 && !_isString(expression) ?
                concat([expression[0]], [for (i=[1:len(expression)-1]) _fixArguments(expression[i])])
                    : expression;

function _optimizedLiteral(x) =
    len(x)==undef ? x : ["'", x];

function _wellDefined(x) =
    x==undef ? false :
    len(x)==undef ? true :
    x[0] == "'" ? true :
    len(x)==1 ? x[0]!=undef :
    len([for (a=x) if(!_wellDefined(a)) true])==0;

function _optimize(expression) =
    let(x=eval(expression,$careful=true))
        _wellDefined(x) ? _optimizedLiteral(x) :
        expression[0] == "'" ? _optimizedLiteral(x) :
        ! _isString(expression) ?
            concat([expression[0]], [for(i=[1:len(expression)-1]) _optimize(expression[i])]) :
        expression;

function compileFunction(expression,optimize=true) =
            _isVector(expression) ? expression :
            _isFloat(expression) ? expression :
            let(unoptimized = _fixArguments(_fixCommas(_parseMain(_parsePass1(expression)))))
        optimize ? _optimize(unoptimized) : unoptimized;

function evaluateFunction(expression,variables) = eval(compileFunction(expression,optimize=false),variables);

function _let(v, var, value) = concat([var, value], v);

function _lookupVariable(var, table) =
    let (s=search([var], table, index_col_num=0))
        s[0] == [] ? undef : table[s[0][0]][1];

function _generate(var, range, expr, v) =
    [ for(i=range) eval(expr, _let(v, var, i)) ];

function _safeNorm(v) =
    ! _isVector(v) || len([for (x=v) x+0==undef]) ? undef : norm(v);

function eval(c,v=[]) =
    ""<=c ? _lookupVariable(c,v) :
    let(op=c[0]) (
    op == undef ? c :
    op == "'" ? c[1] :
    op == "+" ? (len(c)==2 ? eval(c[1],v) : eval(c[1],v)+eval(c[2],v)) :
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
    op == "COS" ? cos(eval(c[1],v)*180/PI) :
    op == "SIN" ? sin(eval(c[1],v)*180/PI) :
    op == "TAN" ? tan(eval(c[1],v)*180/PI) :
    op == "ACOS" ? acos(eval(c[1],v))*PI/180 :
    op == "ASIN" ? asin(eval(c[1],v))*PI/180 :
    op == "ATAN" ? atan(eval(c[1],v))*PI/180 :
    op == "ATAN2" ? atan2(eval(c[1],v),eval(c[2],v))*PI/180 :
    op == "abs" ? abs(eval(c[1],v)) :
    op == "ceil" ? ceil(eval(c[1],v)) :
    op == "cross" ? cross(eval(c[1],v),eval(c[2],v)) :
    op == "exp" ? exp(eval(c[1],v)) :
    op == "floor" ? floor(eval(c[1],v)) :
    op == "ln" ? ln(eval(c[1],v)) :
    op == "len" ? len(eval(c[1],v)) :
    op == "log" ? log(eval(c[1],v)) :
    op == "max" ? (len(c) == 2 ? max(eval(c[1],v)) : max([for(i=[1:len(c)-1]) eval(c[i],v)])) :
    op == "min" ? (len(c) == 2 ? min(eval(c[1],v)) : min([for(i=[1:len(c)-1]) eval(c[i],v)])) :
    op == "norm" ?
        (!$careful ? norm(eval(c[1],v)) : _safeNorm(eval(c[1],v))) :
    op == "rands" ? rands(eval(c[1],v),eval(c[2],v),eval(c[3],v),eval(c[4],v)) :
    op == "round" ? round(eval(c[1],v)) :
    op == "sign" ? sign(eval(c[1],v)) :
    op == "[" ? [for (i=[1:len(c)-1]) eval(c[i],v)] :
    op == "#" ? eval(c[1],v)[eval(c[2],v)] :
    op == "<" ? eval(c[1],v)<eval(c[2],v) :
    op == "<=" ? eval(c[1],v)<=eval(c[2],v) :
    op == ">=" ? eval(c[1],v)>=eval(c[2],v) :
    op == ">" ? eval(c[1],v)>=eval(c[2],v) :
    op == "==" ? (!$careful ? eval(c[1],v)==eval(c[2],v) :
        (let(c1=eval(c[1],v))
        c1==undef ? undef :
        let(c2=eval(c[2],v))
        c2==undef ? undef :
        c1 == c2) ) :
    op == "!=" ? (!$careful ? eval(c[1],v)!=eval(c[2],v) :
        (let(c1=eval(c[1],v))
        c1==undef ? undef :
        let(c2=eval(c[2],v))
        c2==undef ? undef :
        c1 != c2) ) :
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
    op == "!" ? (!$careful ? !eval(c[1],v) :
        (let(c1=eval(c[1],v))
        c1==undef ? undef :
        !c1) ) :
    op == "?" ? (!$careful ? (eval(c[1],v)?eval(c[2],v):eval(c[3],v)) :
        (let(c1=eval(c[1],v))
        c1==undef ? undef :
        c1 ? eval(c[2],v):eval(c[3],v)) ):

    op == "concat" ? [for (i=[1:len(c)-1]) let(vect=eval(c[i],v)) for(j=[0:len(vect)-1]) vect[j]] :
    op == "range" ? (len(c)==3 ? [eval(c[1],v):eval(c[2],v)] : [eval(c[1],v):eval(c[2],v):eval(c[3],v)]) :
    op == "let" ? (!$careful ? eval(c[3],concat([[eval(c[1],v),eval(c[2],v)]], v)) :
            let(c1=eval(c[1],v),c2=eval(c[2],v))
                c1==undef || c2==undef ? undef :
                    eval(c[3],concat([[c1,c2]], v)) ) :
    op == "gen" ? _generate(eval(c[1],v),eval(c[2],v),c[3],v) :
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


minX = -PI;
maxX = PI;
minY = -PI;
maxY = PI;

z = "5*COS(x)+10*SIN(x*2)-5*COS((x+y)*3)+7*SIN(y)-3*COS(x-y)";

graphFunction3D(z,minX,maxX,minY,maxY,surfaceThickness=style?thickness:undef,flatMinimumThickness=style?undef:thickness);

function makePointList(top, bottom)=
    let(
        width = len(bottom),
        height = len(bottom[0]))
        [for (x=[0:width-1]) for (y=[0:height-1]) for(z=[0:1]) [x,y,z?top[x][y]:bottom[x][y]]];

function pointIndex(v,gridHeight)=
      v[0]*gridHeight*2 + v[1]*2 + v[2];

function makeStrip(bottomLeft, lengthwiseDelta, transverseDelta, stripLength, gridHeight) =
        let(
        start = pointIndex(bottomLeft, gridHeight),
        dx = pointIndex(bottomLeft+lengthwiseDelta, gridHeight) - start,
        dy = pointIndex(bottomLeft+transverseDelta, gridHeight) - start
        )
        [ for (i=[0:stripLength-1]) for (t=[0:1])
            let (
            v00 = start+dx*i,
            v10 = v00+dx,
            v01 = v00+dy,
            v11 = v00+dx+dy )
            t ? [v00,v01,v11] : [v00,v11,v10] ];

function concatLists(listOfLists)=
    [for (a=listOfLists) for (b=a) b];

function makeFaceList(width, height)=let(
    baseFaces=concatLists(
        [for(i=[0:width-2])
            makeStrip([i,0,0],[0,1,0],[1,0,0],height-1,height)]),
    surfaceFaces=concatLists(
        [for(i=[0:width-2])
            makeStrip([i,height-1,1],[0,-1,0],[1,0,0],height-1,height)]),
    leftFaces=makeStrip([0,height-1,0],[0,-1,0],[0,0,1],height-1,height),
    rightFaces=makeStrip([width-1,0,0],[0,1,0],[0,0,1],height-1,height),
    bottomFaces=makeStrip([0,0,0],[1,0,0],[0,0,1],width-1,height),
    topFaces=makeStrip([width-1,height-1,0],[-1,0,0],[0,0,1],width-1,height)) concat(baseFaces,surfaceFaces,leftFaces,rightFaces,bottomFaces,topFaces);

module graphArray3D(top, bottom=undef, thickness=undef, baseZ=undef) {
    width = len(top);
    height = len(top[0]);
    bottom0 = bottom!=undef ? bottom :
              thickness!=undef ?
                [for(x=[0:width-1]) [for(y=[0:height-1]) top[x][y]-thickness]] : [for(x=[0:width-1]) [for(y=[0:height-1]) baseZ]];
    top1 = [for(x=[0:width-1]) [for(y=[0:height-1]) max(top[x][y],bottom0[x][y])]];
    bottom1 = [for(x=[0:width-1]) [for(y=[0:height-1]) min(top[x][y],bottom0[x][y])]];

    points = makePointList(top1, bottom1);
    faces = makeFaceList(width, height);
    polyhedron(points=points, faces=faces);
}

// surfaceThickness does a surface with a wavy top and
// and bottom.
// flatMinimumThickness does a surface with a flat bottom
// and specifies the minimum thickness.
module graphFunction3D(f,minX,maxX,minY,maxY,resolution=50,surfaceThickness=undef,flatMinimumThickness=undef,bottomFunction=undef,constants=[],realSize=false) {
    dx = (maxX-minX)/resolution;
    dy = (maxY-minY)/resolution;
    size = max(maxX-minX,maxY-minY);
    fc = compileFunction(f);
    smallSize = size/50;
    e = exp(1);
    allConstants = concat(constants,[["pi", PI], ["PI", PI], ["e", e]]);
    top=[for(i=[0:resolution]) [for(j=[0:resolution])
            eval(fc, concat([["x", minX+dx*i], ["y", minY+dy*j]], allConstants))]];
    translate(realSize ? [minX,minY,0] : [0,0,0])
    scale(realSize ? [(maxX-minX)/resolution,(maxY-minY)/resolution,1] : [1,1,1]) {
        if (bottomFunction != undef) {
            bc = compileFunction(bottomFunction);
            bottom=[for(i=[0:resolution]) [for(j=[0:resolution])
                    eval(bc, concat([["x", minX+dx*i], ["y", minY+dy*j]], allConstants))]];
            graphArray3D(top, bottom);
        }
        else if (flatMinimumThickness != undef) {
            minZ = min([for(i=[0:resolution]) for(j=[0:resolution]) top[i][j]]);
            graphArray3D(top, baseZ=minZ-(flatMinimumThickness != 0 ? flatMinimumThickness : smallSize));
        }
        else {
            thickness = surfaceThickness!=undef && surfaceThickness!=0 ? surfaceThickness : smallSize;
            graphArray3D(top, thickness=thickness);
        }
    }
}
