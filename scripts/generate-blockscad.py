from six import string_types
from numbers import Number

out = []
argumentDictionary = {}

SPACING = 10
yPosition = 0
ind = ""

def addvalue(out, name, value):
    out.append('<value name="%s">' % name)
    out += value
    out.append('</value>')
    
def addfield(out, name, value):
    out.append('<field name="%s">%s</field>' % (name, value))
    
def variable(name):
    return ['<block type="variables_get"><field name="VAR">%s</field></block>' % name]

def number(x):
    return ['<block type="math_number"><field name="NUM">%d</field></block>' % x]

def compare(a, op, b):    
    out = []
    out.append('<block type="logic_compare">')
    addfield(out, "OP", op)
    addvalue(out, "A", a)
    addvalue(out, "B", b)
    out.append('</block>')
    return out

def math(a, op, b):    
    out = []
    out.append('<block type="math_arithmetic">')
    addfield(out, "OP", op)
    addvalue(out, "A", a)
    addvalue(out, "B", b)
    out.append('</block>')
    return out

def modulo(a, b):    
    out = []
    out.append('<block type="math_modulo">')
    addvalue(out, "DIVIDEND", a)
    addvalue(out, "DIVISOR", b)
    out.append('</block>')
    return out

class EX(list):
    def __init__(self, x):
        self.out = []
        if isinstance(x, Number):
            self.out = number(x)
        elif isinstance(x, EX):
            self.out = x.out
        elif isinstance(x, string_types):
            self.out = variable(x)
        else:
            self.out = x
    
    def __eq__(self, x):
        return EX(compare(self.out, "EQ", EX(x).out))        
        
    def __lt__(self, x):
        return EX(compare(self.out, "LT", EX(x).out))        
        
    def __le__(self, x):
        return EX(compare(self.out, "LE", EX(x).out))        
        
    def __gt__(self, x):
        return EX(compare(self.out, "GT", EX(x).out))        
        
    def __ge__(self, x):
        return EX(compare(self.out, "GE", EX(x).out))
        
    def __ne__(self, x):
        return EX(compare(self.out, "NE", EX(x).out))
        
    def __add__(self, x):
        return EX(math(self.out, "ADD", EX(x).out))
        
    def __sub__(self, x):
        return EX(math(self.out, "SUBTRACT", EX(x).out))
        
    def __mul__(self, x):
        return EX(math(self.out, "MULTIPLY", EX(x).out))
        
    def __div__(self, x):
        return EX(math(self.out, "DIVIDE", EX(x).out))
        
    def __pow__(self, x):
        return EX(math(self.out, "POWER", EX(x).out))
        
    def __mod__(self, x):
        return EX(modulo(self.out, EX(x).out))
        
    def ifthen(self, yes, no):
        out = []
        out.append('<block type="logic_ternary">')
        addvalue(out, "IF", self.out)
        addvalue(out, "THEN", EX(yes).out)
        addvalue(out, "ELSE", EX(no).out)
        out.append('</block>')
        return EX(out)
        
    def __repr__(self):
        return "\n".join(self.out)

def invokeFunction(name, *args):
    out = []
    out.append('<block type="procedures_callreturn" x="0" y="%d" collapsed="true">' % yPosition)
    yPosition += SPACING
    out.append('<mutation name="%s">' % name)
    assert(len(argumentDictionary[name]) == len(args));
    for arg in argumentDictionary[name]:
        out.append('<arg name="%s"/>' % arg)
    out.append('</mutation>')
    for i,arg in enumerate(args):
        addvalue(out, "ARG%d"+i, arg)
    out.append('</block>')
    return EX(out)
    
def function(name, args, value):
    global yPosition
    out = []
    out.append('<block type="procedures_defreturn" x="0" y="%d" collapsed="true">' % yPosition)
    yPosition += SPACING
    out.append('<mutation statements="false">')
    argumentDictionary[name] = args
    for arg in args:
        out.append('<arg name="%s"/>' % arg)
    out.append('</mutation>')
    addfield(out, "NAME", name)
    addvalue(out, "RETURN", EX(value).out)
    out.append('</block>')
    return out
    
def ifthen(condition, yes, no):
    out = []
    out.append('<block type="logic_ifthen">')
    addvalue(out, "IF", condition)
    addvalue(out, "THEN", yes)
    addvalue(out, "ELSE", no)
    out.append('</block>')
    return out
    
out.append('<?xml version="1.0" ?>')
out.append('<xml xmlns="https://blockscad3d.com">')
out.append('<version num="1.10.2"/>')
    
out += function("divisible by 5", ["x%d"%i for i in range(1000)], (EX("x") % 5 == 0).ifthen(1, 0))

out.append('</xml>')

print('\n'.join(out))
