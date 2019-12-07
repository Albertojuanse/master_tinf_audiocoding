function [outputSignal] = decodificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto(audioWavFilenameInputUncompressed,filenameOutputCompressed)
%DECODIFICADORAUDIOLOSSLESSLPC_SEBASTIAN_LOMBRANNA_ALBERTO This decoder implements a LPC
%lossless coding algorithm for audio

%% Parámetros de la codificación LPC a corto plazo
duracion_trama = 0.02;  % Duración de una trama en segundos 
solapamiento = 0;       % Tanto por uno de solapamiento de ventanas
p = 15;                 % Número de coeficientes del filtro LPC

%% Lectura de la cabecera
input_file_id = fopen(audioWavFilenameInputUncompressed, 'r');

% En cabecera se guardan con dos primeros bit el exponente usado en la 
% cuantificación de los errores y los coeficientes
exponente_cuantizacion_errores = fread(input_file_id, 1, 'ubit8');
exponente_cuantizacion_coeficientes = fread(input_file_id, 1, 'ubit8');

% Se leen de sendos bytes con el número de bits para descodificar los 
% errores y los coeficientes.
numero_de_bits_minimo_errores = fread(input_file_id, 1, 'ubit8');
numero_de_bits_minimo_coeficientes = fread(input_file_id, 1, 'ubit8');
numero_de_bits_minimo_maxs = fread(input_file_id, 1, 'ubit8');
precision_errores = strcat('bit',num2str(numero_de_bits_minimo_errores));
precision_coeficientes = strcat('bit',num2str(numero_de_bits_minimo_coeficientes));
precision_maxs = strcat('bit',num2str(numero_de_bits_minimo_maxs));

% Se recupera con otros cuatro bytes el número de bits necesarios para
% recuperar el número de valores que hay de cada.
numero_de_bits_del_numero_de_filas_errores = fread(input_file_id, 1, 'ubit8');
numero_de_bits_del_numero_de_columnas_errores = fread(input_file_id, 1, 'ubit8');
numero_de_bits_del_numero_de_filas_coeficientes = fread(input_file_id, 1, 'ubit8');
numero_de_bits_del_numero_de_columnas_coeficientes = fread(input_file_id, 1, 'ubit8');
precision_numero_de_filas_errores = strcat('ubit',num2str(numero_de_bits_del_numero_de_filas_errores));
precision_numero_de_columnas_errores = strcat('ubit',num2str(numero_de_bits_del_numero_de_columnas_errores));
precision_numero_de_filas_coeficientes = strcat('ubit',num2str(numero_de_bits_del_numero_de_filas_coeficientes));
precision_numero_de_columnas_coeficientes = strcat('ubit',num2str(numero_de_bits_del_numero_de_columnas_coeficientes));

% Se recupera el número de filas y columnas de errores y coeficientes que hay
% usando la precision calculada.
numero_de_filas_errores = fread(input_file_id, 1, precision_numero_de_filas_errores);
numero_de_columnas_errores = fread(input_file_id, 1, precision_numero_de_columnas_errores);
numero_de_filas_coeficientes = fread(input_file_id, 1, precision_numero_de_filas_coeficientes);
numero_de_columnas_coeficientes = fread(input_file_id, 1, precision_numero_de_columnas_coeficientes);

%% Lectura de la información
errores_cuantizados = zeros(numero_de_filas_errores, numero_de_columnas_errores);
coeficientes_cuantizados = zeros(numero_de_filas_coeficientes, numero_de_columnas_coeficientes);

% Se recuperan los errores y coeficientes fila por fila
for i_fila = 1:numero_de_filas_errores
    for i_columna = 1:numero_de_columnas_errores
        errores_cuantizados(i_fila,i_columna) = fread(input_file_id, 1, precision_errores);
    end
end
for i_fila = 1:numero_de_filas_coeficientes
    for i_columna = 1:numero_de_columnas_coeficientes
        coeficientes_cuantizados(i_fila,i_columna) = fread(input_file_id, 1, precision_coeficientes);
    end
end

% Se recuperan con dos float para el valor de tail y el de maxs
tail = fread(input_file_id, 1, 'bit32');
maxs_cuantizado = fread(input_file_id, 1, precision_maxs);

fclose(input_file_id);

%% Cuantización de los errores
% Se ha de completar la cuantización que se había hecho.
errores = errores_cuantizados/(10^exponente_cuantizacion_errores);
coeficientes = coeficientes_cuantizados/(10^exponente_cuantizacion_coeficientes);
maxs = maxs_cuantizado/(10^exponente_cuantizacion_errores);

%% Síntesis LPC y reconstrucción de la señal de audio a partir de sus tramas
% a corto plazo
[outputSignal] = sintetiza_lpc_error(errores,coeficientes,solapamiento,tail,maxs); 

%% Reproduce la señal de audio
% sound(outputSignal,fs);

%% Escribe audio a fichero WAV PCM
audiowrite('baselineAutputAudioFile.wav',outputSignal,fs);

end