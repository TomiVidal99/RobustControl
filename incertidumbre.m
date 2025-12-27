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
K = 1.1e-3; 
W_model = K*(Tzero*s+1)^2;
[mg,ph,w] = bode(W_model, w_nom);
loglog(w/(2*pi), mg, 'k--;Modelo de incertidumbre;', "Linewidth", 3);
