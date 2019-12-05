function codificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto(audioWavFilenameInputUncompressed,filenameOutputCompressed)
%CODIFICADORAUDIOLOSSLESSLPC_SEBASTIAN_LOMBRANNA_ALBERTO This coder implements a LPC
%lossless coding algorithm for audio

% Parámetros de la codificación LPC a corto plazo
duracion_trama = 0.02;  % Duración de una trama en segundos 
solapamiento = 0;       % Tanto por uno de solapamiento de ventanas
p = 15;                 % Número de coeficientes del filtro LPC

% Lectura del fichero de audio
[signal_stereo,fs] = audioread(audioWavFilenameInputUncompressed);
signal = signal_stereo(:,1);

% Análisis LPC a corto plazo. Ver ayuda de la función analiza_lpc_error
[errores, coeficientes,tail,maxs] = analiza_lpc_error(signal, duracion_trama,solapamiento, p, fs);

% Codificacion
number_bits_cuantizacion = 10;  % Se cuantiza "en dos pasos"; en el codificador
                                % se multiplica por 2^number_bits_cuantizacion
                                % para obtener un entero al hacerle el
                                % floot y se divide para volver al valor
                                % anterior en el decodificador.

% menor duracion_trama para menos MMS
% menor bits para tamaño
% hacer el huffman a todo el archivo y no por ventana
% menos coeficientes para comprimir
numero_de_muestras_distintos = size((unique(floor(errores(:,:)*(2^number_bits_cuantizacion)))),1);
maxima_muestra_distinta = max(max(floor(errores(:,:)*(2^number_bits_cuantizacion))));
numero_de_bits_minimo_muestras = ceil(log2(max(max(floor(errores(:,:)*(2^number_bits_cuantizacion)))))) + 1;
numero_de_bits_minimo_simbolos = ceil(log2(size((unique(floor(errores(:,:)*(2^number_bits_cuantizacion)))),1))) + 1;

numero_de_bits_minimo_coeficientes = ceil(log2(max(max(floor(coeficientes(:,:)*(2^number_bits_cuantizacion)))))) + 1;
max(numero_de_bits_minimo_coeficientes,numero_de_bits_minimo_muestras);
%mas uno de signo

output_file_id = fopen(filenameOutputCompressed, 'a');
fwrite(input_file_id, errores, 'ubit13');
fwrite(input_file_id, coeficientes, 'ubit13');
fwrite(input_file_id, tail, 'ubit13');
fwrite(input_file_id, max, 'ubit13');
fclose(input_file_id);

end