// Customizable OpenSCAD 3D Surface Plotter by dnewman and arpruss is licensed under the Creative Commons - Attribution - Share Alike license.
// https://creativecommons.org/licenses/by-sa/3.0/
// Remixed from: http://www.thingiverse.com/thing:24897


include <eval.scad>;

//<params>
z = "20*COS(sqrt(x^2+y^2))*exp(-(x^2+y^2)/20)"; // use all-caps trigonometric functions for radian values (e.g., COS(x), ACOS2(x,y))
xMin = -9.42;
xMax = 9.42;
yMin = -9.42;
yMax = 9.42;
zMin = -14;
resolution = 50;
//</params>

pi = 3.14159265358979;
e = 2.71828182845904;
fc = compileFunction(z);

function z(x,y) = eval(fc, [["x", x], ["y", y], ["pi", pi], ["e", e]]);

3dplot([xMin,xMax],[yMin,yMax],[resolution,resolution],zMin);

// OpenSCAD 3D surface plotter, z(x,y)
// Dan Newman, dan newman @ mtbaldy us
// 8 April 2011
// 10 June 2012 (revised)
//
// For 2D plots, please see polymaker's OpenSCAD 2D graphing
// program, http://www.thingiverse.com/thing:11243.

// --- BEGIN EXAMPLES ---

// Square ripples in a pond
//function z(x,y) = 2*COS(rad2deg(abs(x)+abs(y)));
//3dplot([-4*pi,4*pi],[-4*pi,4*pi],[50,50],-2.5);

// A wash board
//function z(x,y) = cos(rad2deg(abs(x)+abs(y)));
//3dplot([-4*pi,4*pi],[-4*pi-20,4*pi-20],[50,50],-1.1);

// Uniform bumps and dips
//function z(x,y) = 5*cos(rad2deg(x)) * sin(rad2deg(y));

// Looks similar to the sombrero function (needs the J1 Bessel function)
//function z(x,y) = 15*cos(180*sqrt(x*x+y*y)/pi)/sqrt(2+x*x+y*y);
//3dplot([-4*pi,+4*pi],[-4*pi,+4*pi],[50,50],-5);

// --- END EXAMPLES --

// --- Useful code begins here


// OpenSCAD trig functions use degrees rather than radians
function rad2deg(a) = a * 180 / pi;

// For the cube vertices
//
//   cube_vertices = [ [0,0,0], [1,0,0], [0,0,1], [1,0,1],
//                     [0,1,0], [1,1,0], [0,1,1], [1,1,1] ];
//
// The two upright prisms which the cube can be divided into are
//
//   prism_faces_1 = [[3,2,7],[5,0,1], [0,2,1],[2,3,1], [1,3,5],[3,7,5], [7,2,5],[2,0,5]];
//   prism_faces_2 = [[6,7,2],[4,0,5], [7,6,4],[4,5,7], [6,2,0],[0,4,6], [2,7,5],[5,0,2]];
//
// If you need help visualizing them, you can draw them,
//
//   polyhedron(points=cube_vertices, triangles=prism_faces_1);
//   polyhedron(points=cube_vertices, triangles=prism_faces_2);
//
// However, since we want to evaluate z(x,y) at each vertex of a prism
// AND each prism doesn't need all the cube vertices, we can save a few
// calculations by having two sets of vertices,
//
//   prism_vertices_1 = [ [0,0,0], [1,0,0], [0,0,1], [1,0,1], [1,1,0], [1,1,1] ];
//   prism_faces_1    = [ [3,2,5],[4,0,1], [0,2,1],[2,3,1], [1,3,4],[3,5,4], [5,2,4],[2,0,4] ];
//   prism_vertices_2 = [ [0,0,0], [0,0,1], [0,1,0], [1,1,0], [0,1,1], [1,1,1] ];
//   prism_faces_2    = [[4,5,1],[2,0,3], [5,4,2],[2,3,5], [4,1,0],[0,2,4], [1,5,3],[3,0,1]];
//
//   polyhedron(points=prism_vertices_1, triangles=prism_faces_1);
//   polyhedron(points=prism_vertices_2, triangles=prism_faces_2);

// Our NxM grid is NxM cubes, each cube split into 2 upright prisms
prism_faces_1 = [ [3,2,5],[4,0,1], [0,2,1],[2,3,1], [1,3,4],[3,5,4], [5,2,4],[2,0,4] ];
prism_faces_2 = [[4,5,1],[2,0,3], [5,4,2],[2,3,5], [4,1,0],[0,2,4], [1,5,3],[3,0,1]];

// 3dplot -- the 3d surface generator
//
// x_range -- 2-tuple [x_min, x_max], the minimum and maximum x values
// y_range -- 2-tuple [y_min, y_max], the minimum and maximum y values
//    grid -- 2-tuple [grid_x, grid_y] indicating the number of grid cells
//              along the x and y axes
//   z_min -- Minimum expected z-value; used to bound the underside of the surface
//    dims -- 2-tuple [x_length, y_length], the physical dimensions in millimeters

module 3dplot(x_range=[-10, +10], y_range=[-10,10], grid=[50,50], z_min=-5, dims=[80,80])
{
    dx = ( x_range[1] - x_range[0] ) / grid[0];
    dy = ( y_range[1] - y_range[0] ) / grid[1];

    // The translation moves the object so that its center is at (x,y)=(0,0)
    // and the underside rests on the plane z=0

    scale([dims[0]/(max(x_range[1],x_range[0])-min(x_range[0],x_range[1])),
           dims[1]/(max(y_range[1],y_range[0])-min(y_range[0],y_range[1])),1])
    translate([-(x_range[0]+x_range[1])/2, -(y_range[0]+y_range[1])/2, -z_min])
    union()
    {
        for ( x = [x_range[0] : dx  : x_range[1]] )
        {
            for ( y = [y_range[0] : dy : y_range[1]] )
            {
                polyhedron(points=[[x,y,z_min], [x+dx,y,z_min], [x,y,z(x,y)], [x+dx,y,z(x+dx,y)],
                                   [x+dx,y+dy,z_min], [x+dx,y+dy,z(x+dx,y+dy)]],
                           triangles=prism_faces_1);
                polyhedron(points=[[x,y,z_min], [x,y,z(x,y)], [x,y+dy,z_min], [x+dx,y+dy,z_min],
                                   [x,y+dy,z(x,y+dy)], [x+dx,y+dy,z(x+dx,y+dy)]],
                           triangles=prism_faces_2);
            }
        }
    }
}

