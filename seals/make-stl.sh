for x in VA*.txt ; do
    echo $x
#    meshlabserver -i $x -o ${x%.*}.stl -s process_seal.mlx
    pypy ../scripts/relief ${x%.*}.stl 1.5
    pypy ../scripts/relief ${x%.*}.stl 2
done