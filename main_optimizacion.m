clear all;
delete coder_output;
delete decoder_output.wav;

%% Parámetros
duracion_trama = [0.001 0.005 0.01 0.05 0.1 0.5 1 5];
p = 5:2:19;             
exponente_cuantizacion_errores = 5:7;
exponente_cuantizacion_coeficientes = 4:6;

%% Resultados
total_simulaciones = size(duracion_trama,2) * size(p,2) * size(exponente_cuantizacion_errores,2) * size(exponente_cuantizacion_coeficientes,2);
contador_duracion_trama = 1;
contador_p = 1;
contador_exponente_cuantizacion_errores = 1;
contador_exponente_cuantizacion_coeficientes = 1;
contador = 1;
resultados_EMC = zeros(size(duracion_trama,2), size(p,2), size(exponente_cuantizacion_errores,2), size(exponente_cuantizacion_coeficientes,2));
resultados_r_comprension = zeros(size(duracion_trama,2), size(p,2), size(exponente_cuantizacion_errores,2), size(exponente_cuantizacion_coeficientes,2));

id = fopen('input.wav', 'r');
[A, bytes_input] = fread(id, 'ubit8');
bytes_input = bytes_input/2;
fclose(id);

for i_duracion_trama = duracion_trama
    for i_p = p
        for i_exponente_cuantizacion_errores = exponente_cuantizacion_errores
            for i_exponente_cuantizacion_coeficientes = exponente_cuantizacion_coeficientes

                delete coder_output;
                delete decoder_output.wav;
                
                %tic;
                signal = codificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto('input.wav','coder_output', i_duracion_trama, i_p, i_exponente_cuantizacion_errores, i_exponente_cuantizacion_coeficientes);
                %tiempo_codificador = toc;

                id = fopen('coder_output', 'r');
                [A, bytes_codificados] = fread(id, 'ubit8');
                resultados_r_comprension(contador_duracion_trama, contador_p, contador_exponente_cuantizacion_errores, contador_exponente_cuantizacion_coeficientes) = bytes_codificados/bytes_input;
                fclose(id);

                %tic;
                outputSignal = decodificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto('coder_output', 'decoder_output.wav');
                %tiempo_decodificador = toc;

                % sound(outputSignal,fs);

                %id = fopen('decoder_output.wav', 'r');
                %[A, bytes_output] = fread(id, 'ubit8');
                %bytes_output = bytes_input
                %fclose(id);

                accumulation = 0;
                for i_sample = 1:size(signal,1)
                    accumulation = accumulation + (outputSignal(1,i_sample) - signal(i_sample))*(outputSignal(1,i_sample) - signal(i_sample));
                end
                resultados_EMC(contador_duracion_trama, contador_p, contador_exponente_cuantizacion_errores, contador_exponente_cuantizacion_coeficientes) = accumulation/size(signal,1);
                
                contador_exponente_cuantizacion_coeficientes = contador_exponente_cuantizacion_coeficientes + 1;
                contador = contador + 1;
                restante = total_simulaciones - contador
                
            end
            contador_exponente_cuantizacion_errores = contador_exponente_cuantizacion_errores + 1;
        end
        contador_p = contador_p + 1;
    end
    contador_duracion_trama = contador_duracion_trama + 1;
end

%% Análisis de los resultados
resultados_EMC_reducidos = resultados_EMC(:,:,1,1);
resultados_r_comprension_reducidos = resultados_r_comprension(:,:,1,1);
plot(resultados_EMC_reducidos);
plot(resultados_r_comprension_reducidos);

%% Guardado de resultados

id = fopen('resultados', 'a');
fwrite(id, contador_duracion_trama, 'ubit8');
fwrite(id, contador_p, 'ubit8');
fwrite(id, contador_exponente_cuantizacion_errores, 'ubit8');
fwrite(id, contador_exponente_cuantizacion_coeficientes, 'ubit8');
for i_duracion_trama = 1:contador_duracion_trama - 1
    for i_p = 1:contador_p - 1 
        for i_exponente_cuantizacion_errores = 1:contador_exponente_cuantizacion_errores - 1
            for i_exponente_cuantizacion_coeficientes = 1:contador_exponente_cuantizacion_coeficientes - 1
                fwrite(id, resultados_r_comprension(i_duracion_trama, i_p, i_exponente_cuantizacion_errores, i_exponente_cuantizacion_coeficientes), 'float32');
            end
        end
    end
end
for i_duracion_trama = 1:contador_duracion_trama - 1
    for i_p = 1:contador_p - 1
        for i_exponente_cuantizacion_errores = 1:contador_exponente_cuantizacion_errores - 1
            for i_exponente_cuantizacion_coeficientes = 1:contador_exponente_cuantizacion_coeficientes - 1
                fwrite(id, resultados_EMC(i_duracion_trama, i_p, i_exponente_cuantizacion_errores, i_exponente_cuantizacion_coeficientes), 'float32');
            end
        end
    end
end
fclose(id);
