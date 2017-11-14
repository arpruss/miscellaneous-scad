import sys
import re

XPARK = -12

with open(sys.argv[1]) as f:
    lines = f.readlines()
    
commands = []

args = sys.argv[2:]

while args:
    if args[0][0] == 'z':
        command = [ 'z', float(args[0][1:]) ]
    elif "mm" in args[0]:
        command = [ 'z', float(args[0]) ]
    elif args[0][0] == 'l':
        command = [ 'l', int(args[0][1:]) ]
    else:
        command = [ 'l', int(args[0]) ]
    args = args[1:]
    while args:
        if args[0][0] == 't':
            command.append('M104 S%d' % int(args[0][1:]))
        elif args[0][0] == 'p':
            command.append(';'+args[0][1:])
        else:
            break
        args = args[1:]
    if len(command) > 2:
        commands.append(command)

ready = False
insertIndex = 0
layer = 0
x = None
y = None
z = None

for line in lines:
    insert = False
    line = line.strip()
    if line[0] == ';':
        print(line)
        continue
    items = re.split(r'\s+', line.lower())
    if items:
        if items[0] == 'g90':
            ready = True
            sys.stderr.write("Ready\n")
        elif ready and (items[0] == 'g0' or items[0] == 'g1'):
            newZ = None
            for coord in items[1:]:
                if coord[0] == 'z':
                    newZ = float(coord[1:])
                elif coord[0] == 'y':
                    y = float(coord[1:])
                elif coord[0] == 'x':
                    x = float(coord[1:])
            if newZ is not None:
                layer += 1
                z = newZ
                if insertIndex < len(commands) and ( ( (commands[insertIndex][0] == 'l' and layer == commands[insertIndex][1]) or
                     (commands[insertIndex][0] == 'z' and z >= commands[insertIndex][1]) ) ):
                    insert = True
    print(line.strip())
    if insert:
        sys.stderr.write(str(commands[insertIndex])+"\n")
        for c in commands[insertIndex][2:]:
            if c[0] == ';':
                print('G1 X%.4f' % XPARK)
                print('M117 '+c[1:])
                print('M25')
                print('G1 Z%.4f' % z)
                print('G1 Y%.4f' % y)
                print('G1 X%.4f' % x)
            else:
                print(c)
        insertIndex += 1

if len(commands) > insertIndex:
    sys.stderr.write("Could not handle commands %d and on.\n" % insertIndex)
    