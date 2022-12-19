use <ribbon.scad>;

//<params>
frontPanel = 13.32;
backPanel = 19.6;
offset = 45;
tolerance = 0.75;

width = 20;
thickness = 3;
//</params>

frontPanelAdj = frontPanel + tolerance + thickness;
backPanelAdj = backPanel + tolerance + thickness;
offsetAdj = offset + thickness/2;

profile = [ [-backPanelAdj, offsetAdj], 
            [-backPanelAdj, 0],
            [0,0],
            [0, offsetAdj],
            [frontPanelAdj, offsetAdj],
            [frontPanelAdj, 0] ];
            
linear_extrude(height=width) {
    ribbon(profile, thickness=thickness);           
    translate(profile[1]-[thickness,thickness]/6) circle(d=thickness*2, $fn=16);
    translate(profile[len(profile)-2]+[thickness,thickness]/6) circle(d=thickness*2, $fn=16);
}