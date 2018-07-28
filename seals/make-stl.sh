for x in VA[0-9][0-9][0-9][0-9][0-9].txt ; do
    echo $x
    meshlabserver -i $x -o ${x%.*}.stl -s process_seal.mlx
    pypy ../scripts/relief.py ${x%.*}.stl 1.5
    pypy ../scripts/relief.py ${x%.*}.stl 2
    pypy unroll.py $x
    echo 'color("gray") import("'${x%.*}-unroll-slab.stl'");' > ${x%.*}-unroll.scad
    echo 'translate([0,-45,0]) text("'${x%.*}$'",size=8);' >> ${x%.*}-unroll.scad
    openscad --camera 80,0,400,80,0,0 --autocenter --imgsize=3000,1500 -o ${x%.*}.png ${x%.*}-unroll.scad 
    convert ${x%.*}.png -trim  ${x%.*}.jpg
    rm ${x%.*}.png
done