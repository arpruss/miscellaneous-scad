// type detector library
// public domain by Alexander Pruss

function isVector(v) = concat(v, []) == v;
function isBoolean(v) = (v==true || v==false);
function isFloat(v) = v+0 != undef;
function isDefiniteFloat(v) = v==v && (let(a=v+1) a!=undef && a!=v); // float, neither NaN nor infinity
function isRange(v) = len(v) == undef && v[0] != undef;
function isString(v) = v >= ""; // this seems to be the fastest way
function typeOf(v) = isVector(v) ? "vector" : 
                     isBoolean(v) ? "boolean" :
                     isFloat(v) ? "float" :
                     isRange(v) ? "range" :
                     isString(v) ? "string" :
                     v==undef ? "undef" :
                     "unknown";

function _allTypes(x) =
    [isVector(x),isBoolean(x),isFloat(x),isDefiniteFloat(x),isRange(x),isString(x)];
function _testTypeDetector() =
    _allTypes(undef) == [false,false,false,false,false,false] 
&&
    _allTypes([]) == [true,false,false,false,false,false] &&
    _allTypes([undef]) == [true,false,false,false,false,false] &&
    _allTypes(true) == [false,true,false,false,false,false] &&
    _allTypes(false) == [false,true,false,false,false,false] &&
    _allTypes(0) == [false,false,true,true,false,false] &&
    _allTypes(-1) == [false,false,true,true,false,false] &&
    _allTypes(1/0) == [false,false,true,false,false,false] &&
    _allTypes(sqrt(-1)) == [false,false,true,false,false,false] &&
    _allTypes([1:2]) == [false,false,false,false,true,false] &&
    _allTypes([1:2:3]) == [false,false,false,false,true,false] &&
    _allTypes("") == [false,false,false,false,false,true] &&
    _allTypes(chr(0)) == [false,false,false,false,false,true] &&
    _allTypes("abc") == [false,false,false,false,false,true];
    
echo(str("All tests passed: ",_testTypeDetector()));
