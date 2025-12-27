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

        TransferFunc=Plant*Ks;

        [mg,ph,w] = bode(TransferFunc, w_nom);
        [p,z] = pzmap(TransferFunc);
        [Y, T, X] = step(TransferFunc);

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
        simulated_plants{plant_index}.Y = Y;
        simulated_plants{plant_index}.T = T;

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
end

legend("show");
xlabel("Frecuencia [Hz]");
ylabel("Magnitud [dB]");
title("Familia de plantas para el controlador");

fig = figure();
hold on;
grid on;

for i = 1:(plant_index-1)
  leg = sprintf(";(Rl=%d, Rpi=%d, Cpi=%d, Cmu=%d);", simulated_plants{i}.Rl, simulated_plants{i}.Rpi, simulated_plants{i}.Cpi/1e-12, simulated_plants{i}.Cmu/1e-12);
  plot(simulated_plants{i}.T, simulated_plants{i}.Y, leg, "Linewidth", 3);
end

legend("Location", "northwest");
xlabel("Tiempo [Segundos]");
ylabel("Amplitud");
title("Familia de plantas para el controlador");
