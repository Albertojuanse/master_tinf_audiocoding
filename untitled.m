duracion_trama = 0.001; % Duración de una trama en segundos 
solapamiento = 0;       % Tanto por uno de solapamiento de ventanas
p = 5;                  % Número de coeficientes del filtro LPC
% menor duracion_trama para menos MMS
% menor bits para tamaño
% hacer el huffman a todo el archivo y no por ventana
% menos coeficientes para comprimir

%% Lectura del fichero de audio
[signal_stereo,fs] = audioread('input.wav');
signal = signal_stereo(:,1);

% Análisis LPC a corto plazo. Ver ayuda de la función analiza_lpc_error
[errores, coeficientes,tail,maxs] = analiza_lpc_error(signal, duracion_trama,solapamiento, p, fs);
exponente_cuantizacion_errores = 3.5;
exponente_cuantizacion_coeficientes = 3;
errores_cuantizados = round(errores*(10^exponente_cuantizacion_errores));

%%
bits = zeros(1,size(errores,2));
for i_columna = 1:size(errores,2)
    maximo_error_columna = max(errores_cuantizados(:,i_columna));
    numero_de_bits_minimo_errores = ceil(log2(abs(maximo_error_columna))) + 1;
    bits(i_columna) = numero_de_bits_minimo_errores;
end 
plot(bits)