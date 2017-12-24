from blockscad import *
from math import *

NUM_LEVELS = 50

def rowSize(i):
    return 1 if i == 0 else int(ceil((i+1)/2.));

def get(i,j):
    if i >= NUM_LEVELS:
        return EX(0)
    elif i <= 1 and j != 0:
        return get(i,0)
    rs = rowSize(i)
    if j == -1:
        return get(i,1)
    elif j == rs:
        if i % 2:
            return get(i,rs-1)
        else:
            return get(i,rs-2)
    return EX("data_%d_%d" % (i,j))
    
def neighborCount(i,j):
    if i == 0:
        return get(1,0)*6
    elif j == 0:
        return get(i,-1)+get(i,1)+get(i+1,-1)+get(i+1,0)+get(i+1,1)+get(i-1,0)
    else:
        return get(i,j-1)+get(i,j+1)+get(i+1,j)+get(i+1,j+1)+get(i-1,j)+get(i-1,j-1)
        
def emitter():
    parts = []
    for i in range(NUM_LEVELS):
        for j in range(rowSize(i)):
            parts.append( (get(i,j)>0).statementif( invokeModule("draw", [EX(i),EX(j)] ) ) )
    return parts[0].union(*parts[1:])
    
def evolved(i,j):
    return (get(i,j)>0).ifthen(invokeFunction("survive", [get(i,j), neighborCount(i,j)]), invokeFunction("generate", [get(i,j), neighborCount(i,j)]))
    
def iterator():
    args = [EX("iterations")-1]+[evolved(i,j) for i in range(NUM_LEVELS) for j in range(rowSize(i))]
    return invokeModule("evolve", args)

vars = ["data_%d_%d" % (i,j) for i in range(NUM_LEVELS) for j in range(rowSize(i))]
varCount = len(vars)

out = []

module("draw", ["i","j"], None)
module("evolve", ["n"]+vars, None)
module("survive", ["self", "neighbors"], None)
module("generate", ["self", "neighbors"], None)
out += module("evolve", ["n"]+vars, [ (EX("n")==0).statementif( emitter() ).union( *iterator() ) ])
out += module("go", [], invokeModule("evolve", [EX("iterations")]+[EX(0) for i in range(varCount)]))

addhead(out)

addtail(out)
print('\n'.join([str(line) for line in out]))
