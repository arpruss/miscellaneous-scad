from six import string_types
from numbers import Number

argumentDictionary = {}

SPACING = 25
yPosition = 0
ind = ""

def addhead(out):
    out.append('<?xml version="1.0" ?>')
    out.append('<xml xmlns="https://blockscad3d.com">')
    out.append('<version num="1.10.2"/>')
    
def addtail(out):
    out.append('</xml>')

def addvalue(out, name, value):
    out.append('<value name="%s">' % name)
    out += value
    out.append('</value>')
    
def addstatement(out, name, value):
    out.append('<statement name="%s">' % name)
    out += value
    out.append('</statement>')
    
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
    out.append('</block><!--logic_compare-->')
    return out

def arithmetic(a, op, b):    
    out = []
    out.append('<block type="math_arithmetic">')
    addfield(out, "OP", op)
    addvalue(out, "A", a)
    addvalue(out, "B", b)
    out.append('</block><!--math_arithmetic-->')
    return out

def modulo(a, b):    
    out = []
    out.append('<block type="math_modulo">')
    addvalue(out, "DIVIDEND", a)
    addvalue(out, "DIVISOR", b)
    out.append('</block><!--math_modulo-->')
    return out
    
def setop(op, extra, base, list):
    out = []
    out.append('<block type="%s">'%op)
    if len(list)>1:
        out.append('<mutation %s="%d"/>'%(extra,len(list)-1))
    addstatement(out, "A", base)
    for i,item in enumerate(list):
        addstatement(out, "%s%d" % (extra.upper(), i), item)
    out.append('</block>')
    return out

class EX(list):
    def __init__(self, x):
        if isinstance(x, Number):
            super(EX, self).__init__(number(x))
        elif isinstance(x, string_types):
            super(EX, self).__init__(variable(x))
        else:
            super(EX, self).__init__(x)
    
    def __eq__(self, x):
        return EX(compare(self, "EQ", EX(x)))        
        
    def __lt__(self, x):
        return EX(compare(self, "LT", EX(x)))        
        
    def __le__(self, x):
        return EX(compare(self, "LE", EX(x)))        
        
    def __gt__(self, x):
        return EX(compare(self, "GT", EX(x)))        
        
    def __ge__(self, x):
        return EX(compare(self, "GE", EX(x)))
        
    def __ne__(self, x):
        return EX(compare(self, "NE", EX(x)))
        
    def __add__(self, x):
        return EX(arithmetic(self, "ADD", EX(x)))
        
    def __sub__(self, x):
        return EX(arithmetic(self, "MINUS", EX(x)))
        
    def __mul__(self, x):
        return EX(arithmetic(self, "MULTIPLY", EX(x)))
        
    def __div__(self, x):
        return EX(arithmetic(self, "DIVIDE", EX(x)))
        
    def __pow__(self, x):
        return EX(arithmetic(self, "POWER", EX(x)))
        
    def __mod__(self, x):
        return EX(modulo(self, EX(x)))
        
    def ifthen(self, yes, no):
        out = []
        out.append('<block type="logic_ternary">')
        addvalue(out, "IF", self)
        addvalue(out, "THEN", EX(yes))
        addvalue(out, "ELSE", EX(no))
        out.append('</block>')
        return EX(out)
        
    def statementif(self, yes):
        out = []
        out.append('<block type="controls_if">')
        addvalue(out, "IF0", self)
        addvalue(out, "DO0", EX(yes))
        out.append('</block>')
        return EX(out)
        
    def union(self, *args):
        return EX(setop("union", "plus", self, args))
        
    def difference(self, *args):
        return EX(setop("difference", "minus", self, args))
        
    def translate3(self, x, y, z):
        out = []
        out.append('<block type="translate">')
        addvalue(out, "XVAL", x)
        addvalue(out, "YVAL", y)
        addvalue(out, "ZVAL", z)
        addstatement(out, "A", self)
        out.append('</block>')
        return EX(out)
        
    def translate2(self, x, y):
        out = []
        out.append('<block type="translate">')
        addvalue(out, "XVAL", x)
        addvalue(out, "YVAL", y)
        addstatement(out, "A", self)
        out.append('</block>')
        return EX(out)
        
    def __repr__(self):
        return "\n".join(self)

def function(name, args, value):
    global yPosition
    argumentDictionary[name] = args
    if value is None:
        return None
    out = []
    out.append('<block type="procedures_defreturn" x="0" y="%d" collapsed="true">' % yPosition)
    yPosition += SPACING
    if args:
        out.append('<mutation statements="false">')
        for arg in args:
            out.append('<arg name="%s"/>' % arg)
        out.append('</mutation>')
    addfield(out, "NAME", name)
    addvalue(out, "RETURN", EX(value))
    out.append('</block>')
    return out
    
def module(name, args, value):
    global yPosition
    argumentDictionary[name] = args
    if value is None:
        return None
    out = []
    out.append('<block type="procedures_defnoreturn" x="0" y="%d" collapsed="true">' % yPosition)
    yPosition += SPACING
    if args:
        out.append('<mutation>')
        for arg in args:
            out.append('<arg name="%s"/>' % arg)
        out.append('</mutation>')
    addfield(out, "NAME", name)
    addstatement(out, "STACK", EX(value))
    out.append('</block>')
    return out
    
def invoke(name, type, args):
    out = []
    out.append('<block type="procedures_%s">' % type)
    out.append('<mutation name="%s">' % name)
    assert(len(argumentDictionary[name]) == len(args));
    for arg in argumentDictionary[name]:
        out.append('<arg name="%s"/>' % arg)
    out.append('</mutation>')
    for i,arg in enumerate(args):
        addvalue(out, "ARG%d"%i, arg)
    out.append('</block>')
    return EX(out)
    
def invokeModule(name, args):
    return invoke(name, "callnoreturn", args)
    
def invokeFunction(name, args):
    return invoke(name, "callreturn", args)

def square(x, y, center=False):
    out = []
    out.append('<block type="square">')
    addfield(out, "CENTERDROPDOWN", "true" if center else "false")
    addvalue(out, "XVAL", EX(x))
    addvalue(out, "YVAL", EX(y))
    out.append('</block>')
    return EX(out)
    
def ifthen(condition, yes, no):
    out = []
    out.append('<block type="logic_ifthen">')
    addvalue(out, "IF", condition)
    addvalue(out, "THEN", yes)
    addvalue(out, "ELSE", no)
    out.append('</block>')
    return EX(out)
    
