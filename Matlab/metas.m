function T = metas(alpha,L,d,th)

T = [       cos(th)           -sin(th)           0              L 
     sin(th)*cos(alpha)  cos(th)*cos(alpha)  -sin(alpha)   -sin(alpha)*d
     sin(th)*sin(alpha)  cos(th)*sin(alpha)   cos(alpha)    cos(alpha)*d
             0                  0                 0             1];

