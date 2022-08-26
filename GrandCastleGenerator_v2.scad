/*----------------------------------------------------------------------------*/
/*  Grand Castle Generator
/*  http://www.thingiverse.com/thing:1682427
/*
/*  Created by Ziv Botzer
/*  zivbot@gmail.com
/*
/*  Island generation code by Torleif 
/*  http://www.thingiverse.com/Torleif/about
/*
/*  License: Creative Commons - Attribution - Non-Commercial - Share Alike
/*
/*  8.8.2016  V2.0 up, with island and bug fixes
/*  20.7.2016 V1.0 on Thingiverse
/*----------------------------------------------------------------------------*/

// preview[view:south east, tilt:top diagonal]

// Master switch for details (windows, decorations...) - keep it off while you calibrate
generate_details = "Full"; // [Off, Basic, Full]

// Controls the big architectural changes
structure_random_seed = 14; // [1:1:400]

// Controls the small changes
detail_random_seed = 70; // [1:1:400]

// How many sides/facets for main perimiter wall
perimiter_sides = 8; // [4,5,6,8,12,60]

// Height in millimeters of a miniature knight visiting the castle
people_scale = 4; // [1:0.2:10]

// Wide & low structure (0), or narrow & tall (10)
tall_and_narrow = 5;  // [0:0.5:10]

// How many sub-elements
dense = 8;  // [0:0.5:10]

// Uniform & symmetric or a complete mess
chaos = 6; // [0:0.5:10]

// Island variations (0 = no island)
island_random_seed = 60; // [0:1:400]


/* [Hidden] */


/********** PLAY AND TEST AREA ***********

generate_details = "Off";
perimiter_sides = 8;
dense = 1;
people_scale = 7;
chaos = 7;
island_random_seed = 0;
tall_and_narrow = 5;

structure_random_seed = 992; 
detail_random_seed = 38; 
island_random_seed = 45;

*/

/*** Make every rebuild really random: ***

structure_random_seed = floor(rands(0,1000,1)[0]); 
detail_random_seed = floor(rands(0,1000,1)[0]); 
island_random_seed = floor(rands(1,1000,1)[0]);

echo("structure_random_seed=",structure_random_seed);
echo("detail_random_seed=",detail_random_seed);
echo("island_random_seed=",island_random_seed);

/*****************************************/

/*
// Place a 10x10cm square just for reference
translate([0,0,-1])
%cube([100,100,1],center=true);
*/

//********************** CONSTANTS *****************************

// Basics
sides_predef=[4,5,6,8,12,60]; // possible number of sides per polygon
$fn = 10; // Basic resolution (hardly affects anything, controlled locally)
overlap = 0.01; // used to make sure union/difference give nice results
max_roof_types = 3; // 4 allows for dome roofs
edge_margin_factor = 0.1;

// More constants

wall_thickness = 5; // [4:1:40]

window_width_base = 0.4*people_scale; // [1:0.5:10]
window_coverage = 0.1; // [0.1:0.1:1]

roof_flat_extend_ratio = 0.5; // [0.1:0.1:1] // Flat roofs - how wide?
pointed_roof_cone_base_ratio = 0.04; // ratio between inverted base cone of roof, and the cone of roof
roof_deco_spacing_height = 0.25*people_scale; // distance between ring decorations on the roofs
roof_pointed_ratio = 1.5; // [0.4:0.2:4]

turrets_roof_type = 0; // random

// collection of booleans for handling detail generation
gen_roof_decorations = (generate_details == "Basic") || (generate_details == "Full");
gen_windows = (generate_details == "Full");
gen_corbel_decoration = (generate_details == "Basic") || (generate_details == "Full");
gen_bricks = false;

gen_structure = true;
gen_roofs = true;



//********************** MAIN *****************************

tallness = tall_and_narrow/10; // = 0...1

// Setup perimiter values
max_height = 40;
max_diameter = 110;
min_perimiter_diameter = 30;
min_perimiter_height = 10;

