function [outputSignal] = decodificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto(filenameInputCompressed,audioWavFilenameOuputUncompressed)
%DECODIFICADORAUDIOLOSSLESSLPC_SEBASTIAN_LOMBRANNA_ALBERTO This decoder implements a LPC
%lossless coding algorithm for audio

%% Parámetros de la codificación LPC a corto plazo
duracion_trama = 0.02; % Duración de una trama en segundos 
solapamiento = 0;      % Tanto por uno de solapamiento de ventanas
p = 15;                % Número de coeficientes del filtro LPC

%% Lectura de la cabecera
input_file_id = fopen(filenameInputCompressed, 'r');

% En cabecera se guardan con dos primeros bit el exponente usado en la 
% cuantificación de los errores y los coeficientes
exponente_cuantizacion_errores = fread(input_file_id, 1, 'float', 'ieee-be');
error_cuantizado_minimo = fread(input_file_id, 1, 'float', 'ieee-be');

% Se leen de sendos bytes con el número de bits para descodificar los 
% errores y los coeficientes.
numero_de_bits_minimo_errores = fread(input_file_id, 1, 'float', 'ieee-be');
precision_errores = strcat('bit',num2str(numero_de_bits_minimo_errores));

% Se recupera el número de filas y columnas de errores y coeficientes que hay
% usando la precision calculada.
numero_de_filas_errores = fread(input_file_id, 1, 'float', 'ieee-be');
numero_de_columnas_errores = fread(input_file_id, 1, 'float', 'ieee-be');
numero_de_filas_coeficientes = fread(input_file_id, 1, 'float', 'ieee-be');
numero_de_columnas_coeficientes = fread(input_file_id, 1, 'float', 'ieee-be');

% Se recuperan con dos float para el valor de tail y el de maxs
tail = fread(input_file_id, 1, 'float', 'ieee-be');
maxs = fread(input_file_id, 1, 'float', 'ieee-be');
fs = fread(input_file_id, 1, 'float', 'ieee-be');

%% Lectura de la información
errores_cuantizados = zeros(numero_de_filas_errores, numero_de_columnas_errores);
coeficientes = zeros(numero_de_filas_coeficientes, numero_de_columnas_coeficientes);

% Se recuperan los errores y coeficientes fila por fila
for i_fila = 1:numero_de_filas_coeficientes
    for i_columna = 1:numero_de_columnas_coeficientes
        coeficientes(i_fila,i_columna) = fread(input_file_id, 1, 'float', 'ieee-be');
    end
end
for i_fila = 1:numero_de_filas_errores
    for i_columna = 1:numero_de_columnas_errores
        errores_cuantizados(i_fila,i_columna) = fread(input_file_id, 1, precision_errores);
    end
end

fclose(input_file_id);

%% Cuantización de los errores
% Se ha de completar la cuantización que se había hecho.
errores_cuantizados = errores_cuantizados + error_cuantizado_minimo;
errores = errores_cuantizados/(2^exponente_cuantizacion_errores);

%% Síntesis LPC y reconstrucción de la señal de audio a partir de sus tramas
% a corto plazo
[outputSignal] = sintetiza_lpc_error(errores,coeficientes,solapamiento,tail,maxs);

%% Escribe audio a fichero WAV PCM
audiowrite(audioWavFilenameOuputUncompressed,outputSignal,fs);

end