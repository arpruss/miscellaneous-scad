import sys
import re
import xml.etree.ElementTree as ET

svg = ET.parse(sys.argv[1])
if len(sys.argv)>=3:
    extra = float(sys.argv[2])
else:
    extra = 1
root = svg.getroot()
assert(root.tag == "svg" or root.tag.endswith("}svg"))
if root.tag == "svg":
    namespace = ""
else:
    namespace = root.tag[:-4]
namespaceLength = len(namespace)
print("input:",root.attrib)
for a in ("width","height"):
    value = root.attrib[a]
    offset = re.search(r'[ a-zA-Z]',value).start()
    newValue = float(value[:offset])+2*extra
    root.attrib[a] = "%g%s"%(newValue,value[offset:])
viewBox = list(map(float,root.attrib["viewBox"].split()))
viewBox[0] -= extra
viewBox[1] -= extra
viewBox[2] += 2*extra
viewBox[3] += 2*extra
root.attrib["viewBox"] = "%g %g %g %g" % tuple(viewBox)
print("output:",root.attrib)
svg.write(sys.argv[1])