function [signal] = codificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto(audioWavFilenameInputUncompressed,filenameOutputCompressed)
%CODIFICADORAUDIOLOSSLESSLPC_SEBASTIAN_LOMBRANNA_ALBERTO This coder implements a LPC
%lossless coding algorithm for audio

%% Parámetros de la codificación LPC a corto plazo
duracion_trama = 0.02;  % Duración de una trama en segundos 
solapamiento = 0;       % Tanto por uno de solapamiento de ventanas
p = 15;                 % Número de coeficientes del filtro LPC 5 3.5 3
% menor duracion_trama para menos MMS
% menor bits para tamaño
% hacer el huffman a todo el archivo y no por ventana
% menos coeficientes para comprimir

%% Lectura del fichero de audio
[signal_stereo,fs] = audioread(audioWavFilenameInputUncompressed);
signal = signal_stereo(:,1);

% Análisis LPC a corto plazo. Ver ayuda de la función analiza_lpc_error
[errores, coeficientes,tail,maxs] = analiza_lpc_error(signal, duracion_trama,solapamiento, p, fs);

%% Cuantización de errores y coeficientes
% Sólo se puede guardar en máquina de forma fácil y directa enteros.
% Se tiene que cometer un error cuadrático medio menor a 10^-1.
% Así que se multiplica cada muestra por 10^10, de tal forma que la parte
% entera contenga toda la información necesaria para reconstruir la señal
% con ese error cuadrático medio. Al guardarla en máquina la parte negativa
% se elimina, y por lo tanto existe una cuantización.
% Se cuantiza "en dos pasos"; en el codificador se multiplica por dicho
% valor para obtener un entero y se divide para volver al valor anterior en
% el decodificador.
exponente_cuantizacion_errores = 12;
errores_cuantizados = round(errores*(2^exponente_cuantizacion_errores));
errores_cuantizados(isnan(errores_cuantizados==1)) = 0;
error_cuantizado_minimo = min(min(errores_cuantizados));
errores_cuantizados = errores_cuantizados - error_cuantizado_minimo;

%% Análisis del audio
% Numero de valores
numero_de_filas_errores = size(errores_cuantizados,1);
numero_de_columnas_errores = size(errores_cuantizados,2);
numero_de_filas_coeficientes = size(coeficientes,1);
numero_de_columnas_coeficientes = size(coeficientes,2);
% Número de bits mínimo para guardar los valores; 1 más por el signo
numero_de_bits_minimo_errores = ceil(log2(abs(max(max(errores_cuantizados))))) + 1;

%% Codificado


%% Guardado de la cabecera
output_file_id = fopen(filenameOutputCompressed, 'a');

% En cabecera se guardan con dos primeros bit el exponente usado en la 
% cuantificación de los errores y los coeficientes
fwrite(output_file_id, exponente_cuantizacion_errores, 'float', 'ieee-be');
fwrite(output_file_id, error_cuantizado_minimo, 'float', 'ieee-be');

% Se guardan en sendos bytes con el número de bits para descodificar los 
% errores y los coeficientes.
fwrite(output_file_id, numero_de_bits_minimo_errores, 'float', 'ieee-be');
precision_errores = strcat('bit',num2str(numero_de_bits_minimo_errores));

% Se codifica el número de filas y columnas de errores y coeficientes que hay usando la
% precision calculada
fwrite(output_file_id, numero_de_filas_errores, 'float', 'ieee-be');
fwrite(output_file_id, numero_de_columnas_errores, 'float', 'ieee-be');
fwrite(output_file_id, numero_de_filas_coeficientes, 'float', 'ieee-be');
fwrite(output_file_id, numero_de_columnas_coeficientes, 'float', 'ieee-be');

% Se termina con dos float para el valor de tail y el de maxs
fwrite(output_file_id, tail, 'float', 'ieee-be');
fwrite(output_file_id, maxs, 'float', 'ieee-be');
fwrite(output_file_id, fs, 'float', 'ieee-be');

%% Guardado de la información
% Se guardan los errores y coeficientes fila por fila
for i_fila = 1:numero_de_filas_coeficientes
    for i_columna = 1:numero_de_columnas_coeficientes
        fwrite(output_file_id, coeficientes(i_fila,i_columna), 'float', 'ieee-be');
    end
end
for i_fila = 1:numero_de_filas_errores
    for i_columna = 1:numero_de_columnas_errores
        fwrite(output_file_id, errores_cuantizados(i_fila,i_columna), precision_errores);
    end
end

% Se añade un byte de seguridad contra errores en la precisión
fwrite(output_file_id, 0, 'ubit8');

fclose(output_file_id);

end