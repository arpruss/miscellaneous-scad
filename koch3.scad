// OpenSCAD file automatically generated by svg2cookiercutter.py
wallHeight = 12;
wallFlareWidth = 3;
wallFlareThickness = 1.5;
minWallWidth = 1;
maxWallWidth = 3;
insideWallFlareWidth = 2;
insideWallFlareThickness = 1.5;
minInsideWallWidth = 1;
maxInsideWallWidth = 3;
featureHeight = 8;
minFeatureThickness = 0.8;
maxFeatureThickness = 3;
connectorThickness = 1;
size = 90.015;

module dummy() {}

scale = size/90.015;

module ribbon(points, thickness=1, closed=false) {
    p = closed ? concat(points, [points[0]]) : points;
    
    union() {
        for (i=[1:len(p)-1]) {
            hull() {
                translate(p[i-1]) circle(d=thickness, $fn=8);
                translate(p[i]) circle(d=thickness, $fn=8);
            }
        }
    }
}

module cookieCutter() {

path0=scale*[[-66.609,-0.927],[-66.609,9.075],[-73.995,14.076],[-66.609,19.076],[-66.609,29.078],[-73.995,34.079],[-81.381,29.078],[-81.381,39.080],[-88.767,44.081],[-81.381,49.082],[-81.381,59.083],[-73.995,54.082],[-66.609,59.083],[-66.609,69.085],[-73.995,74.086],[-66.609,79.087],[-66.609,89.088],[-59.222,84.087],[-51.836,89.088],[-51.836,79.087],[-44.450,74.086],[-37.064,79.087],[-37.064,89.088],[-29.678,84.087],[-22.291,89.088],[-22.291,79.087],[-14.905,74.086],[-22.291,69.085],[-22.291,59.083],[-14.905,54.082],[-7.519,59.083],[-7.519,49.082],[-0.133,44.081],[-7.519,39.080],[-7.519,29.078],[-14.905,34.079],[-22.291,29.078],[-22.291,19.076],[-14.905,14.076],[-22.291,9.075],[-22.291,-0.927],[-29.678,4.074],[-37.064,-0.927],[-37.064,9.075],[-44.450,14.076],[-51.836,9.075],[-51.836,-0.927],[-59.222,4.074],[-66.609,-0.927]];
render(convexity=10) linear_extrude(height=(featureHeight)) ribbon(path0,thickness=min(maxFeatureThickness,max(0.144,minFeatureThickness)));
}

translate([88.767*scale,0.927*scale,0]) cookieCutter();
