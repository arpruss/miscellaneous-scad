import re
import sys

PARK = "G1 X-12 : G1 Y0"

def dumpSplit(s):
    for line in re.split(r'\s*:\s*', s):
        if line:
            print(line)

if len(sys.argv) < 2:
    print("""
python insert.py filename zN|Nmm|lN|N commands ... > outputname
  zN / Nmm : insert commands before the layer at (or above) height N (in mm)
  lN / N   : insert commands before layer number N (lowest layer = 1)
  commands :
             tN           : set extruder temperature to NameError
             "pMessage"   : park (%s), show Message, and sd pause (M25) 
             "gcode line" : manual gcode line
             r            : return to last XYZ position
 """ % PARK)
    sys.exit(0)

with open(sys.argv[1]) as f:
    lines = f.readlines()
    
commands = []
every = []

args = sys.argv[2:]

while args:
    isEvery = False
    if args[0] == 'e':
        command = []
        isEvery = True
    elif args[0][0] == 'z':
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
            command.append('~'+args[0][1:])
        elif args[0][0] == 'z' or args[0][0] == 'l' or args[0][0].isdigit() or args[0][0] == 'e':
            break
        else:
            command.append(args[0])
        args = args[1:]
    if isEvery:
        every += command
    elif len(command) > 2:
        commands.append(command)

ready = False
insertIndex = 0
layer = 0
x = None
y = None
z = None

def insertCommands(commandList):
    def returnToXYZ():
        print('G90')
        if z is not None:
            print('G1 Z%.4f' % z)
        if y is not None:
            print('G1 Y%.4f' % y)
        if x is not None:
            print('G1 X%.4f' % x)
        
    for c in commandList:
        if c[0] == '~':
            dumpSplit(PARK)
            print('M0 '+c[1:])
#            print('M24')
            returnToXYZ()
        elif c == 'r':
            returnToXYZ()
        else:
            dumpSplit(c)


for line in lines:
    insert = False
    line = line.strip()
    if line[0] == ';':
        print(line)
        continue
    items = line.lower().split()
    if items:
        if items[0] == 'g90':
            ready = True
            sys.stderr.write("Detected main\n")
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
                insertCommands(every)
                if insertIndex < len(commands) and ( ( (commands[insertIndex][0] == 'l' and layer == commands[insertIndex][1]) or
                     (commands[insertIndex][0] == 'z' and z >= commands[insertIndex][1]) ) ):
                    insert = True
    print(line)
    if insert:
        sys.stderr.write(str(commands[insertIndex])+"\n")
        insertCommands(commands[insertIndex][2:])
        insertIndex += 1

if len(commands) > insertIndex:
    sys.stderr.write("Could not handle commands %d and on.\n" % insertIndex)
    