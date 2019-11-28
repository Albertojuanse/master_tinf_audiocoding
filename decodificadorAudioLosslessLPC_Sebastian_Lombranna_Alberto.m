function decodificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto(audioWavFilenameInputUncompressed,filenameOutputCompressed)
%DECODIFICADORAUDIOLOSSLESSLPC_SEBASTIAN_LOMBRANNA_ALBERTO This decoder implements a LPC
%lossless coding algorithm for audio

%%%%%%%%%%%%
% EN ESTA SECCI�N DEL C�DIGO DEBER�A OCURRIR LA COMPRESI�N, ESCRITURA A
% FICHERO, LECTURA DE FICHERO Y DESCOMPRESI�N
%
% OJO: ESTE FICHERO NO RESPETA EL FORMATO DE LA PR�CTICA. VER GUION DE LA
% MISMA.
%%%%%%%%%%%%

% S�ntesis LPC y reconstrucci�n de la se�al de audio a partir de sus tramas
% a corto plazo
[outputSignal] = sintetiza_lpc_error(errores,coeficientes,solapamiento,tail,maxs); 

% Reproduce la se�la de audio
% sound(outputSignal,fs);

% Escribe audio a fichero WAV PCM
audiowrite('baselineAutputAudioFile.wav',outputSignal,fs); 

end