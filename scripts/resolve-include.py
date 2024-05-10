import sys
import re
import os

output = []
params = []
skip = []
current = output

stack = []

def process(name,level=0):
    global current
    with open(name) as f:
        for line in f:
            m = re.match(r'(include|use)\s+<([^>]+)>', line)
            if m:
                dep = line.strip()
                current.append("\n//BEGIN DEPENDENCY: "+dep)
                process(m.group(2),level=level+1)
                current.append("\n//END DEPENDENCY: "+dep+"\n")
            else:
                lineStripped = line.strip()
                if lineStripped == "//<params>":
                    stack.append(current)
                    current = params
                elif lineStripped == "//</params>":
                    current = stack.pop()
                elif lineStripped == "//<skip>":
                    stack.append(current)
                    if level:                        
                        current = skip
                elif lineStripped == "//</skip>":
                    current = stack.pop()
                else:
                    current.append(line.rstrip())
 

name = sys.argv[1]

process(name)
base, ext = os.path.splitext(name)

with open(base+"-standalone"+ext, "w") as f:
    f.write("""// This file was processed by resolve-include.py [https://github.com/arpruss/miscellaneous-scad/blob/master/scripts/resolve-include.py] 
// to include  all the dependencies inside one file.

""")

    if params:
        params.append("\nmodule end_of_parameters_dummy() {}\n")

    f.write("\n".join(params+output))
