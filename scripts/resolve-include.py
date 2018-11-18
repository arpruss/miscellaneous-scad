import sys
import re

output = []
params = []
skip = []
current = output

stack = []

def process(name):
    global current
    with open(name) as f:
        for line in f:
            m = re.match(r'(include|use)\s+<([^>]+)>', line)
            if m:
                current.append("\n//BEGIN: "+line.strip())
                process(m.group(2))
                current.append("\n//END: "+line.strip()+"\n")
            else:
                lineStripped = line.strip()
                if lineStripped == "//<params>":
                    stack.append(current)
                    current = params
                elif lineStripped == "//</params>":
                    current = stack.pop()
                elif lineStripped == "//<skip>":
                    stack.append(current)
                    current = skip
                elif lineStripped == "//</skip>":
                    current = stack.pop()
                else:
                    current.append(line.rstrip())
                
process(sys.argv[1])
if params:
    params.append("\nmodule end_of_parameters_dummy() {}\n")
print("\n".join(params+output))