//perimiter_sides = decide_number_of_sides(0, structure_random_seed);
perimiter_height = min_perimiter_height+(max_height-min_perimiter_height)*tallness;
perimiter_diameter = min_perimiter_diameter+(max_diameter-min_perimiter_diameter)*(1-tallness);

// Setup towers/turrets basic values
max_number_of_towers = (perimiter_sides <= 12)?perimiter_sides:12;

probability_of_towers = (dense/10)*3;
probability_of_turrets = dense/10;

perimiter_facet = perimiter_diameter*sin(180/max_number_of_towers); // facet width for perimiter

typical_tower_width = (0.6*perimiter_facet + 0.1*perimiter_sides)*(0.5 + 0.3*tallness)*(1 + 0.6*dense/10);
typical_tower_height = 1.3*perimiter_height;

turrets_height_ratio = 0.4+(1-tallness)*0.4;
turrets_width_ratio = 0.1+(dense/10)*0.3;
min_turret_width = 2*people_scale;
max_turret_width = 25;

gate_width = 2*people_scale;
gate_height = 3*people_scale;
    
gate_tower_width = chaos(3*gate_width, 0.5*gate_width, 2*gate_width);
gate_tower_height = chaos(1.4*gate_height, 0.1*gate_height, 0.5*gate_height);

island_height = perimiter_height*rands(0.7,1.5,1, island_random_seed)[0];
            

//*********************** MAIN *************************
union() {
difference() {
    
    translate([0,0,-overlap])
    union() {
        difference() {
            // walls
            turret_round ( perimiter_diameter, perimiter_height, false, perimiter_sides, 1, 2 );
            
            // negative volume
            if (gen_structure)
            color("Gainsboro")
            translate([0,0,-overlap])
            linear_extrude(200)
            rotate([0,0,correction_angle(perimiter_sides)])
            circle(d=perimiter_diameter-2*wall_thickness, $fn=perimiter_sides);
            
        }
        
        // gate tower
        translate([0,-inradius( perimiter_diameter, perimiter_sides ) /2 ])
        union() {
            //translate([0,0,-overlap])
            turret_round ( gate_tower_width, gate_tower_height, false, 4, 1, 2 );
        
            // Gate outer rim
            if (gen_structure)
            rotate([90,0,0])
            translate([0,gate_height/2,0])
            linear_extrude(inradius(gate_tower_width, 4)+2, center=true)
            special_rectangle(gate_width+people_scale/2, gate_height+people_scale/2);

        }
        
        // position towers around wall
        towers_symmetry = (chaos<7);
        count_till = towers_symmetry? ceil(max_number_of_towers/2)-1 : max_number_of_towers-1;

        rotate([0,0,perimiter_sides==5?-360/10:0])
        for (i = [0:count_till])
            if (rands(0,1,1,structure_random_seed+i*5)[0] <= probability_of_towers) {

                // give unique character to each tower
                m1 = (0.2+3*(1-tallness))*typical_tower_height;
                max_height_addition = (m1 < 40)?m1:40;
                    
                current_tower_width = chaos(typical_tower_width, 
                                        0.7*typical_tower_width,0.2*typical_tower_width,structure_random_seed*i);
                current_tower_height = chaos(typical_tower_height, 
                                        0.6*typical_tower_height,max_height_addition,structure_random_seed*i+2);
                
                current_tower_levels = ceil( current_tower_height / 
                                        chaos(30 * people_scale, 15*people_scale, 
                                        5*people_scale, detail_random_seed*i+2) );
                
                current_tower_sides = chaos_sides(perimiter_sides, detail_random_seed*i);
                current_tower_roof = chaos_roof(2, detail_random_seed*i);

                number_of_turrets = ceil(dense/3);
                number_recursion = ceil(dense/3);
                
                co = 0.97*perimiter_diameter/2;
                center_offset = chaos(co,0.2*co,0.1*co,structure_random_seed*i+2);
                                        
                                        
                rotate([0,0,i*(360/max_number_of_towers) + 360/max_number_of_towers/2 ])
                translate([0,center_offset,0])
                rotate([0,0,perimiter_sides==4?45:0]) {
                    turret_recursive(1, number_recursion,
                                    number_of_turrets,
                                    current_tower_width, 
                                    current_tower_height, 
                                    true, 
                                    current_tower_sides,
                                    current_tower_roof,
                                    detail_random_seed+i*100 );
                    
                    // add structure continuation below floor to prevent gaps
                    if (island_random_seed != 0) {
                        translate([0,0,-island_height+overlap])
                        turret_round(current_tower_width, island_height,
                                            false, current_tower_sides, 1, -1);
                    }
                }
                      
                //color("Blue")
                if (towers_symmetry)
                if ((perimiter_sides!=5) || ((perimiter_sides==5) && (i < count_till)) )
                rotate([0,0,-(i*(360/max_number_of_towers) + 360/max_number_of_towers/2) ])
                translate([0,center_offset,0])
                rotate([0,0,perimiter_sides==4?45:0]) {
                    turret_recursive(1, number_recursion,
                                    number_of_turrets,
                                    current_tower_width, 
                                    current_tower_height, 
                                    true, 
                                    current_tower_sides,
                                    current_tower_roof,
                                    detail_random_seed+i*100 );
                    
                    // add structure continuation below floor to prevent gaps
                    if (island_random_seed != 0) {
                        translate([0,0,-island_height+overlap])
                        turret_round(current_tower_width, island_height,
                                            false, current_tower_sides, 1, -1);
                    }
                }

        }  
    }
    

    // gate inner cut!
    if (gen_structure)
    color("Black")
    translate([0,0,-overlap])
    rotate([90,0,0])
    translate([0,gate_height/2,0])
    linear_extrude(500)
    special_rectangle(gate_width, gate_height);
    
    // trim everything below 0 Z
    if ((gen_structure) && (island_random_seed == 0))
    translate([0,0,-50])
    cube([500, 500, 100], center=true);
} // difference

