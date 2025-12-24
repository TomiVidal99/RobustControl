disp("Control de sistemas con PID");

required_packages = {"control", "signal", "symbolic"};

ensure_installed_pkgs(required_packages);

% for i=1:numel(required_packages)
%   try
%     pkg load (required_packages{i})
%   catch
%     error("El paquete "%s" no se pudo cargar.", required_packages{i});
%   end_try_catch
% end

pkg load control;
pkg load signal;

s = tf("s");

freqs = {1e-5, 1e9};

% Modelo con todos los parámetros
Rpi=[1e3, 300e3];
Cpi=[80e-12, 150e-12];
Cmu=Cpi;
Rl=[1e3, 10e3]; % TODO: cambiar la carga varía mucho la estabilidad
hFE=1000;
Rs=1;

simulated_plants={};

% Planta nominal
f0=10;
w0=2*pi*f0;
Kp=1e3*w0*w0;
chi=0.2;
Tzpn=1/1e8;
Pn=Kp*(Tzpn*s+1)/(s*s-2*chi*s+w0*w0)
[mg_nom, ph_nom, w_nom] = bode(Pn, freqs);

% figure();
% hold on;
% grid on;

plant_index = 1;
for Rpi_i = Rpi
  for Cpi_i = Cpi
    for Cmu_i = Cmu
      for Rl_i = Rl
        TauPi=Cpi_i*Rpi_i;
        TauMu=Cmu_i*Rpi_i;

        A=TauPi*(Rs+Rl_i);
        B=TauPi+TauMu+Cmu_i*(Rs+Rl_i)*(1+hFE);
        C=1;

        Kp=hFE+1;
        Tz=TauPi;

        Plant=Kp*(Tz*s+1)/(A*s*s+B*s+C);

        [mg,ph,w] = bode(Plant, w_nom);
        [p,z] = pzmap(Plant);

        % nyquist(Plant);

        simulated_plants{plant_index}.mg = mg;
        simulated_plants{plant_index}.ph = ph;
        simulated_plants{plant_index}.w = w;
        simulated_plants{plant_index}.z = z;
        simulated_plants{plant_index}.p = p;
        simulated_plants{plant_index}.Rl = Rl_i;
        simulated_plants{plant_index}.Rpi = Rpi_i;
        simulated_plants{plant_index}.Cmu = Cmu_i;
        simulated_plants{plant_index}.Cpi = Cpi_i;
        simulated_plants{plant_index}.uncert_mg = abs((mg./mg_nom)-1);
        simulated_plants{plant_index}.uncert_ph = abs((ph./ph_nom)-1); % TODO: esto como es fase no cambia????

        plant_index = plant_index + 1;
        
      end
    end
  end
end

fig = figure();
hold on;
grid on;

for i = 1:(plant_index-1)
  leg = sprintf(";(Rl=%d, Rpi=%d, Cpi=%d, Cmu=%d);", simulated_plants{i}.Rl, simulated_plants{i}.Rpi, simulated_plants{i}.Cpi/1e-12, simulated_plants{i}.Cmu/1e-12);
  loglog(simulated_plants{i}.w/(2*pi), simulated_plants{i}.mg, leg, "Linewidth", 3);
  printf("- - - - - \n Rl=%d. Polos: \n\n", simulated_plants{i}.Rl);
  disp(simulated_plants{i}.p);
  printf("Ceros: \n\n");
  disp(simulated_plants{i}.z);
  printf("\n\n\n");
end

legend("show");
xlabel("Frecuencia [Hz]");
ylabel("Magnitud [dB]");
title("Familia de plantas");

% Planta nominal basada en los gráficos anteriores
loglog(w_nom/(2*pi), mg_nom, '--;Planta Nominal;', "Linewidth", 4);

% Planta nominal más máximo
f0=1e3;
w0=2*pi*f0;
Kp=1e3*w0*w0;
chi=0.2;
Pn=Kp/(s*s-2*chi*s+w0*w0);
[mg,ph,w] = bode(Pn, freqs);
loglog(w/(2*pi), mg, 'k--;Planta máxima;', "Linewidth", 3);

% Planta nominal menos mínimo
f0=1e-2;
w0=2*pi*f0;
Kp=1e3*w0*w0;
chi=1e-5;
Pn=Kp/(s*s-2*chi*s+w0*w0);
[mg,ph,w] = bode(Pn, freqs);
loglog(w/(2*pi), mg, 'g--;Planta mínima;', "Linewidth", 3);

% Modelo de incertidumbre para todas las plantas
figure();
grid on;
hold on;

max_mag_plants=0;
for i = 1:(plant_index-1)
  leg = sprintf(";(Rl=%d, Rpi=%d, Cpi=%d, Cmu=%d);", simulated_plants{i}.Rl, simulated_plants{i}.Rpi, simulated_plants{i}.Cpi/1e-12, simulated_plants{i}.Cmu/1e-12);
  loglog(simulated_plants{i}.w/(2*pi), simulated_plants{i}.uncert_mg, leg, "Linewidth", 2);
  m = max(simulated_plants{i}.uncert_mg);
  if (m > max_mag_plants)
    max_mag_plants = m;
  end
end


legend("location", "northwest");
xlabel("Frecuencia [Hz]");
ylabel("Magnitud [dB]");
title("Incertidumbre de la familia");
ylim auto;
ylim_bef = ylim;
ylim_lower = ylim_bef(1);
ylim([ylim_lower, max_mag_plants]);

% Modelo de incertidumbre
Tzero=1/1e-2;
K = 1.5e-3; 
W_model = K*(Tzero*s+1)^3;
[mg,ph,w] = bode(W_model, w_nom);
loglog(w/(2*pi), mg, 'k--;Modelo de incertidumbre;', "Linewidth", 3);

% Controlador
Tpk=-12;
Tpk2=-800;
Pn_poles=pole(Pn);
s1=Pn_poles(1);
s2=Pn_poles(2);
%Ks = ((s-Pn_poles(1))*(s-Pn_poles(2)))/(s*(Tpk*s+1)*(Tpk2*s+1));
Ks = zpk([s1 s2], [-1e-5 -1 -10 -100], 1)
%Pn=Kp/(s*s-2*chi*s+w0*w0);

% Verifico estabilidad robusta
figure(); hold on; grid on; title("Verificación estabilidad robusta");
% T_s = Pn*Ks/(1+Pn*Ks);
T_s = feedback(Pn*Ks, 1);

% [p,z] = pzmap(T_s)
% if (any(real(p)) > 0)
%   dispc("ERROR: la transferencia T(s) es inestable!!!\n", "red");
%   input("Enter para finalizar... \n\n");
%   exit;
% end

[mg,ph,w] = bode(T_s*W_model, w_nom);
loglog(w/(2*pi), mg, "Linewidth", 3);
semilogx(w/(2*pi), ones(length(w)), '--k', "Linewidth", 3);

if (max(mg) >= 1)
  dispc('ERROR: el controlador NO es robusto!!! \n', 'red');
end


% Gráfico del sistema controlado
figure(); hold on; grid on; title("Respuesta al escalón del sistema controlado");
step(T_s);

% Handle exit
ans = input("Presiona ENTER para finalizar... \n\n");
close all;
exit;
