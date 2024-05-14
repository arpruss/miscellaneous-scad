use <Bezier.scad>;
use <tubeMesh.scad>;

// modified from https://www.tnutz.com/product/exm-2020/

// scrap paper:
//  diagonal line equation is:
//      y = x + 1.5/2*sqrt(2)-20/2

function t2020insertprofile(topWidth=12,topHeight=1.5,tol=0.1,htolExtra=0.1) = 
    let(b=1.5/2*sqrt(2)-20/2,
        x1=20/2-7,y2=-1.75,x2=x1+2.95,
        y3=x2+b,
        y4=y2-4,
        x4=y4-b,path=
    [ 
        [topWidth/2,topHeight],
        [topWidth/2,tol],
        [x1-tol-htolExtra,tol], [x1-tol-htolExtra,y2-tol], [x2-tol-htolExtra,y2-tol], [x2-tol-htolExtra,y3+tol/sqrt(2)], [x4-tol/sqrt(2)-htolExtra,y4+tol],
        [-x4+tol/sqrt(2)+htolExtra,y4+tol], [-x2+tol+htolExtra,y3+tol/sqrt(2)], [-x2+tol+htolExtra,y2-tol],[-x1+tol+htolExtra,y2-tol], [-x1+tol+htolExtra,tol],
        [-topWidth/2,tol],
        [-topWidth/2,topHeight],

      
      ]) Bezier(roundOuter([for(z=path) z-[0,tol]],size=0.27));      
     
function _roundOuter1(profile,i,size,startEndSkip) = 
      i>=len(profile)-1? 
        [LINE(),profile[i]] :
      let(d1=(profile[i]-profile[i-1])/norm(profile[i]-profile[i-1]),
        d2=(profile[i+1]-profile[i])/norm(profile[i+1]-profile[i]),
        angle=asin((d2[1]*d1[0]-d2[0]*d1[1]))) 
      angle >= 0 || i<=startEndSkip || i>=len(profile)-startEndSkip-1 ? [LINE(),profile[i],LINE()] : 
//[LINE(),profile[i]-d1*size,LINE(),LINE(),profile[i]+d2*size,LINE()];
  [LINE(),profile[i]-d1*size,profile[i]-d1*size*.3,profile[i]+d2*size*.3,profile[i]+d2*size,LINE()]
      ;
      
function roundOuter(profile,size=0.3) = 
      [for (z=[ [profile[0],LINE()], [for(i=[1:len(profile)-1]) for(u=_roundOuter1(profile,i,size,1)) u] ]) for(w=z) w];
   
module t2020insertprofile(topWidth=12,topHeight=1.5,tol=0.15,htolExtra=0.1) {
    polygon(t2020profile(topWidth=topWidth,topHeight=topHeight,tol=tol));
}

function _translatePath(path,delta) = [for(z=path) z+delta];

module t2020insert(topWidth=12,topHeight=1.5,length=100,tol=0.15,htolExtra=0,chamfer=0.5) {
    vChamfer = min(chamfer,0.15);
    sections = [sectionZ(_translatePath(t2020insertprofile(topWidth=topWidth,topHeight=topHeight,tol=tol+vChamfer,htolExtra=htolExtra+chamfer),[0,vChamfer]),0),
        sectionZ(t2020insertprofile(topWidth=topWidth,topHeight=topHeight,tol=tol,htolExtra=htolExtra),2*chamfer),
        sectionZ(t2020insertprofile(topWidth=topWidth,topHeight=topHeight,htolExtra=htolExtra,tol=tol),length-2*chamfer),
        sectionZ(_translatePath(t2020insertprofile(topWidth=topWidth,topHeight=topHeight,tol=tol+vChamfer,htolExtra=htolExtra+chamfer),[0,vChamfer]),length)];
    tubeMesh(sections);
}

//linear_extrude(height=8)
//t2020();
t2020insert(length=10,tol=0.25,htolExtra=0.1);