    // ISLAND
    if (island_random_seed != 0)
        Island ( perimiter_diameter*rands(1,1.5,1, island_random_seed)[0]+max_turret_width*
            rands(0.1,0.5,1, island_random_seed)[0], 
        island_height,
        rands(-5,5,1, island_random_seed)[0],
        floor(rands(0,2,1, island_random_seed)[0]) ,perimiter_sides, island_random_seed,
        gate_tower_width);
}


/**************************************************************
   Helper functions
***************************************************************/

// chaos decides whether to randomize a value, and if so - what should be the value (val+-variance)
function chaos ( val, minus,plus, rseed=detail_random_seed ) = 
    val + ( (rands(-5,10,1,rseed)[0]>=chaos)? 0 : (chaos/10)*rands(-minus,plus,1,rseed)[0] );

function chaos_sides ( val, rseed=detail_random_seed ) = 
    (rands(-5,10,1,rseed)[0]>=chaos)? val : decide_number_of_sides(0,rseed);

function chaos_roof ( val, rseed=detail_random_seed ) = 
    (rands(-5,10,1,rseed)[0]>=chaos)? val : decide_roof_type(0,rseed);


function decide_roof_type( t, rseed ) = (t==0)? floor(rands(0,max_roof_types-0.01,1,rseed)[0]+1) : t;

function decide_number_of_sides ( s, rseed ) = (s==0) ? 
        sides_predef[ floor( rands(0,len(sides_predef)-0.01,1,rseed)[0] ) ] : s;

// the correction angle makes sure all polygons (no matter how many sides) align on one side
function correction_angle ( sides ) = (sides==4)?45: (sides==5)?18: (sides==8)?22.5: (sides==12)?15:0;

function decide_dimension ( dim, minimum, random_min, random_max, rseed ) =
     (dim == 0)? round(rands(random_min, random_max, 1, rseed)[0]) : (
     (dim >= minimum )? dim : minimum );

function inradius ( R, sides ) = R * cos( 180 / sides ); // inradius of the polygon shape






