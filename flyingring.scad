ratioOfWingChordToRadius = 0.228;
outerDiameter = 328.6;
// if this is >0, the above ratio is ignored
forceChordSize = 0;
// set to zero for a flat underside
ratioOfUndercutHeightToWingThickness = 0.326;
// 1 places the undercut at the outer edge, and 0 at the inner edge
undercutPosition= 0.423;
undercutAngle = 90;
crossSectionDisplay = 0; // [0:no, 1:yes]

module dummy() {}

// original: 
// wing chord 37.37
// diameter: 328.6

chord = forceChordSize > 0 ? forceChordSize : ratioOfWingChordToRadius * outerDiameter / 2;

size_section = [178.368150375,20.531710643];

// paths for section
bottom = -10.038806110;
undercutY = bottom+ratioOfUndercutHeightToWingThickness*size_section[1];
undercutX = size_section[0] * undercutPosition - size_section[0]/2;
undercutDeltaX = ratioOfUndercutHeightToWingThickness*size_section[1] * tan(undercutAngle/2);
points_section_1 = [ [-89.184075187,bottom],[undercutX-undercutDeltaX,bottom],[undercutX,undercutY],[undercutX+undercutDeltaX,bottom],[43.973430185,-10.255668532],[68.104217031,-10.265855321],[89.184075187,bottom],[87.028882624,-7.381291630],[85.036907385,-4.670020678],[78.288796781,5.510042015],[76.803620995,7.588155954],[75.357947667,9.359250619],[74.571549492,10.158438080],[74.370755383,10.265855321],[74.261267155,10.202438056],[74.181911461,8.599671226],[73.969268838,7.240302257],[73.722675556,6.483989661],[73.345603521,5.700541477],[72.810329654,4.907920070],[72.089130876,4.124087805],[71.154284108,3.367007047],[69.978066271,2.654640160],[69.246493351,2.359989411],[68.339958162,2.146973924],[66.002291175,1.943924725],[62.965645714,2.001644548],[59.230602181,2.276285374],[49.667642508,3.300937967],[37.318055378,4.667098366],[30.099727522,5.368623950],[22.186484010,6.023982432],[13.578905243,6.589325797],[4.277571625,7.020806027],[-5.716936442,7.274575103],[-16.404038556,7.306785010],[-27.783154313,7.073587729],[-39.853703312,6.531135244],[-44.865007554,6.089551584],[-49.738976655,5.374015723],[-54.449949403,4.426259200],[-58.972264585,3.288013552],[-63.280260988,2.001010317],[-67.348277400,0.606981034],[-71.150652608,-0.852342760],[-74.661725398,-2.335229527],[-77.855834560,-3.799947728],[-80.707318878,-5.204765826],[-85.279768138,-7.667775559],[-89.184075187,bottom] ];

module section() {
  translate([outerDiameter/2,0,0])
    scale(chord/size_section[0])
    translate([-size_section[0]/2,-bottom]) polygon(points=points_section_1);
}

//section();

render(convexity=2)
intersection() {
    rotate_extrude(d=outerDiameter,$fn=120) section();
    if (crossSectionDisplay) {
        translate([-outerDiameter/2-0.5, 0,0]) cube([outerDiameter+1,outerDiameter, size_section[1]+1]);
    }
}