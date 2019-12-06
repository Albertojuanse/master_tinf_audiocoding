function [signal] = codificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto(audioWavFilenameInputUncompressed,filenameOutputCompressed)
%CODIFICADORAUDIOLOSSLESSLPC_SEBASTIAN_LOMBRANNA_ALBERTO This coder implements a LPC
%lossless coding algorithm for audio

%% Parámetros de la codificación LPC a corto plazo
duracion_trama = 0.02;  % Duración de una trama en segundos 
solapamiento = 0;       % Tanto por uno de solapamiento de ventanas
p = 15;                 % Número de coeficientes del filtro LPC
% menor duracion_trama para menos MMS
% menor bits para tamaño
% hacer el huffman a todo el archivo y no por ventana
% menos coeficientes para comprimir

%% Lectura del fichero de audio
[signal_stereo,fs] = audioread(audioWavFilenameInputUncompressed);
signal = signal_stereo(:,1);

% Análisis LPC a corto plazo. Ver ayuda de la función analiza_lpc_error
[errores, coeficientes,tail,maxs] = analiza_lpc_error(signal, duracion_trama,solapamiento, p, fs);

%% Parámetros de la codificación
bits_cuantizacion_errores = 12;
bits_cuantizacion_coeficientes = 12;

%% Cuantización de errores y coeficientes
% Se cuantiza "en dos pasos"; en el codificador se multiplica por 
% 2^number_bits_cuantizacion para obtener un entero al hacerle el floor
% y se divide para volver al valor anterior en el decodificador.
errores_cuantizados = floor(errores*(2^bits_cuantizacion_errores));
coeficientes_cuantizados = floor(coeficientes*(2^bits_cuantizacion_coeficientes));


%% Análisis del audio
% Numero de valores
numero_de_filas_errores = size(errores_cuantizados,1);
numero_de_columnas_errores = size(errores_cuantizados,2);
numero_de_filas_coeficientes = size(coeficientes_cuantizados,1);
numero_de_columnas_coeficientes = size(coeficientes_cuantizados,2);
% Numero de bits `para codificar estas cantidades
numero_de_bits_del_numero_de_filas_errores = ceil(log2(numero_de_filas_errores));
numero_de_bits_del_numero_de_coeficientes_errores = ceil(log2(numero_de_columnas_errores));
numero_de_bits_del_numero_de_filas_coeficientes = ceil(log2(numero_de_filas_coeficientes));
numero_de_bits_del_numero_de_coeficientes_coeficientes = ceil(log2(numero_de_columnas_coeficientes));
% Valores máximos
maximo_error = max(max(errores_cuantizados));
maximo_coeficiente = max(max(coeficientes_cuantizados));
% Número de valores distintos
numero_de_errores_distintos = size(unique(errores_cuantizados),1);
numero_de_coeficientes_distintos = size(unique(coeficientes_cuantizados),1);
% Número de bits mínimo para guardar los valores; 1 más por el signo
numero_de_bits_minimo_errores = ceil(log2(maximo_error)) + 1;
numero_de_bits_minimo_coeficientes = ceil(log2(maximo_coeficiente)) + 1;
% Número de bits mínimo para guardar los símbolos que codifiquen los
% valores
numero_de_bits_minimo_simbolos_errores = ceil(log2(numero_de_errores_distintos)) + 1;
numero_de_bits_minimo_simbolos_coeficientes = ceil(log2(numero_de_coeficientes_distintos)) + 1;

%% Codificado


%% Guardado de la cabecera
output_file_id = fopen(filenameOutputCompressed, 'a');

% En cabecera se guardan con dos primeros bit el número de bits usados en
% la cuantificación de los errores y los coeficientes
fread(output_file_id, bits_cuantizacion_errores, 'ubit8');
fread(output_file_id, bits_cuantizacion_coeficientes, 'ubit8')

% Se guardan en sendos bytes con el número de bits para descodificar los 
% errores y los coeficientes.
fwrite(output_file_id, numero_de_bits_minimo_errores, 'ubit8');
fwrite(output_file_id, numero_de_bits_minimo_coeficientes, 'ubit8');
precision_errores = strcat('ubit',num2str(numero_de_bits_minimo_errores));
precision_coeficientes = strcat('ubit',num2str(numero_de_bits_minimo_coeficientes));

% Se guarda con otros cuatro bytes el número de bits necesarios para
% recuperar el número de valores que hay de cada.
fwrite(output_file_id, numero_de_bits_del_numero_de_filas_errores, 'ubit8');
fwrite(output_file_id, numero_de_bits_del_numero_de_coeficientes_errores, 'ubit8');
fwrite(output_file_id, numero_de_bits_del_numero_de_filas_coeficientes, 'ubit8');
fwrite(output_file_id, numero_de_bits_del_numero_de_coeficientes_coeficientes, 'ubit8');
precision_numero_de_filas_errores = strcat('ubit',num2str(numero_de_bits_del_numero_de_filas_errores));
precision_numero_de_columnas_errores = strcat('ubit',num2str(numero_de_bits_del_numero_de_coeficientes_errores));
precision_numero_de_filas_coeficientes = strcat('ubit',num2str(numero_de_bits_del_numero_de_filas_coeficientes));
precision_numero_de_columnas_coeficientes = strcat('ubit',num2str(numero_de_bits_del_numero_de_coeficientes_coeficientes));

% Se codifica el número de filas y columnas de errores y coeficientes que hay usando la
% precision calculada
fwrite(output_file_id, numero_de_filas_errores, precision_numero_de_filas_errores);
fwrite(output_file_id, numero_de_columnas_errores, precision_numero_de_columnas_errores);
fwrite(output_file_id, numero_de_filas_coeficientes, precision_numero_de_filas_coeficientes);
fwrite(output_file_id, numero_de_columnas_coeficientes, precision_numero_de_columnas_coeficientes);

%% Guardado de la información
% Se guardan los errores y coeficientes fila por fila
for i_fila = 1:numero_de_filas_errores
    for i_columna = 1:numero_de_columnas_errores
        fwrite(output_file_id, errores_cuantizados(i_fila,i_columna), precision_errores);
    end
end
for i_fila = 1:numero_de_filas_coeficientes
    for i_columna = 1:numero_de_columnas_coeficientes
        fwrite(output_file_id, coeficientes_cuantizados(i_fila,i_columna), precision_coeficientes);
    end
end

% Se termina con dos float para el valor de tail y el de maxs
fwrite(output_file_id, tail, 'float32');
fwrite(output_file_id, maxs, 'float32');
% Se añade un byte de seguridad contra errores en la precisión
fwrite(output_file_id, 0, 'ubit8');

fclose(output_file_id);

end