/**************************************************************
   Generate turrets with recursive children
***************************************************************/
module turret_recursive ( current_depth, max_recursion, number_children, w, h, main_tower, sides_, roof, rseed ) {
    
    if (current_depth <= max_recursion)
    union() {
        
        // how many sides if this were a main tower
        sides = decide_number_of_sides (sides_, rseed+current_depth );
        
        // decide roof type
        main_tower_roof_type = decide_roof_type (roof, rseed+current_depth);
        
        this_roof_type = (main_tower)? main_tower_roof_type : 
            decide_roof_type (turrets_roof_type, rseed+current_depth );
        
        // GENERATE TOWER/TURRET
        turret_round(w, h, !main_tower, sides, roof_pointed_ratio, this_roof_type);
        
        inradius = w * cos( 180 / sides ); 

        if (number_children >= 1)
        for (i = [1:number_children]) {
            r1 = rands(-200,200,1,rseed + i*10 + current_depth*100)[0];
            v1 = inradius*0.55;  // y (offset from center) translation of children
            
            // calc width of children
            cw1 = w*turrets_width_ratio;
            cw2 = (cw1 > min_turret_width)?cw1:min_turret_width; // set a minimum to turrets width
            t_width = (cw2 < max_turret_width)?cw2:max_turret_width; // set a maximum to turrets width
            
            t_height = h*turrets_height_ratio;
        
            z_transform = rands(2*t_width,1.0*h,1,rseed + i + current_depth)[0];

            rotate([0,0, r1 ] )
            translate([0,v1, z_transform])
            turret_recursive(current_depth+1, max_recursion, number_children-1, t_width, t_height, false, sides_, roof, rseed*i );
            
            /*if (next_levels_symmetry=="Yes") 
                rotate([0,0, 360-r1 ] )
                translate([0,v1, z_transform])
                turret_recursive(current_depth+1, max_recursion, number_children, t_width, t_height, false, sides_, roof, rseed*i+10 );*/
        }
    }
}



/**************************************************************
   Generate a complete turret
***************************************************************/
module turret_round ( w, h, generate_bottom, sides, roof_ratio, roof_type_ ) {

    body_height = h;
    roof_height = w*roof_ratio;
    base_height = w*2;
   
    //rotate([0,0,(sides==4)?45:0])
    rotate([0,0,correction_angle(sides)])
    union() {
        
        // roof
        translate([0,0,body_height-overlap])
           turret_roof (w, roof_height, sides, roof_type_);
       
        // body of turret
        if(gen_structure)
        turret_body(w, body_height, sides);

        // under part
        if(gen_structure)
        translate([0,0,overlap])
        if (generate_bottom) {
            color("Gainsboro")
             turret_base(w, base_height, sides);
        }
        
    }
}


/**************************************************************
   Generate turret ROOF according to type
***************************************************************/
module turret_roof ( w, h, sides, rtype ) {

    union() {

        if (rtype == 1) {
            // pointed roof
            if (gen_roofs)
                roof_pointed ( w, h, sides );
        }
        else if (rtype == 2) {
            // flat roof
            if(gen_structure)
                roof_flat (w, 1.8*people_scale, sides);
        }
        else if (rtype == 3) {
            // flat and point
            if(gen_structure) {
                roof_flat (w, 1.8*people_scale, sides);
                translate([0,0,0.5*people_scale-overlap])
                    turret_body ( 0.7*w, 2*people_scale, sides );
            }
            if (gen_roofs)
                translate([0,0,1.5*people_scale + people_scale-2*overlap])
                roof_pointed ( 0.7*w, 0.8*h, sides );
        }
        else if (rtype == 4) {
            // Dome
            if(gen_structure) {
                roof_flat (w, 1.1*people_scale, sides);
                translate([0,0,0.5*people_scale-overlap])
                    turret_body ( 0.7*w, people_scale, sides );
            }
            if (gen_roofs)
                translate([0,0,0.5*people_scale + people_scale-2*overlap])
                roof_dome ( 0.7*w, 0.8*h, sides );
        }
        
    }
}


