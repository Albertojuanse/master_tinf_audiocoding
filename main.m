clear all;
delete coder_output;
delete decoder_output.wav;

id = fopen('TheWorldtoMe_RosieDias.wav', 'r');
[A, bytes_input] = fread(id, 'ubit8');
bytes_input = bytes_input/2
fclose(id);

tic;
% 'Be Brave- WAV.wav'
% 'input.wav'
% 'TheWorldtoMe_RosieDias.wav'
signal = codificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto('TheWorldtoMe_RosieDias.wav','coder_output');
tiempo_codificador = toc

id = fopen('coder_output', 'r');
[A, bytes_codificados] = fread(id, 'ubit8');
bytes_codificados
fclose(id);

tic;
outputSignal = decodificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto('coder_output', 'decoder_output.wav');
tiempo_decodificador = toc

accumulation = 0;
for i_sample = 1:min(size(outputSignal,2),size(signal,1) )
    if outputSignal(1,i_sample) > 1
        outputSignal(1,i_sample)
    end
    accumulation = accumulation + (outputSignal(1,i_sample) - signal(i_sample,1))*(outputSignal(1,i_sample) - signal(i_sample,1));
end
ECM = accumulation/min(size(outputSignal,2),size(signal,1) )