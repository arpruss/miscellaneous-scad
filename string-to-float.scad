// Jesse Campbell
// www.jbcse.com
// http://www.thingiverse.com/thing:2247435
// OpenSCAD ascii string to number conversion function atof
// atoi and substr are from http://www.thingiverse.com/roipoussiere
// licensed under the Creative Commons - Attribution license.

// modified to support scientific notation by Alexander Pruss

function atoi(str, base=10, i=0, nb=0) =
	i == len(str) ? (str[0] == "-" ? -nb : nb) :
	i == 0 && str[0] == "-" ? atoi(str, base, 1) :
	atoi(str, base, i + 1,
		nb + search(str[i], "0123456789ABCDEF")[0] * pow(base, len(str) - i - 1));

function substr(str, pos=0, len=-1, substr="") =
	len == 0 ? substr :
	len == -1 ? substr(str, pos, len(str)-pos, substr) :
	substr(str, pos+1, len-1, str(substr, str[pos]));
    
function atof(str) = 
    len(str) == 0 ? 0 : 
        let(
            expon1 = search("e", str),
            expon = len(expon1) ? expon1 : search("E", str))
           len(expon) ? atof(substr(str,pos=0,len=expon[0])) * pow(10, atoi(substr(str,pos=expon[0]+1))) :
        let(
            multiplyBy = (str[0] == "-") ? -1 : 1,
            str = (str[0] == "-" || str[0] == "+") ? substr(str, 1, len(str)-1) : str,    
            decimal = search(".", str),    
            beforeDecimal = decimal == [] ? str : substr(str, 0, decimal[0]),
            afterDecimal = decimal == [] ? "0" : substr(str, decimal[0]+1)
        )
        (multiplyBy * (atoi(beforeDecimal) + atoi(afterDecimal)/pow(10,len(afterDecimal))));
        
echo(atof("+12.123e-1"));
echo(atof("1.23"));
echo(atof("-4.56"));
echo(atof("-0.56"));
echo(atof("-.1"));
echo(atof("99"));
