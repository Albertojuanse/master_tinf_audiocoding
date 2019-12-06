function [outputSignal] = decodificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto(audioWavFilenameInputUncompressed,filenameOutputCompressed)
%DECODIFICADORAUDIOLOSSLESSLPC_SEBASTIAN_LOMBRANNA_ALBERTO This decoder implements a LPC
%lossless coding algorithm for audio

%% Lectura de la cabecera
output_file_id = fopen(filenameOutputCompressed, 'a');

% En cabecera se guardan con dos primeros bit el número de bits usados en
% la cuantificación de los errores y los coeficientes
bits_cuantizacion_errores = fread(output_file_id, 1, 'ubit8');
bits_cuantizacion_coeficientes = fread(output_file_id, 1, 'ubit8');

% Se leen de sendos bytes con el número de bits para descodificar los 
% errores y los coeficientes.
numero_de_bits_minimo_errores = fread(output_file_id, 1, 'ubit8');
numero_de_bits_minimo_coeficientes = fread(output_file_id, 1, 'ubit8');
precision_errores = strcat('ubit',num2str(numero_de_bits_minimo_errores));
precision_coeficientes = strcat('ubit',num2str(numero_de_bits_minimo_coeficientes));

% Se recupera con otros cuatro bytes el número de bits necesarios para
% recuperar el número de valores que hay de cada.
numero_de_bits_del_numero_de_filas_errores = fread(output_file_id, 1, 'ubit8');
numero_de_bits_del_numero_de_coeficientes_errores = fread(output_file_id, 1, 'ubit8');
numero_de_bits_del_numero_de_filas_coeficientes = fread(output_file_id, 1, 'ubit8');
numero_de_bits_del_numero_de_coeficientes_coeficientes = fread(output_file_id, 1, 'ubit8');
precision_numero_de_filas_errores = strcat('ubit',num2str(numero_de_bits_del_numero_de_filas_errores));
precision_numero_de_columnas_errores = strcat('ubit',num2str(numero_de_bits_del_numero_de_coeficientes_errores));
precision_numero_de_filas_coeficientes = strcat('ubit',num2str(numero_de_bits_del_numero_de_filas_coeficientes));
precision_numero_de_columnas_coeficientes = strcat('ubit',num2str(numero_de_bits_del_numero_de_coeficientes_coeficientes));

% Se recupera el número de filas y columnas de errores y coeficientes que hay
% usando la precision calculada.
numero_de_filas_errores = fread(output_file_id, 1, precision_numero_de_filas_errores);
numero_de_columnas_errores = fread(output_file_id, 1, precision_numero_de_columnas_errores);
numero_de_filas_coeficientes = fread(output_file_id, 1, precision_numero_de_filas_coeficientes);
numero_de_columnas_coeficientes = fread(output_file_id, 1, precision_numero_de_columnas_coeficientes);

%% Lectura de la información
errores_cuantizados = zeros(numero_de_filas_errores, numero_de_columnas_errores);
coeficientes_cuantizados = zeros(numero_de_filas_coeficientes, numero_de_columnas_coeficientes);

% Se recuperan los errores y coeficientes fila por fila
for i_fila = 1:numero_de_filas_errores
    for i_columna = 1:numero_de_columnas_errores
        errores_cuantizados(i_fila,i_columna) = fread(output_file_id, 1, precision_errores);
    end
end
for i_fila = 1:numero_de_filas_coeficientes
    for i_columna = 1:numero_de_columnas_coeficientes
        coeficientes_cuantizados(i_fila,i_columna) = fread(output_file_id, 1, precision_coeficientes);
    end
end

% Se recuperan con dos float para el valor de tail y el de maxs
tail = fread(output_file_id, 1, 'float32');
maxs = fread(output_file_id, 1, 'float32');

fclose(output_file_id);

%% Cuantización de los errores
% Se ha de completar la cuantización que se había hecho; en el codificador 
% se multiplica por 2^number_bits_cuantizacion para obtener un entero al 
% hacerle el floor y se divide para volver al valor anterior en el 
% decodificador.
errores = errores_cuantizados/(2^bits_cuantizacion_errores);
coeficientes = coeficientes_cuantizados/(2^bits_cuantizacion_coeficientes);

%% Síntesis LPC y reconstrucción de la señal de audio a partir de sus tramas
% a corto plazo
[outputSignal] = sintetiza_lpc_error(errores,coeficientes,solapamiento,tail,maxs); 

%% Reproduce la señal de audio
% sound(outputSignal,fs);

%% Escribe audio a fichero WAV PCM
audiowrite('baselineAutputAudioFile.wav',outputSignal,fs);

end