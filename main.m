clear all;
delete coder_output;
delete decoder_output.wav;

tic;
 = codificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto('input.wav','coder_output');
tiempo_codificador = toc

id = fopen('coder_output', 'r');
[A, bytes_codificados] = fread(id, 'ubit8');
bytes_codificados
fclose(id);

tic;
outputSignal = decodificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto('coder_output', 'decoder_output.wav');
tiempo_decodificador = toc

