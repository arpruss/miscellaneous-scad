/*
 *    polyTests.scad    by aubenc @ Thingiverse
 *
 * This script contains few examples to show how to use the modules
 * included in the library script: 	polyScrewThead.scad
 *
 * http://www.thingiverse.com/thing:8796
 *
 * CC Public Domain
 */
include <polyScrewThread.scad>

PI=3.141592;

/* Example 01.
 * Just a 100mm long threaded rod.
 *
 * screw_thread(15,   // Outer diameter of the thread
 *               4,   // Step, traveling length per turn, also, tooth height, whatever...
 *              55,   // Degrees for the shape of the tooth 
 *                       (XY plane = 0, Z = 90, btw, 0 and 90 will/should not work...)
 *             100,   // Length (Z) of the tread
 *            PI/2,   // Resolution, one face each "PI/2" mm of the perimeter, 
 *               0);  // Countersink style:
 *                         -2 - Not even flat ends
 *                         -1 - Bottom (countersink'd and top flat)
 *                          0 - None (top and bottom flat)
 *                          1 - Top (bottom flat)
 *                          2 - Both (countersink'd)
 */
// screw_thread(15,4,55,100,PI/2,2);


/* Example 02.
 * A nut for the previous example.
 *
 * hexa_nut(24,  // Distance between flats
 *           8,  // Height 
 *           4,  // Step height (the half will be used to countersink the ends)
 *          55,  // Degrees (same as used for the screw_thread example)
 *          15,  // Outer diameter of the thread to match
 *         0.5)  // Resolution, you may want to set this to small values
 *                  (quite high res) to minimize overhang issues
 *
 */
// hex_nut(24,8,4,55,15,0.5);


/* Example 03.
 * A screw, threaded all the way, with hex head.
 *
 * hex_screw(15,  // Outer diameter of the thread
 *            4,  // Thread step
 *           55,  // Step shape degrees
 *           30,  // Length of the threaded section of the screw
 *          1.5,  // Resolution (face at each 2mm of the perimeter)
 *            2,  // Countersink in both ends
 *           24,  // Distance between flats for the hex head
 *            8,  // Height of the hex head (can be zero)
 *            0,  // Length of the non threaded section of the screw
 *            0)  // Diameter for the non threaded section of the screw
 *                     -1 - Same as inner diameter of the thread
 *                      0 - Same as outer diameter of the thread
 *                  value - The given value
 *
 */
// hex_screw(15,4,55,30,1.5,2,24,8,0,0);


/* Example 04.
 * A screw with a non threaded section and with hex head.
 *
 * Same module and parameters than for Example 03 but for the length of the non 
 * threaded section wich is set to 50mm here.
 *
 */
// hex_screw(15,4,55,30,1.5,2,24,8,50,0);


/* Example 05.
 *
 * A rod whith a middle section without thread and, a portion of it, hex shaped.
 * One end is threaded in the opposite direction than the other.
 *
 * So... yes, OpenSCAD mirror feature will change the thread direction.
 *
 */

render(convexity=4)
translate([0,0,32.5+5+7.5])
union()
{
    hex_screw(15,4,55,32.5,1.5,2,15,5,7.5,0);
    mirror([0,0,1]) hex_screw(15,4,55,32.5,1.5,2,15,5,7.5,0);
}