/**************************************************************
   Generate FLAT ROOF with decorations
***************************************************************/
module roof_flat ( w, h, sides ) {

    roof_bottom_part_height = 1.8*roof_flat_extend_ratio*people_scale;
    roof_top_part_height = h-roof_bottom_part_height;
    
    roof_top_width = w+1.8*roof_flat_extend_ratio*people_scale;
    roof_overhang = (roof_top_width - w);
    
    roof_scale = roof_top_width / w;
    
    shortest_radius = w * cos( 180 / sides ) / 2; 
        // ^-- for polygons with low number of sides, gives the constrained radius
    
    circular_n = (sides <= 12)?sides:12;
    
    correct = correction_angle(sides);
    
    color("LightGrey")
    union() {
        translate([0,0,roof_bottom_part_height-overlap])
        difference() 
        {
            // top part 
            
            linear_extrude(roof_top_part_height)
            circle(d=roof_top_width,$fn=sides);
            
            // emboss center
            translate([0,0,0.3*roof_top_part_height])
            linear_extrude(roof_top_part_height)
            circle(d=w,$fn=sides);
            
            // cut archers slots
            translate([0,0,0.5*roof_top_part_height])
            pattern_around_polygon (roof_top_width, roof_top_part_height, sides, 
                                0, 0,
                               element_max_width=people_scale, 
                               element_height=roof_top_part_height, 
                               extrude_length=people_scale,
                               distribution_ratio=1 )
                square([0.4,1], center=true);
        }

        
        
        // base part with corbels
        difference() {
            linear_extrude(roof_bottom_part_height, scale=roof_scale)
             circle(d=w*1.0,$fn=sides);
        
            if (gen_corbel_decoration)
            translate([0,0,-0.1*roof_bottom_part_height])
            pattern_around_polygon (roof_top_width, roof_bottom_part_height, sides, 
                                    people_scale, 0,
                                    element_max_width=0.7*people_scale, 
                                    element_height=roof_bottom_part_height, 
                                    extrude_length=roof_overhang,
                                    distribution_ratio=1 )
                                    special_rectangle(0.6,1);
            
            
            /*pattern_around_polygon (w, h, sides, 
            width_padding, height_padding,
            element_max_width, element_height, 
            extrude_length, distribution_ratio)*/
        }
    }
}

/**************************************************************
   Generate POINTED ROOF with decorations
***************************************************************/
module roof_pointed ( w, h, sides ) {
    
    roof_inverted_cone_height = h*pointed_roof_cone_base_ratio;
    roof_cone_height = h - roof_inverted_cone_height;


    roof_cone_base_width = w + 2*roof_inverted_cone_height;
    
    roof_tip_scale = 0.05;
    
    roof_cone_delta = roof_cone_base_width - roof_cone_base_width*roof_tip_scale;
    
    shortest_radius = w * cos( 180 / sides ) / 2; 
        // ^-- for polygons with low number of sides, gives the constrained radius

    union() {
        // roof cone
        color("OrangeRed")
        translate([0,0,roof_inverted_cone_height-overlap])
          linear_extrude(roof_cone_height, scale=roof_tip_scale)
          circle(d = roof_cone_base_width, $fn=sides);

        // up-side-down cone below roof cone
        color("OrangeRed")
        linear_extrude(roof_inverted_cone_height, scale=roof_cone_base_width/w)
          circle(d = w, $fn=sides); 



