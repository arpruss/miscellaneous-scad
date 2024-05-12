// data https://www.tnutz.com/product/exm-2020/

// scrap paper:
//  diagonal line equation is:
//      y = x + 1.5/2*sqrt(2)-20/2

function t2020profile(topWidth=12,topHeight=1.5,tol=0.1) = 
    let(b=1.5/2*sqrt(2)-20/2,
        x1=20/2-7,y2=-1.5,x2=x1+2.95,
        y3=x2+b,
        y4=y2-4,
        x4=y4-b,path=
    [ 
        [topWidth/2,topHeight],
        [topWidth/2,tol],
        [x1-tol,tol], [x1-tol,y2-tol], [x2-tol,y2-tol], [x2-tol,y3+tol/sqrt(2)], [x4-tol/sqrt(2),y4+tol],
        [-x4+tol/sqrt(2),y4+tol], [-x2+tol,y3+tol/sqrt(2)], [-x2+tol,y2-tol],[-x1+tol,y2-tol], [-x1+tol,tol],
        [-topWidth/2,tol],
        [-topWidth/2,topHeight],

      
      ]) [for(z=path) z-[0,tol]];
   
module t2020(topWidth=12,topHeight=1.5,tol=0.1) {
    polygon(t2020profile(topWidth=topWidth,topHeight=topHeight,tol=tol));
}

//t2020();