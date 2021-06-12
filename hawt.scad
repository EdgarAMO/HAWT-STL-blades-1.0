use <section.scad>
use <loft.scad>
$fa = 0.01;
$fs = 2;
$fn = 5;



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
NACA =      "4412";             // airfoil
R =         45.00;              // blade's length
NB =        3.000;              // number of blades
CL =        1.110;              // design lift coefficient
ALPHA =     5.850;              // design angle of attack
LAMBDA =    7.000;              // design lambda
NS =        15.00;              // number of sections
NP =        50;                 // number of points for airfoil
ROOT =      0.200;              // initial root position

PRINT =     false;               // print one blade option
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */



// rotate a point clockwise by t degrees:
function f(point, t) =
    let (x = point[0])
    let (y = point[1])
    let (xp = x * cos(t) + y * sin(t))
    let (yp = -x * sin(t) + y * cos(t))
    [xp, yp, point[2]];
   
// rotate a list of points: 
function return(points, t) = 
    let (npoints = [for (point = points) f(point, t)])
    npoints;
    
// relative wind angle:
function get_phi(lambda_i) = (2 / 3) * atan(1 / lambda_i);
    
// get local lambda:
function get_lambda_i(lambda, rstar) = lambda * rstar;
    
// get tip loss :
function get_F(rstar, phi) = 
    let (A = 2 / PI)
    let (B = (NB / 2) * (1 - rstar))
    let (C = rstar * sin(phi))
    let (D = exp(-B / C))
    let (E = acos(D) * PI / 180)
    A * E;
    
// get local chord:
function get_c(rstar, F, phi, lambda_i) = 
    let (X1 = 8 * PI * rstar * R * F * sin(phi))
    let (X2 = cos(phi) - lambda_i * sin(phi))
    let (X3 = NB * CL)
    let (X4 = sin(phi) + lambda_i * cos(phi))
    (X1 * X2) / (X3 * X4);
    
// get twist:
function get_twist(phi) = phi - ALPHA;
    
// construction loops:
params = [for (i = [0:NS-1]) let(rstar = ROOT + i * (1 - ROOT) / NS,
                                lambda_i = get_lambda_i(LAMBDA, rstar),
                                phi = get_phi(lambda_i),
                                tiploss = get_F(rstar, phi),
                                chord = get_c(rstar, tiploss, phi, lambda_i),
                                twist = get_twist(phi))
                                [rstar, lambda_i, phi, tiploss, chord, twist]];

levels = [for (p = params) naca(NACA, 0.25, NP, p[4], p[0] * R)];
 
END =   PRINT == true ? 0 : NB - 1 ;
rotate( 180, [0, 0, 1]) 
    for (j = [0:END]) {
        union () {
            rotate( j*360/NB, [0, 1, 0])
                for (i = [0:NS-2]) { loft(return(levels[i], params[i][5]), 
                                    return(levels[i+1], params[i+1][5]), 
                                    20); }     
        }
    }
                       
                            