        // generate decos
       color("OrangeRed") 
        if (gen_roof_decorations) {

            translate([0,0,roof_inverted_cone_height]) {
                
                // small roofs around base of roof
                default_size = window_width_base*1.5;
                s = (sides <= 12)?sides:12;
                mx = 0.7*roof_cone_base_width*3.14/s;
                
                deco_size = (default_size <= mx)?default_size:mx;
                
                translate([0,0,overlap])
                intersection() {
                    pattern_around_polygon ( 0.95*roof_cone_base_width,
                                    deco_size+0.1, sides, 
                                    0.05*roof_cone_base_width,
                                    0, // vertical margin
                                    element_max_width=deco_size, 
                                   element_height=deco_size, 
                                   extrude_length=0.5*roof_cone_base_width,
                                   distribution_ratio=1 )
                        special_rectangle(0.8,1);

                    translate([0,0,-overlap])
                    linear_extrude(deco_size+1)
                    circle(d=roof_cone_base_width-overlap, $fn=sides);
                }
               
                // round horz rails along roof
                rail_spacing = 2*roof_deco_spacing_height;
                how_many_rows =  floor( roof_cone_height / rail_spacing);
                if (how_many_rows>1) {
                    rail_spacing2 = roof_cone_height / how_many_rows;
                    rail_height = 0.1*rail_spacing2;
                
                    color("Maroon")
                    for (i = [1:how_many_rows-1]) {
                        translate([0,0,i*rail_spacing2])
                            linear_extrude(rail_height)
                            circle(d = roof_cone_base_width-i*(roof_cone_delta/how_many_rows), $fn=sides);
                    }
                }
                
                
            }
        }
    }

}


/**************************************************************
   Generate turret BODY with decorations
***************************************************************/
module turret_body ( w, h, sides ) {

    difference () {
        color("LightGrey")
        linear_extrude(h, convexity = 2) circle (d=w, $fn=sides);
        
        // _____Generate windows______
        color([0.3,0.3,0.3])
        if (gen_windows) {
            windows_start_height = 0.3*h;
            
            translate([0,0,windows_start_height])
            pattern_around_polygon (w, h-windows_start_height, sides, 
                                    edge_margin_factor*w,
                                    edge_margin_factor*h,
                                    window_width_base,
                                    people_scale,
                                    0.2*w,
                                    window_coverage )
                scale([0.8,1/4,1])
                special_rectangle(0.8,3);
        }
        
        // _____Generate brick pattern______
        color("DarkGray")
        if (gen_bricks) {
            
            how_many_rows =  floor( (h-brick_space) / (brick_height+brick_space));
            brick_height2 = (h-((how_many_rows-1)*brick_space)) / how_many_rows;
            
            how_many_cols = floor(w*3.1416/brick_horz);
            bricks_angle = 360/how_many_cols;

            difference () {
            
                union() {
                    // create the horizontal slots between the rows of bricks
                    for (i = [1: 1:how_many_rows-1] ) {
                        translate([0,0,i*(brick_height2+brick_space)-brick_space]) {
                                linear_extrude(brick_space,false) {
                                    circle(d = w*1.5, $fn=sides);
                            }
                        }
                    }
            
                    // create the vertical slots between the columns of bricks + random rotation
                    union()
                    for(vi = [0:how_many_rows-1]) {
                        rand_rotate = rands(0,1,1)[0];
                        translate([0,0,brick_height2/2+vi*(brick_height2+brick_space)])
                        for (i = [0: 1:(how_many_cols/2)-1] ) {
                            rotate([0,0,(i+rand_rotate)*bricks_angle])
                            color ("DimGray")
                            cube([brick_space, 1.1*w, brick_height2+0.2], center=true);
                        }
                    }
                    
                }
                
                // substract middle volume 
                translate([0,0,-0.5])
                linear_extrude(h+5) circle (d=w-brick_space_depth*2, $fn=sides);
            }
        }
        
    }    
    
}


/**************************************************************
   Generate turret BASE with decorations
***************************************************************/
module turret_base ( w, h, sides ) {

    circular_n = (sides <= 6)?sides:6;
    shortest_radius = w * cos( 180 / sides ) / 2; 
    
    correct = correction_angle(sides);
    
    color("Gainsboro")
    rotate([0,0,(sides==4)?-45:0]) // fix square alignment
    union () {
        // inverted cone
        translate([0,-w/2,0])
        rotate([180,0,0])
        linear_extrude(height = h, scale=0.1, convexity = 3)
        translate([0, -w/2, 0])
        rotate([0,0,(sides==4)?45:0]) // fix square alignment
         difference() {
             
             circle(d = w, $fn=sides);
         
             if (gen_corbel_decoration) {
                rotate([0,0,correct])
                for (i = [0:circular_n-1]){
                    d_ = 0.5*3.1416*w/circular_n;
                    rotate([0,0, i*(360/circular_n) ])
                    translate([0,1.1*shortest_radius,0])
                    circle(d=d_, $fn=sides*4);
                }
            }
         }
         
