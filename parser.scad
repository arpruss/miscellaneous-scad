use <string-to-float.scad>;
use <strings.scad>;

function _isspace(c) = (" " == c || "\t" == c || "\r" == c || "\n" == c );
function _isdigit(c) = ("0" <= c && c <= "9" );
function _isalpha(c) = ("a" <= c && c <= "z") || ("A" <= c && c <= "Z");
function _isalnum_(c) = _isalpha(c) || _isdigit(c) || c=="_";

function _spaceSequence(s, start=0) = 
    len(s)>start && _isspace(s[start]) ? 1+_spaceSequence(s, start=start+1) : 0;
function _digitSequence(s, start=0) =
    len(s)>start && _isdigit(s[start]) ? 1+_digitSequence(s, start=start+1) : 0;
function _alnum_Sequence(s, start=0) = 
    len(s)>start && _isalnum_(s[start]) ? 1+_alnum_Sequence(s, start=start+1) : 0;
function _identifierSequence(s, start=0) = 
    len(s)>start && (_isalpha(s[start]) || s[start]=="_") ? 1+_alnum_Sequence(s, start=start+1) : 0;
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
_OPERATOR = 4;

_operators = [
    [ "*", 2, 1, true, "*" ],
    [ "/", 2, 1, true, "/" ],
    [ "+", 2, 2, true, "+" ],
    [ "-", 2, 2, true, "-" ],
    [ "#-",1, -1, true, "-" ],
    [ "^", 2, 0, false, "^" ] ];
    
_binary_or_unary = [ ["-", "#-"] ];

function _fixUnaries(pretok) =
    [ for (i=[0:len(pretok)-1]) 
         let (
            a = pretok[i],
            j=_indexInTable(a, _binary_or_unary)) 
            (0 <= j && (i == 0 || pretok[i-1] == "(" ||
                0 <= _indexInTable(pretok[i-1], _operators)))? _binary_or_unary[j][1] : a ];

function _tokenizeExpression(s) =
    let (pretok=_fixUnaries(_tokenize(s)))
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
    
function _parseLiteralOrVariable(s) = search(s[0], "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ") ? s : atof(s);
    
function _findLowestPrecedenceOperator(tok,start,stop) = stop <= start ? [undef,start] :
        stop == start+1 ? ( len(tok[start])>_PREC ? [tok[start],start] : [undef,start] ) :
        let( rest = tok[start][0] == "(" ?
            _findLowestPrecedenceOperator(tok, _endParens(tok,start=start+1,_stop=stop), stop)
            : _findLowestPrecedenceOperator(tok, start+1, stop) )
            _prec(rest[0], rest[1], tok[start], start) ? [tok[start], start] : rest;
    
function _parseTokenized(tok,start=0,_stop=undef) = 
    let( stop= _stop==undef ? len(tok) : _stop )
        stop <= start ? undef :
        tok[start][0] == "(" ? 
            _parseTokenized(tok,start=start+1,_stop=_endParens(tok,start=start+1,openCount=1,stop=stop)-1) : 
        let( lp = _findLowestPrecedenceOperator(tok,start,stop) )
            lp[0] == undef ? ( stop-start>1 ? undef : _parseLiteralOrVariable(tok[start][0]) ) :
            let( op = lp[0], pos = lp[1] ) 
                op[_ARITY] == 2 ?
                    [ op[_OPERATOR], _parseTokenized(tok,start,pos), _parseTokenized(tok,pos+1,_stop=stop) ]
                    : [ op[_OPERATOR], _parseTokenized(tok,pos+1,_stop=stop) ];  

//echo(_tokenizeExpression("a-b*(-!a)+(-a)-a*12e1"));
//echo(search("-", ["+",["-",1],["z",1]], num_returns_per_match=1));
echo(_tokenizeExpression("a-b*c-(d-e)-f*12e1"));
echo(_parseTokenized(_tokenizeExpression("a-b*c-(d-e)-f*12e1")));
echo(_positiveRealSequence("12e-3"));
echo(_tokenize("z 12e-3<=34+44&&exp2_(33)"));
//echo(_parseTokenized(_tokenizeExpression("(a)")));
// TODO: fix tokenization not to break on periods, and inside things like "<=" and "&&"