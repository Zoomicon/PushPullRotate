clear
clc

q1 = sym('q1','real');
q2 = sym('q2','real');
d3 = sym('d3','real');
q4 = sym('q4','real');
q5 = sym('q5','real');
d6 = sym('d6','real');
q7 = sym('q7','real');
q8 = sym('q8','real');
d9 = sym('d9','real');
q10 = sym('q10','real');
q11 = sym('q11','real');
d12 = sym('d12','real');
q13 = sym('q13','real');
q14 = sym('q14','real');
d15 = sym('d15','real');


DH=[0 0 0 q1;
    -pi/2 0 0 q2;
    pi/2 0 d3 0;
    0 0 0 q4;
    -pi/2 0 0 q5;
    pi/2 0 d6 0;
    0 0 0 q7;
    -pi/2 0 0 q8;
    pi/2 0 d9 0;
    0 0 0 q10;
    -pi/2 0 0 q11;
    pi/2 0 d12 0;
    0 0 0 q13;
    -pi/2 0 0 q14;
    pi/2 0 d15 0;];

%docNode=myppr(DH) 
docNode=myppr_generic(DH) 
    