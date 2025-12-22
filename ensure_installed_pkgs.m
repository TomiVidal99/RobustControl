function ensure_installed_pkgs(required_packages)
  % Usage:
  % 
  % required_packages = {"signal", "control"};
  
  installed_pkgs = pkg("list");
  if (length(installed_pkgs) == 0)
    pkgs = "";
    for i = 1:length(required_packages)
      pkgs = strcat(pkgs, "\t - ", required_packages{i}, "\n");
    end
    printf("No están los paquetes requeridos: \n%s \n\n", pkgs);
    printf("Se deben instalar con el comando: \n");
    printf(" pkg install -forge 'paquete' \n");
    return
  end

  for i=1:length(required_packages)
    found_flag = 0;
    for j=1:length(installed_pkgs)
      if (strcmp(installed_pkgs{j}.name, required_packages{i}))
        found_flag = 1;
        continue;
      end
    end

    if (found_flag == 0)
      printf("ERROR: el paquete '%s' no se encuentra instalado. \n", required_packages{i});
      printf("Debe instalarlo con: \n");
      printf("pkg install -forge %s\n\n", required_packages{i})
    end
  end

end
