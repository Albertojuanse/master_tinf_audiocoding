function codificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto(audioWavFilenameInputUncompressed,filenameOutputCompressed)
%CODIFICADORAUDIOLOSSLESSLPC_SEBASTIAN_LOMBRANNA_ALBERTO This coder implements a LPC
%lossless coding algorithm for audio

% Par�metros de la codificaci�n LPC a corto plazo
duracion_trama = 0.02; % Duraci�n de una trama en segundos
solapamiento = 0; % Tanto por uno de solapamiento de ventanas
p = 15; % N�mero de coeficientes del filtro LPC

% Lectura del fichero de audio
[signal,fs] = audioread(audioWavFilenameInputUncompressed);

% An�lisis LPC a corto plazo. Ver ayuda de la funci�n analiza_lpc_error
[errores, coeficientes,tail,maxs] = analiza_lpc_error(signal, duracion_trama,solapamiento, p, fs);

%%%%%%%%%%%%
% EN ESTA SECCI�N DEL C�DIGO DEBER�A OCURRIR LA COMPRESI�N, ESCRITURA A
% FICHERO, LECTURA DE FICHERO Y DESCOMPRESI�N
%
% OJO: ESTE FICHERO NO RESPETA EL FORMATO DE LA PR�CTICA. VER GUION DE LA
% MISMA.
%%%%%%%%%%%%

end