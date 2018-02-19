function _slice(a,start,end=undef) =
    let(end = end==undef ? len(a) : end)
        start>=end ? [] : [for (i=[start:end-1]) a[i]];

function _mergeLists(a,b,merged=[]) =
    len(a)==0 ? concat(merged,b) :
    len(b)==0 ? concat(merged,a) :
    a[0] < b[0] ? _mergeLists(_slice(a,1), b, merged=concat(merged,[a[0]])) : 
        _mergeLists(_slice(b,1), a, merged=concat(merged,[b[0]]));

function mergeSort(a) =
    let(l=len(a))
        l <= 1 ? a :
        let(split=floor(l/2),
            b=_slice(a,0,end=split),
            c=_slice(a,split))
            _mergeLists(mergeSort(b),mergeSort(c));

//echo(mergeSort(rands(0,100,1000)));