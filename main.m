clear all;
delete coder_output;
delete decoder_output.wav;

tic;
codificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto('input.wav','coder_output');
tiempo_codificador = toc

tic;
decodificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto('coder_output', 'decoder_output.wav');
tiempo_decodificador = toc