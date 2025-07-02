for x in 0 28 29 30 32 33.5 34 36 40 42 44 ; do
	openscad barbedconnector.scad -D hoopDiameter_inches=$x -o barbedconnector-$x.stl
done