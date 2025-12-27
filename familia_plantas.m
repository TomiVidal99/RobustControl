% Planta nominal
f0=10;
w0=2*pi*f0;
Kp=1e3*w0*w0;
chi=0.01;
% Tzpn=1/1e3;
Pn=Kp/(s*s+2*w0*chi*s+w0*w0)
[mg_nom, ph_nom, w_nom] = bode(Pn, freqs);

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
Pn_max=Kp/(s*s-2*chi*s+w0*w0);
[mg,ph,w] = bode(Pn_max, freqs);
loglog(w/(2*pi), mg, 'k--;Planta máxima;', "Linewidth", 3);

% Planta nominal menos mínimo
f0=1e-2;
w0=2*pi*f0;
Kp=1e3*w0*w0;
chi=1e-5;
Pn_min=Kp/(s*s-2*chi*s+w0*w0);
[mg,ph,w] = bode(Pn_min, freqs);
loglog(w/(2*pi), mg, 'g--;Planta mínima;', "Linewidth", 3);

