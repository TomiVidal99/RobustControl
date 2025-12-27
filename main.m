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
Rpi=[1e3, 100e3];
Cpi=[80e-12, 120e-12];
Cmu=Cpi;
Rl=[1, 10e3]; % TODO: cambiar la carga varía mucho la estabilidad
hFE=1000;
Rs=1;

simulated_plants={};

familia_plantas();

incertidumbre();

controlador();

controladores_para_familias();

% Handle exit
ans = input("Presiona ENTER para finalizar... \n\n");
close all;
exit;
