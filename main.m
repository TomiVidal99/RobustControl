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

freqs = {0.01, 1e7};

% Modelo con todos los parámetros
Rpi=[1250, 250e3];
Cpi=[20e-12, 120e-12];
Cmu=Cpi;
Rl=[1, 100e3];
hFE=1000;
Rs=1;

simulated_plants={};

% Planta nominal
f0=10;
w0=2*pi*f0;
Kp=1e3*w0*w0;
chi=0.2;
Pn=Kp/(s*s-2*chi*s+w0*w0);
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
        simulated_plants{plant_index}.uncert_mg = (mg./mg_nom)-1;
        simulated_plants{plant_index}.uncert_ph = (ph_nom./ph)-1; % TODO: esto como es fase no cambia????

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
f0=0.5e-1;
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

for i = 1:(plant_index-1)
  loglog(simulated_plants{i}.w/(2*pi), simulated_plants{i}.uncert_mg, "Linewidth", 2);
end


legend("show");
xlabel("Frecuencia [Hz]");
ylabel("Magnitud [dB]");
title("Incertidumbre de la familia");

% Modelo de incertidumbre
Tzero=1/0.5e-1;
Tpolo=1/1e3;
K = 1e2; 
W_model = K*(Tzero*s+1)/(Tpolo*s+1);
[mg,ph,w] = bode(W_model, w_nom);
loglog(w/(2*pi), mg, 'k--;Modelo de incertidumbre;', "Linewidth", 3);


% Handle exit
ans = input("Presiona ENTER para finalizar... \n\n");
close all;
exit;
