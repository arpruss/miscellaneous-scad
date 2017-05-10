// type detector library
// public domain by Alexander Pruss

function isVector(v) = !(v>="") && len(v) != undef;
function isBoolean(v) = (v==true || v==false);
function isFloat(v) = v+0 != undef;
function isDefiniteFloat(v) = v==v && (let(a=v+1) a!=undef && a!=v); // float, neither NaN nor infinity
function isRange(v) = !(v>="") && len(v)==undef && v[0]!=undef;
function isString(v) = v >= ""; // this seems to be the fastest way

// the order of tests below has some importance
function typeOf(v) = v>="" ? "string" :
                     len(v) != undef ? "vector" :
                     v+0 != undef ? "float" :
                     v[0] != undef ? "range" :
                     v == false || v == true ? "boolean" :
                     v == undef ? "undef" :
                     "unknown";

function _allTypes(x) =
    [isVector(x),isBoolean(x),isFloat(x),isDefiniteFloat(x),isRange(x),isString(x),typeOf(x)];
function _testTypeDetector() =
    _allTypes(undef) == [false,false,false,false,false,false,"undef"] 
&&
    _allTypes([]) == [true,false,false,false,false,false,"vector"] &&
    _allTypes([undef]) == [true,false,false,false,false,false, "vector"] &&
    _allTypes(true) == [false,true,false,false,false,false, "boolean"] &&
    _allTypes(false) == [false,true,false,false,false,false,"boolean"] &&
    _allTypes(0) == [false,false,true,true,false,false,"float"] &&
    _allTypes(-1) == [false,false,true,true,false,false,"float"] &&
    _allTypes(1/0) == [false,false,true,false,false,false,"float"] &&
    _allTypes(sqrt(-1)) == [false,false,true,false,false,false,"float"] &&
    _allTypes([1:2]) == [false,false,false,false,true,false,"range"] &&
    _allTypes([1:2:3]) == [false,false,false,false,true,false,"range"] &&
    _allTypes("") == [false,false,false,false,false,true,"string"] &&
    _allTypes(chr(0)) == [false,false,false,false,false,true,"string"] &&
    _allTypes("abc") == [false,false,false,false,false,true,"string"];
    
echo(str("All tests passed: ",_testTypeDetector()));
