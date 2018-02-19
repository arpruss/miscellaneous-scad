function _slice(a,start,end=undef) =
    let(end = end==undef ? len(a) : end)
        start>=end  ? [] : [for (i=[start:end-1]) a[i]];

function _rmergeLists(a,b,merged=[]) =
    len(a)==0 ? concat(merged,b) :
    len(b)==0 ? concat(merged,a) :
    rands(0,1,1)[0]<len(a)/(len(a)+len(b)) ? _rmergeLists(_slice(a,1), b, merged=concat(merged,[a[0]])) : 
        _rmergeLists(_slice(b,1), a, merged=concat(merged,[b[0]]));

function permute(a) =
    let(l=len(a))
        l <= 1 ? a :
        let(split=floor(l/2),
            b=_slice(a,0,end=split),
            c=_slice(a,split))
            _rmergeLists(permute(b),permute(c));

echo(permute([for(i=[0:99]) i]));
        