        if (gen_corbel_decoration) {
            translate([0,-w/4,0])
            rotate([180,0,0])
             linear_extrude(height = h/2, scale=0.1, convexity = 3)
             translate([0, -w/4, 0])
             rotate([0,0,(sides==4)?45:0])
             circle(d = w, $fn=sides);
         }
        
   }
}

/**************************************************************
   Generate rectangle with pointed 45deg tip (for windows and other decorations)
***************************************************************/
module special_rectangle (w, h) {
    // if h is too small its ignored
    // ^-- thats not good behaviour, leading to misalignment <<<<
    offs = sqrt(2*pow(w/2,2));
    rotate([180,0,0])
    translate([0,-h/2,0])
    union() {
        hull() {
            translate([0,offs/2,0])
            rotate([0,0,45])
            square(w/2,center=true);

            difference() {
                translate([0,offs,0])
                circle(d=w, $fn=20);
                
                // substract for half circle
                translate([0,offs+w/2,0])
                square([w*1.1,w],center=true);
            }
        }
        if (h > offs)
                translate([0,offs+(h-offs)/2,0])
                square([w,h-offs],center=true);
    }
}


/**************************************************************
   module for distributing elements along floors, sides and per each facet
***************************************************************/
module pattern_around_polygon (w, h, sides, 
            width_padding, height_padding,
            element_max_width, element_height, 
            extrude_length, distribution_ratio) {
// distribute child geometry along sides of defined polygon (w,h,sides)
// size of 2D element given should be 1X1 to completely fill the grid, or smaller for partial.

    h2 = h-height_padding;

    vertical_n = floor(h2/element_height); // how many rows of elements
    element_height2 = h2/vertical_n;

    // treat circular as (diameter/element_width) sided
    circular_n = (sides > 12)? floor(w*3.1415/(element_max_width)): sides; 

    ww = w*sin(180/circular_n); // facet width calculated per circular_n
    element_width = (ww<element_max_width)?ww:element_max_width; // limit window width

    // for circular only one element per facet
    side_length = w*sin(180/sides)-width_padding;
    elements_per_facet = (sides <= 12) ?
                floor ( side_length / element_width ) : 1;
    
    element_width2 = (sides <= 12) ?
                side_length / elements_per_facet : element_width;
    
    inradius = w * cos( 180 / sides ); // inradius of the polygon shape
    
    delta_per_facet = 0.5*(elements_per_facet-1) * element_width2;
    
    rotate([0,0,correction_angle(sides)])
    for (a=[1:1:vertical_n]) // per each floor
    for (b=[0:1:circular_n]) {   // per each side
        for (c=[0:1:elements_per_facet-1]) // per each facet with multiple windows
        if (rands(0,1,1,detail_random_seed*a*b*c)[0] <= distribution_ratio)
        rotate([0,0,b*360/circular_n])
        translate([-delta_per_facet + c*element_width2,0,0])
        translate([0,inradius/2,(a-0.5)*(h2/vertical_n) + height_padding/2]) {
            union() {
                rotate([90,0,0]) {
                    linear_extrude(extrude_length,center=true)
                    scale([element_width2, element_height2])
                    children(0);
                }
            }
        }
    }
}





module Island(r,h,over,moat,sides=4, rseed, gate_tower_width){

