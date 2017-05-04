function _substr(s, start=0, stop=undef) =
    let( stop = stop==undef ? len(s) : stop )
        start >= stop || start >= len(s) ? "" :
        str(s[start], _substr(s, start=start+1, stop=stop));
        
function _parseInt(s, start=0, stop=undef, accumulated=0) =
    let( stop = stop==undef ? len(s) : stop )
        start >= stop ? accumulated :
        s[start] == "+" ? _parseInt(s, start=start+1, stop=stop) :
        s[start] == "-" ? -_parseInt(s, start=start+1, stop=stop) :
        let (digit = search(s[start], "0123456789"))
            digit == [] ? 0 : _parseInt(s, start=start+1, stop=stop, accumulated=accumulated*10+digit[0]);
    
function _findNonDigit(s, start=0) =
    start >= len(s) ? len(s) :
        "0" <= s[start] && s[start] <= "9" ? 
        _findNonDigit(s, start=start+1) : start;

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
    [ ":", 2, 10, -1, true, "," ],
    [ "?", 2, 20, -1, true, "?" ], 
    [ ",", 2, 100, 1, true, "," ]
   ];
    
_binary_or_unary = [ ["-", "#-"], ["+", "#+"], ["#", "["] ];

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
    op1 == undef && op2 == undef ? true :
    op1[_PREC] < op2[_PREC] ? true :
        op2[_PREC] < op1[_PREC] ? false :
            op1[_ASSOC_DIR] * pos1 < op2[_ASSOC_DIR] * pos2;
    
function _parseLiteralOrVariable(s) = 
        s == "true" ? true :
        s == "false" ? false :
        s == "undef" ? undef :
        _isalpha_(s[0]) ? ["$", s] : 
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
function _findMainOperator(candidates,start=0) =
    len(candidates) <= start ? [undef, 0] :
    let(rest=_findMainOperator(candidates,start+1))
    _prec(rest[0], rest[1], candidates[start][0], candidates[start][1]) ? candidates[start] : rest;

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
    m=_findMainOperator(c))
     m[0][0] == "?" || m[0][0] == ":" ? _mainQuestionOperator(c) : m;
    
/* This takes a fully tokenized vector, each element of which is either a line from the _operators table or a vector containing a single non-operator string, and parses it using general parenthesis and operator parsing. Comma expressions for building vectors will be parsed in the next pass. */
function _parseMain(tok,start=0,stop=undef) = 
    let( stop= stop==undef ? len(tok) : stop )
        stop <= start ? undef :
        tok[start][0] == "(" && _endParens(tok,start=start+1,stop=stop,openCount=1)==stop ? 
            _parseMain(tok,start=start+1,stop=stop-1) : 
        let( lp = _mainOperator(tok,start,stop) )
            lp[0] == undef ? ( stop-start>1 ? undef : _parseLiteralOrVariable(tok[start][0]) ) :
            let( op = lp[0], pos = lp[1] )
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
    expression[0] == "$" || !(len(expression)>1) ? expression :
            concat([expression[0]], [for (i=[1:len(expression)-1]) _fixCommas(expression[i])]);

// fix arguments from vectors
function _fixArguments(expression) = 
    let(i=_indexInTable(expression[0], _operators, _OPERATOR)) 
            i >=0 && _operators[i][_ARGUMENTS_FROM_VECTOR] && expression[1][0] == "[[" ? concat([expression[0]], [for (i=[1:len(expression[1])-1]) _fixArguments(expression[1][i])]) : 
            expression[0] == "?" ?
                concat([expression[0],expression[1]],[for (i=[1:len(expression[2])-1]) _fixArguments(expression[2][i])]) : 
            len(expression)>1 && expression[0] != "$" ? 
                concat([expression[0]], [for (i=[1:len(expression)-1]) _fixArguments(expression[i])])
                    : expression;
                
function _optimizedLiteral(x) = 
    len(x)==undef ? x : ["'", x];
                
function _wellDefined(x) =
    x==undef ? false :
    len(x)==undef ? true :
    len([for (a=x) if(!_wellDefined(a)) true])==0;

function _optimize(expression) =
    let(x=eval(expression,$careful=true))
        _wellDefined(x) ? _optimizedLiteral(x) :
        expression[0] == "'" ? _optimizedLiteral(x) :
        let(n=len(expression))
        n>=2 ? 
        expression[0]=="$" ? ((expression[1]=="x" || expression[1] == "y" || expression[1] == "z" || expression[1] == "t") ?expression[1] : expression) :
    concat([expression[0]], [for(i=[1:n-1]) _optimize(expression[i])]) :
        expression;
        
function compileFunction(expression,optimize=true) = let(unoptimized = _fixArguments(_fixCommas(_parseMain(_parsePass1(expression)))))
        optimize ? _optimize(unoptimized) : unoptimized;

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
        ["!", c1 == c2]) ) :
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
    op == "let" ? eval(c[3],_let(v,c[1],c[2])) :
    op == "gen" ? _generate(eval(c[1],v),eval(c[2],v),c[3],v) :
    undef
    );
    