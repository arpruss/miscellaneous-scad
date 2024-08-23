import re;
import sys;

START = 0
PARAMS = 1
CODE = 2

state = START
params = []

source = []

moduleName = sys.argv[2]

with open(sys.argv[1]) as f:
    for line in f:
        if state == CODE:
            print("  ", end='')
        print(line,end='')
        if state == START:
            if line.startswith("//<params>"):
                state = PARAMS
        elif line.startswith("//</params>"):
            inParams = False
            state = CODE
            print("\nmodule %s(" % moduleName)
            for arg in params:
                print(" %s=%s," % (arg,arg))
            print(" )\n{")
        elif state == PARAMS:
            m = re.match(r'([A-Za-z_][A-Za-z0-9_]*)\s*\=',line)
            if m:
                params.append(m.group(1))
if state == CODE:
    print("}\n\n//<skip>\n%s();\n//</skip>\n" % moduleName)
    
