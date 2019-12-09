duracion_trama = [0.001 0.005 0.01 0.05 0.1 0.5 1 5];
p = 5:2:19;             
exponente_cuantizacion_errores = 5:7;
exponente_cuantizacion_coeficientes = 4:6;

%% Resultados
total_simulaciones = size(duracion_trama,2) * size(p,2) * size(exponente_cuantizacion_errores,2) * size(exponente_cuantizacion_coeficientes,2);
resultados_EMC = zeros(size(duracion_trama,2), size(p,2), size(exponente_cuantizacion_errores,2), size(exponente_cuantizacion_coeficientes,2));
resultados_r_comprension = zeros(size(duracion_trama,2), size(p,2), size(exponente_cuantizacion_errores,2), size(exponente_cuantizacion_coeficientes,2));

id = fopen('resultados', 'r');
contador_duracion_trama = fread(id, 1, 'ubit8');
contador_p = fread(id, 1, 'ubit8');
contador_exponente_cuantizacion_errores = fread(id, 1, 'ubit8');
contador_exponente_cuantizacion_coeficientes = fread(id, 1, 'ubit8');
for i_duracion_trama = 1:contador_duracion_trama - 1
    for i_p = 1:contador_p - 1 
        for i_exponente_cuantizacion_errores = 1:contador_exponente_cuantizacion_errores - 1
            for i_exponente_cuantizacion_coeficientes = 1:contador_exponente_cuantizacion_coeficientes - 1
                resultados_r_comprension(i_duracion_trama, i_p, i_exponente_cuantizacion_errores, i_exponente_cuantizacion_coeficientes) = fread(id, 1, 'float32');
            end
        end
    end
end
for i_duracion_trama = 1:contador_duracion_trama - 1
    for i_p = 1:contador_p - 1
        for i_exponente_cuantizacion_errores = 1:contador_exponente_cuantizacion_errores - 1
            for i_exponente_cuantizacion_coeficientes = 1:contador_exponente_cuantizacion_coeficientes - 1
                resultados_EMC(i_duracion_trama, i_p, i_exponente_cuantizacion_errores, i_exponente_cuantizacion_coeficientes) = fread(id, 1, 'float32');
            end
        end
    end
end
fclose(id);
