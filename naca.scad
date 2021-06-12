/* module defines coordinates of a 4-digit NACA profile. 
        arg1 : 'MPXX',
        arg2 : mounting point,
        arg3 : chord length,
        arg4 : number of points
*/

module naca(arg1, arg2, arg3, arg4) {
    // read arguments
    list = [for (s = arg1) ord(s)];
    chr_offset = 48;
    M = (list[0] - chr_offset) / 100;
    P = (list[1] - chr_offset) / 10;
    n1 = (list[2] - chr_offset) * 10;
    n2 = (list[3] - chr_offset);
    T = (n1 + n2) / 100;
    MP = arg2;
    C = arg3;
    N = arg4;
    
    // wing profile equation coefficients
    a0 = 0.29690;
    a1 = -0.1260;
    a2 = -0.3516;
    a3 = 0.28430;
    a4 = -0.1036;
   
    // upper points
    function get_upper_points(i) =
        let (b = i * (180 / N))
        let (x = (1 - cos(b)) / 2)
        let (c1 = (M != 0))
        let (c2 = (P != 0))
        let (c3 = (x < P))
        let (b1 = (2 * P))
        let (b2 = (2 * P * x))
        let (b3 = (P - x))
        let (b4 = (2 * M))
        let (b5 = pow(P, 2))
        let (b6 = pow(1 - P, 2))
        let (b7 = pow(x, 2))
        let (yc1 = (c1 && c2) ? (M / b5) * (b2 - b7) : 0)
        let (yc2 = (c1 && c2) ? (M / b6) * (1 - b1 + b2 - b7) : 0)
        let (dycdx1 = (c1 && c2) ? (b4 / b5) * b3 : 0)
        let (dycdx2 = (c1 && c2) ? (b4 / b6) * b3 : 0)
        let (k0 = a0 * pow(x, 0.5))
        let (k1 = a1 * x)
        let (k2 = a2 * pow(x, 2))
        let (k3 = a3 * pow(x, 3))
        let (k4 = a4 * pow(x, 4))
        let (yt = (T / 0.2) * (k0 + k1 + k2 + k3 + k4))
        let (yc = c3 ? yc1 : yc2)
        let (dycdx = c3 ? dycdx1 : dycdx2)
        let (th = atan(dycdx))
        let (xu = x - yt * sin(th))
        let (yu = yc + yt * cos(th))
        [(C * xu) - (C * MP), C * yu];
        
    // lower points
    function get_lower_points(i) =
        let (b = i * (180 / N))
        let (x = (1 - cos(b)) / 2)
        let (c1 = (M != 0))
        let (c2 = (P != 0))
        let (c3 = (x < P))
        let (b1 = (2 * P))
        let (b2 = (2 * P * x))
        let (b3 = (P - x))
        let (b4 = (2 * M))
        let (b5 = pow(P, 2))
        let (b6 = pow(1 - P, 2))
        let (b7 = pow(x, 2))
        let (yc1 = (c1 && c2) ? (M / b5) * (b2 - b7) : 0)
        let (yc2 = (c1 && c2) ? (M / b6) * (1 - b1 + b2 - b7) : 0)
        let (dycdx1 = (c1 && c2) ? (b4 / b5) * b3 : 0)
        let (dycdx2 = (c1 && c2) ? (b4 / b6) * b3 : 0)
        let (k0 = a0 * pow(x, 0.5))
        let (k1 = a1 * x)
        let (k2 = a2 * pow(x, 2))
        let (k3 = a3 * pow(x, 3))
        let (k4 = a4 * pow(x, 4))
        let (yt = (T / 0.2) * (k0 + k1 + k2 + k3 + k4))
        let (yc = c3 ? yc1 : yc2)
        let (dycdx = c3 ? dycdx1 : dycdx2)
        let (th = atan(dycdx))
        let (xl = x + yt * sin(th))
        let (yl = yc - yt * cos(th))
        [(C * xl) - (C * MP), C * yl];
    
    
    // create the upper points
    points_upper = [for (i=[0:N]) get_upper_points(i)];
        
    // create the lower points
    points_lower = [for (i=[N-1:-1:1]) get_lower_points(i)];
        
    // join upper and lower points
    points = concat(points_upper, points_lower);
    
    // create polygon
    polygon(points);
}


naca("5411", 0.5, 10.00, 300);



