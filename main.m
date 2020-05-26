clear all;
delete coder_output;
delete decoder_output.wav;

% 'Be Brave- WAV.wav'
% 'input.wav'
% 'TheWorldtoMe_RosieDias.wav'
fichero = 'TheWorldtoMe_RosieDias.wav';

id = fopen(fichero, 'r');
[A, bytes_input] = fread(id, 'ubit8');
bytes_input = bytes_input/2
fclose(id);

tic;

% errores_cuantizados = round(errores*(2^exponente_cuantizacion_errores));
% errores_cuantizados(isnan(errores_cuantizados==1)) = 0;
% error_cuantizado_minimo = min(errores_cuantizados(:));
% errores_cuantizados = errores_cuantizados - error_cuantizado_minimo;'float', 'ieee-be'

[signal] = codificadorAudioLosslessLPC_Sebastian_Lombranna_Alberto(fichero,'coder_output');
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