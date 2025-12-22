disp("Control de sistemas con PID");

required_packages = {"control", "signal", "symbolic"};

ensure_installed_pkgs(required_packages);

% for i=1:numel(required_packages)
%   try
%     pkg load (required_packages{i})
%   catch
%     error("El paquete '%s' no se pudo cargar.", required_packages{i});
%   end_try_catch
% end

pkg load control;
pkg load signal;

% Planta nominal
s = tf('s');
% Kp=1000;
% Tz=1;
% Tp1=10;
% Tp2=20;
% Pn=Kp*(Tz*s+1)/((Tp1*s+1)*(Tp2*s+1));

% Modelo con todos los parámetros
Rpi=[1250, 250e3];
% Cpi = 50e-12; 
Cpi=[20e-12, 120e-12];
% Cmu = Cpi;
Cmu=Cpi;
% Rl = 1;
Rl=[1, 100e3];
hFE=1000;
Rs=1;

simulated_plants={};

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

        [mg,ph,w] = bode(Plant, {1, 1e5});
        [z,p] = pzmap(Plant);

        simulated_plants{plant_index}.mg = mg;
        simulated_plants{plant_index}.ph = ph;
        simulated_plants{plant_index}.w = w;
        simulated_plants{plant_index}.z = z;
        simulated_plants{plant_index}.p = p;
        simulated_plants{plant_index}.Rl = Rl_i;
        simulated_plants{plant_index}.Rpi = Rpi_i;

        plant_index = plant_index + 1;
        
      end
    end
  end
end

fig = figure();
hold on;
grid on;

for i = 1:(plant_index-1)
  leg = sprintf(";(Rl=%d, Rpi=%d);", simulated_plants{i}.Rl, simulated_plants{i}.Rpi);
  semilogx(simulated_plants{i}.w, simulated_plants{i}.mg, leg, 'Linewidth', 3);
end

legend('show');
xlabel('Frecuencia [rad/s]');
ylabel('Magnitud');

% Handle exit
ans = input("Presiona ENTER para finalizar... \n\n");
close all;
exit;
