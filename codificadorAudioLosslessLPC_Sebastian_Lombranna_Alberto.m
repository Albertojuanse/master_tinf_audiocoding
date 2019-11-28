function codificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto(audioWavFilenameInputUncompressed,filenameOutputCompressed)
%CODIFICADORAUDIOLOSSLESSLPC_SEBASTIAN_LOMBRANNA_ALBERTO This coder implements a LPC
%lossless coding algorithm for audio

% Parámetros de la codificación LPC a corto plazo
duracion_trama = 0.02;  % Duración de una trama en segundos
solapamiento = 0;       % Tanto por uno de solapamiento de ventanas
p = 15;                 % Número de coeficientes del filtro LPC

% Lectura del fichero de audio
[signal,fs] = audioread(audioWavFilenameInputUncompressed);

% Análisis LPC a corto plazo. Ver ayuda de la función analiza_lpc_error
[errores, coeficientes,tail,maxs] = analiza_lpc_error(signal, duracion_trama,solapamiento, p, fs);

end