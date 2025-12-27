% Controlador
Tpk=-12;
Tpk2=-800;
Pn_poles=pole(Pn);
z1=Pn_poles(1);
z2=Pn_poles(2);
Ks = zpk([z1 z2], [0, -0.001, -4500, -4500, -4500], 2e1)
pole(Ks)

% f0=10;
% w0=2*pi*f0;
% Kp=1e3*w0*w0;
% chi=0.2;
% Tzpn=1/1e8;
% Pn=Kp*(Tzpn*s+1)/(s*s-2*chi*s+w0*w0)

% Verifico estabilidad robusta
figure(); hold on; grid on; title("Verificación estabilidad robusta");
% T_s = Pn*Ks/(1+Pn*Ks);
T_s = feedback(Pn*Ks, 1);

[mg,ph,w] = bode(T_s*W_model, w_nom);
loglog(w/(2*pi), mg, "Linewidth", 3);
semilogx(w/(2*pi), ones(length(w)), '--k', "Linewidth", 3);

if (max(mg) >= 1)
  dispc('ERROR: el controlador NO es robusto!!! \n', 'red');
end


% Gráfico del sistema controlado
% figure(); hold on; grid on; title("Respuesta al escalón del sistema controlado");
% step(T_s);

figure(); grid on;
rlocus(T_s);
