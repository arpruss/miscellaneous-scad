use <string-to-float.scad>;
use <strings.scad>;

function _endParens(list,start=0,openCount=0) = 
    start >= len(list) ? len(list) :
    list[start] == [")"] ? 
            (openCount==1 ? start+1 : _endParen(list,start+1,openCount=openCount-1)) : 
    _endParen(list,start+1,openCount=
        list[start] == ["("] ? 
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
    let (pretok=_fixUnaries(tokenize(s)))
    [ for (i=[0:len(pretok)-1])
        let (a=pretok[i], 
             j=_indexInTable(a, _operators))
            j >= 0 ? _operators[j] : [a] ];
    
    /*
function _parseTokenized(tok,start=0,stop=undef) = 
    let( _stop=stop==undef ? len(tok) : stop )
        tok[start] == "(" ? _parseTokenized(tok,start=start+1,stop=_endParens(tok,start=start+1,openCount=1)) :
            findLowestPrecedenceOperator(...
*/

echo(_tokenizeExpression("a-b*(-!a)+(-a)-a"));
//echo(search("-", ["+",["-",1],["z",1]], num_returns_per_match=1));
