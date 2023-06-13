function [xk, yk, zk] = Position(SV, t, PRN, OMEGA_e_dot, A)
    GM = 3.986005D14;                                                       % WGS 84 value of the earth's gravitational constant
    n0 = sqrt(GM / (A^3));                                                  % Mean motion
    toe = SV(PRN).navData.TOE;                                              % Time from ephemeris reference epoch
    tk = t - toe;
    
    Delta_n = SV(PRN).navData.DeltaN;                                       % Corrected mean motion
    n = n0 + Delta_n;
    
    M0 = SV(PRN).navData.M0;                                                % Mean anomaly
    Mk = M0 + n * tk;
    
    delta = 1000; E_t0 = Mk;                                                % Eccentric anomaly
    e = SV(PRN).navData.e;
    while delta > 1D-10
        E_t = E_t0 + (Mk - E_t0 + e*sin(E_t0))./(1 - e*cos(E_t0));
        delta = abs(E_t - E_t0);
        E_t0 = E_t;
    end
    Ek = E_t;
    
    vk = 2*atan(sqrt((1 + e)/(1 - e))*tan(Ek/2));                           % True Anomaly (unambiguous quadrant)
    
    w = SV(PRN).navData.omega;                                              % Argument of Latitude
    Phik = vk + w;
    
    Cus = SV(PRN).navData.Cus;
    Cuc = SV(PRN).navData.Cuc;
    Crs = SV(PRN).navData.Crs;
    Crc = SV(PRN).navData.Crc;
    Cis = SV(PRN).navData.Cis;
    Cic = SV(PRN).navData.Cic;
    delta_uk = Cus*sin(2*Phik) + Cuc*cos(2*Phik);
    delta_rk = Crs*sin(2*Phik) + Crc*cos(2*Phik);
    delta_ik = Cis*sin(2*Phik) + Cic*cos(2*Phik);
    
    uk = Phik + delta_uk;                                                   % Corrected Argument of Latitude
    
    rk = A*(1 - e*cos(Ek)) + delta_rk;                                      % Corrected Radius
    
    i0 = SV(PRN).navData.i0;
    IDOT = SV(PRN).navData.IDOT;
    ik = i0 + delta_ik + (IDOT) * tk;                                       % Corrected Inclination
     
    xk_p = rk * cos(uk);
    yk_p = rk * sin(uk);                                                    % Positions in orbital
    
    Omega0 = SV(PRN).navData.OMEGA0;
    Omega_dot = SV(PRN).navData.OMEGA_DOT;
    Omega_k = Omega0 + (Omega_dot - OMEGA_e_dot) * tk - OMEGA_e_dot * toe;  % Corrected longitude of ascending node
    
    xk = xk_p * cos(Omega_k) - yk_p * cos(ik) * sin(Omega_k);
    yk = xk_p * sin(Omega_k) + yk_p * cos(ik) * cos(Omega_k);
    zk = yk_p * sin(ik);
    
end