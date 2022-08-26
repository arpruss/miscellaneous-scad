wallFlareWidth = 3;
wallFlareThickness = 1.5;
wallHeight = 12;
wallWidth = 1;

lineSegment = 15;
iterations = 1;

angle = 90;
axiom = "F+F+F+F";
rules = [["F", "F-F+F+FF-F-F+F"]];

module end_of_parameters_dummy() {}

//use <lsystem.scad>;

function isString(v) = v >= ""; // this seems to be the fastest way

// search without not-found warnings
function lookup(c, r)
    = let(r1 = concat(r, [[c,c]]))
        r1[search(c, r1)[0]][1];

function rest(list) = len(list)<=1 ? [] : [for(i=[1:len(list)-1]) list[i]];

function cat(strings, i=0, sofar="")
    = i>=len(strings) ? sofar : cat(strings, i=i+1, sofar=str(sofar,strings[i]));

function evolve1(rules, axiom)
    = cat([for (i=[0:len(axiom)-1]) lookup(axiom[i], rules)]);

function lsystem(rules, axiom, n=1)
    = n==0 ? axiom
             : lsystem(rules, evolve1(rules, axiom), n=n-1);

function pitchMatrix(angle)
    = [[cos(angle), 0, -sin(angle),0],
                [0,          1, 0,0],
                [sin(angle), 0, cos(angle),0],
                [0,0,0,1]];

function yawMatrix(angle)
    =  [[cos(angle), -sin(angle), 0,0],
                [sin(angle), cos(angle),0,0],
                [0,          0,          1,0],
                [0,0,0,1]];

function rollMatrix(angle)
    = [[1,          0,          0,0],
                [0, cos(angle),-sin(angle),0],
                [0, sin(angle),cos(angle),0],
                [0,0,0,1]
                ];

function forwardMatrix(distance)
    = [[1,0,0,distance], [0,1,0,0], [0,0,1,0], [0,0,0,1]];

function identityMatrix()
    = [[1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1]];


function evolveState1(f, state) =
    isString(f) ? state :
    f[0] == "m" ? [ state[0], state[1]*f[1] ] :
    f[0] == "push" ? concat([ concat([rest(state)], state[0]) ], rest(state)) :
    f[0] == "pop" ? concat([rest(state[0])], state[0][0]) :
    state;

function evolveState(string, functions, state, n=0, soFar=[]) =
    n >= len(string) ? concat(soFar, [rest(state)]) :
        evolveState(string, functions,
            evolveState1(lookup(string[n],functions), state),
            n=n+1, soFar=concat(soFar, [rest(state)]));

module traceStates(states) {
    for (i=[1:len(states)-1])
        hull() {
            multmatrix(states[i-1][0]) children();
            multmatrix(states[i][0]) children();
        }
}

module drawLSystem(rules,axiom,n,functions,baseState=[ [], identityMatrix() ]) {
    traceStates(evolveState(lsystem(rules,axiom,n), functions, baseState)) children();
}



module dummy();

forward = lineSegment;

baseState  = [ [], identityMatrix() ];
functions =
    [
      ["F", ["m", forwardMatrix(forward)]],
      ["-", ["m", yawMatrix(angle)]],
      ["+", ["m", yawMatrix(-angle)]],
      ["^", ["m", pitchMatrix(angle)]],
      ["&", ["m", pitchMatrix(-angle)]],
      [">", ["m", rollMatrix(angle)]],
      ["<", ["m", rollMatrix(-angle)]],
      ["[", ["push"]],
      ["]", ["pop"]]
      ];

out = lsystem(rules,axiom,iterations);
states = evolveState(out,functions, baseState);
linear_extrude(height=wallFlareThickness) traceStates(states) circle(d=wallFlareWidth,$fn=10);
linear_extrude(height=wallHeight) traceStates(states) circle(d=wallWidth,$fn=10);
