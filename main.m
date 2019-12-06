clear all;
delete coder_output;
delete decoder_output.wav;

id = fopen('input.wav', 'r');
[A, bytes_input] = fread(id, 'ubit8');
bytes_input = bytes_input/2
fclose(id);

tic;
signal = codificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto('input.wav','coder_output');
tiempo_codificador = toc

id = fopen('coder_output', 'r');
[A, bytes_codificados] = fread(id, 'ubit8');
bytes_codificados
fclose(id);

tic;
outputSignal = decodificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto('coder_output', 'decoder_output.wav');
tiempo_decodificador = toc

accumulation = 0;
for i_sample = 1:size(1,signal)
    accumulation = accumulation + (outputSignal(1,i_sample) - signal(i_sample))*(outputSignal(1,i_sample) - signal(i_sample));
end
ECM = accumulation/size(1,signal)