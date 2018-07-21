use <hershey.scad>;
use <eval.scad>;

//<params>
font = 0; // [0:cursive, 1:futural, 2:futuram, 3:gothgbt, 4:gothgrt, 5:gothiceng, 6:gothicger, 7:gothicita, 8:gothitt, 9:rowmand, 10:rowmans, 11:rowmant, 12:scriptc, 13:scripts, 14:timesi, 15:timesib, 16:timesr, 17:timesrb]
text = "Arma virumque cano, Troiae qui primus ab oris / Italiam, fato profugus, Laviniaque venit / litora, multum ille et terris iactatus et alto / vi superum saevae memorem Iunonis ob iram; / multa quoque et bello passus, dum conderet urbem, / inferretque deos Latio, genus unde Latinum, / Albanique patres, atque altae moenia Romae.";
// To work around a bug in the Customizer, equal signs in the following were replaced with @ signs. You can use equal signs when you edit the formula, though.
formula = "let(angle@u*10,z@20*(v-1.5*angle/360),r@30-z/3) [r*cos(angle),r*sin(angle),z]";
//</params>

uv = _replaceChar(formula,"@","=");
fonts=["cursive","futural","futuram","gothgbt","gothgrt","gothiceng","gothicger","gothicita","gothitt","rowmand","rowmans","rowmant","scriptc","scripts","timesi","timesib","timesr","timesrb"];

function normalize(vect) = 
    let(n=norm(vect))
    n == 0 ? [0,0,0] : vect/n;
    
function makeMatrix(v1,v2,v3,pos) =
    [[v1[0],v2[0],v3[0],pos[0]],
     [v1[1],v2[1],v3[1],pos[1]],
     [v1[2],v2[2],v3[2],pos[2]],
     [0,0,0,1]];

function getTransform(f,uv,normalize=true,extraParameters=[],delta=0.01) =
    let(u = uv[0],
        v = uv[1],
        fc = eval(f,concat([["u",u],["v",v]],extraParameters)),
        f_u = (eval(f,concat([["u",u+delta],["v",v]],extraParameters))-fc)/delta,
        f_v = (eval(f,concat([["u",u],["v",v+delta]],extraParameters))-fc)/delta,
        normal = cross(f_u,f_v),
        t = (norm(f_u)+norm(f_v))/2,
        adjNormal = t==0 ? normal : normal/t)
        
        normalize ? makeMatrix(normalize(f_u),normalize(f_v),normalize(normal),fc) : makeMatrix(f_u,f_v,normal,fc);;
        
module mapHershey(text,f="[u,v,0]",font="timesr",halign="left",valign="baseline",normalize=true,size=1,extraParameters=[]) {
    cf = compileFunction(f);
    lines = getHersheyTextLines(text,size=1,font=font,halign=halign,valign=valign);
    for (line=lines) {
//        echo(getTransform(cf,line[0],normalize=normalize));
        hull() {
            multmatrix(getTransform(cf,line[0],normalize=normalize,extraParameters=extraParameters)) children();
            multmatrix(getTransform(cf,line[1],normalize=normalize,extraParameters=extraParameters)) children();
        }
    }
}

module demo() {
    mapHershey(text,f=uv,font=fonts[font]) cylinder(d=1,h=3,$fn=8);
}

demo();