    color("Gray")
    intersection(){ 


    translate([0,0,-h])
        cylinder(2*h,r*1.1,r*1.1);// cut it all to size
        
    
    difference(){ //Island minus cortyard and gate

    union(){
        

        ps=correction_angle(perimiter_sides);
        // main cliff blocks

        loops=3;
        l=30;// num points
        n=30;// num faces
        
        for(loop=[0:loops]){
            
            z=rands(0,360,l+1,rseed+loop);
            t=rands(90,180,l+1,rseed+loop+1);
            v21=rands(0,l-1,n*3+1,rseed+loop);

            v1 = [ for(i=[0:l])               
                [sin(z[i])*cos(t[i]),cos(z[i])*cos(t[i]),sin(t[i])]];

            v2 = [for(j=[0:n])[floor(v21[j]),floor(v21[j+n]),floor(v21[j+n+n])]]; 


            hull()
            translate([0,-people_scale*.65+over*2,-h*2.2])
            scale([r*0.95,r*0.95,h*2.66-r*0.01+over])
            polyhedron(v1, v2);

        }

        // castle and gate footprint
        union(){
            midr=rands(-1,1,1,rseed)[0]*25;
            
            hull(){

                translate([0,0,-h*0.05]) 
                rotate([0,0,ps])
                linear_extrude(1, 0, convexity = 3) 
                offset(r = 0.5*people_scale)
                    circle(r/2,$fn=sides);

                // footprint
                translate([0,-5,-h*0.6])
                rotate([0,0,midr])
                linear_extrude(1, 0, convexity = 3) 
                offset(r = people_scale)
                  circle(r*0.65,$fn=sides); // footprint half way down

                // gate tower footprint
                translate([0,-inradius( perimiter_diameter, perimiter_sides ) /2 ])
                union() {
                   turret_round ( gate_tower_width+people_scale*2, 1, false, 4, -1, -1 );
                   linear_extrude(1, 0, convexity = 3) 
                        offset(r = people_scale)
                        square([gate_width+3,gate_tower_width], center=true);
                }
            }

            hull(){
                translate([0,-5,-h*0.6])
                rotate([0,0,midr])
                linear_extrude(1, 0, convexity = 3)
                offset(r = people_scale)
                circle(r*0.65,$fn=sides  );


                translate([0,0,-h*2])
                rotate([0,0,rands(0,45,1,rseed)[0]])
                linear_extrude(1, 0, convexity = 3) 
                offset(r = people_scale)
                circle(r,$fn=sides /2);
                
                translate([0,0,-h*2])
                rotate([0,0,rands(0,360,1,2*rseed)[0]])
                linear_extrude(1, 0, convexity = 3) 
                offset(r = 4)
                circle(r,$fn=sides  );

            }
        }
    }
       

    //////////////////////shapes the top of the island to fit the castle
    // negative volume
    if (gen_structure)
    translate([0,0,-overlap+0.95])
    linear_extrude(200)
    rotate([0,0,correction_angle(perimiter_sides)])
    circle(d=perimiter_diameter-2*wall_thickness + 2*overlap, $fn=perimiter_sides);
    
    // gate inner cut!
    if (gen_structure)
    translate([0,0,-overlap-0.051])
    rotate([90,0,0])
    //translate([0,(3*people_scale)/2+1,perimiter_diameter/2 -3*people_scale])
    translate([0,(3*people_scale)/2+1,0])
    linear_extrude(15*people_scale)
    special_rectangle(2.01*people_scale, 3*people_scale); 
    
    if (gen_structure)
        translate([0,0,-overlap-0.051])
        rotate([90,0,0])
        translate([0,(3*people_scale)/2+1,perimiter_diameter/2 -3*people_scale+1])
        linear_extrude(20*people_scale)
        special_rectangle(2.01*people_scale, 3*people_scale);

    if (moat==1){   
        hull(){ 
            translate ([0,0,1.8])
            rotate([0,0,0])
            turret_round ( perimiter_diameter+max_turret_width*1.1, 1, false, perimiter_sides*2,0,0);
           
            color("Grey") 
            translate ([0,0,1.8+h*2])
            scale([2,2,1])
            rotate([0,0,0])
            turret_round ( perimiter_diameter+max_turret_width*1.1, h, false, perimiter_sides*3,0,0); }}

    }
    }
}


// And they lived happily ever after...


