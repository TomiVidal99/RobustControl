% Controlador
Tpk=-12;
Tpk2=-800;
Pn_poles=pole(Pn);
s1=Pn_poles(1);
s2=Pn_poles(2);
Ks = (1.5)*zpk([s1 s2], [-1e-10 -1e-4 -1e4 -10], 1)
%Pn=Kp/(s*s-2*chi*s+w0*w0);

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
figure(); hold on; grid on; title("Respuesta al escalón del sistema controlado");
step(T_s);
