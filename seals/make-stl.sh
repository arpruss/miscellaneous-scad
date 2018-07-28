for x in VA*.txt ; do
    echo $x
    meshlabserver -i $x -o ${x%.*}.stl -s process_seal.mlx
done