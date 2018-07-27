echo Generating OpenSCAD
python ../scripts/cylinder2scad.py $1-in.stl > $1.scad
echo Generating STL 1x
openscad -o $1-1x.stl -D "reliefFactor=1" -D "holeDiameter=$2" $1.scad
echo Generating STL 1.5x
openscad -o $1-1.5x.stl -D "reliefFactor=1.5" -D "holeDiameter=$2" $1.scad
echo Generating STL 2x
openscad -o $1-2x.stl -D "reliefFactor=2" -D "holeDiameter=$2" $1.scad
