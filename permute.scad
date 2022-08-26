function unique(list,pos=0,soFar=true) =
    !soFar || pos >=len(list) ? soFar :
    unique(list,pos=pos+1,soFar = pos==0 || len(search(list[pos],[for (i=[0:pos-1]) list[i]]))==0);

function lesserCount(limit,list,pos,soFar=0) =
    pos == 0 ? soFar :
    lesserCount(limit,list,pos=pos-1,soFar=
        list[pos-1]<limit ? 1+soFar :
        soFar);

function tryPermute(n) =
    let(r=rands(0,1,n))
    [for (i=[0:n-1]) lesserCount(r[i],r,n)];
        
function permute(n) = 
    let(try=tryPermute(n))
        unique(try) ? try : permute(n);
    
data = permute(20000);
echo(data[0]);    
//echo(unique(tryPermute(20000)));