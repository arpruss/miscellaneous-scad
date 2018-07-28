for x in VA*3D_[0-9][0-9][0-9][0-9].txt ; do
    echo $x
#    meshlabserver -i $x -o ${x%.*}.stl -s process_seal.mlx
#    pypy ../scripts/relief.py ${x%.*}.stl 1.5
#    pypy ../scripts/relief.py ${x%.*}.stl 2
#    pypy unroll.py $x
    echo 'color("gray") import("'${x%.*}-unroll-slab.stl'");' > ${x%.*}-unroll.scad
    openscad --camera 50,0,300,50,0,0 --autocenter --imgsize=1024,500 -o ${x%.*}.png ${x%.*}-unroll.scad 
done