function baselineAudioProcesses(audioWavFilenameInputUncompressed)
% Función "Baseline" de codificación de audio LPC sin pérdidas, para
% práctica de codificación de audio sin pérdidas de TiCom
%
% El código de este fichero no constituye la entrega de la práctica, sino
% que está pensado para servir de base para los desarrollos posteriores del
% estudiante.
%
% La función realiza un códec de audio LPC, pero sin comprimir la señal de
% audio. Simplemente realiza la codifciación de audio LPC a corto plazo y
% la dedodificación posterior para reconstruir la señal de audio, para así
% liberar al estudiante de la tarea de realizar dicho procesado de audio.
%
% Es importante notar que el códec utiliza una ley de compresión de audio
% utilizando Ley A, necesaria para evitar distorsión en la reconstrucción
% de la señal.
%
% En concreto, la función sigue los siguientes pasos:
%
%   * División de señal en fragmentos enventanados a corto plazo.
%
%   * Separación de cada ventana de señal en coeficientes LPC y señal
%     error.
%
%   * Síntesis LPC para recuperar las tramas de audio a corto plazo, a
%     partir de la señal de error y los coeficientes de los filtros LPC.
%
%   * Reconstruir la señal de audio a partir de las ventanas a corto plazo.
%
% El código está pensado para codificar y decodificar audio wav PCM con 16
% bits por muestra y una frecuencia de muestreo de 44100 Hz.
%
% El código está convenientemente comentado para facilitar su uso por parte
% del estudiante
%
% AUTOR: Daniel Ramos Castro, a partir del código de la Práctica de TiCom
% de Alejandro Peña Almansa durante el curso 2018-19 (código utilizado y
% publicado bajo consentimiento del autor).

% Parámetros de la codificación LPC a corto plazo
% EL ESTUDIANTE PUEDE CAMBIARLOS A CONVENIENCIA SI LO CONSIDERA NECESARIO
duracion_trama = 0.02; % Duración de una trama en segundos
solapamiento = 0; % Tanto por uno de solapamiento de ventanas
p = 15; % Número de coeficientes del filtro LPC

% Lectura del fichero de audio
% SE RECOMIENDA EXPLORAR LAS FUNCIONES DE AUDIO RELACIONADAS (audioplayer,
% play, etc.). Ver "doc audioplayer" para referencia en Matlab(TM)
[signal,fs] = audioread(audioWavFilenameInputUncompressed);

% Análisis LPC a corto plazo. Ver ayuda de la función analiza_lpc_error
[errores, coeficientes,tail,maxs] = analiza_lpc_error(signal, duracion_trama,solapamiento, p, fs);

%%%%%%%%%%%%
% EN ESTA SECCIÓN DEL CÓDIGO DEBERÍA OCURRIR LA COMPRESIÓN, ESCRITURA A
% FICHERO, LECTURA DE FICHERO Y DESCOMPRESIÓN
%
% OJO: ESTE FICHERO NO RESPETA EL FORMATO DE LA PRÁCTICA. VER GUION DE LA
% MISMA.
%%%%%%%%%%%%

% Síntesis LPC y reconstrucción de la señal de audio a partir de sus tramas
% a corto plazo
[outputSignal] = sintetiza_lpc_error(errores,coeficientes,solapamiento,tail,maxs); 

% Reproduce la señla de audio
% sound(outputSignal,fs);

% Escribe audio a fichero WAV PCM
audiowrite('baselineAutputAudioFile.wav',outputSignal,fs); 

end

%%Función para realizar el análisis LPC de corto plazo
function [errores, coeficientes,tail,maxs] = analiza_lpc_error(signal, duracion_trama,solapamiento, p, fs)


[tramas,tail,maxs] = obtiene_tramas(signal,fs, duracion_trama, solapamiento);
[len_trama,n_trama,~] = size(tramas);

errores = zeros(len_trama,n_trama);
coeficientes = zeros(p,n_trama);

for i = 1:n_trama
    
    trama = tramas(:,i);
    [a,G] = lpc(trama,p);
    
    prediccion = filter([0 -a(2:end)], 1, trama);
    
    errores(:,i) = trama - prediccion;
    coeficientes(:,i) = a(2:end);

end;

end

%%Función de enventanado de la señal y compresión de rango
% ENTRADAS:
%   * signal: audio de entrada (según se extrae del fichero wav).
%   * fs: frecuencia de muestreo del audio
%   * duracion_trama: duración de la trama definida en el códec.
%   * Solapamiento define el solapamiento entre tramas.
% 
% SALIDAS:
%   * tramas: array de tramas, ocn tantas filas como muestras por
%      tramas, y tantas columnas como tramas.
%   * tailInf: tamaño de la última ventana (podría ser menor que el tamaño
%      del resto de ventanas).
%   * maxs: máximo valor de la señal de audio.
function [tramas,tailInf,maxs] = obtiene_tramas(signal, fs, duracion_trama,solapamiento)

%%Por defecto se aplicará una ventana Hamming a las tramas
ventana = floor(duracion_trama*fs);
maxs = max(signal);

Window = hamming(ventana,'periodic');
Desplazamiento = (1-solapamiento)*ventana;
nv=floor((length(signal)-ventana)/Desplazamiento);
if solapamiento == 0
    Window = ones(ventana,1);
    nv = floor((length(signal))/Desplazamiento);
end;

tramas = zeros(ventana,nv + 1);
for i = 1:nv
    trama = signal((i-1)*Desplazamiento+1:(i-1)*Desplazamiento+ventana);
    trama = trama.*Window; 
    % La siguiente línea plica una ley A de compresión, que favorece que se
    % dé más importancia a las partes de señal más cercanas a cero.
    % Supuestamente favorece la compresión desde el punto de vista del
    % error de reconstrucción del audio al decodificar.
    tramas(:,i) = compand(trama,87.6,maxs,'a/compressor');
end;

tailInf = length(signal(nv*Desplazamiento+1:end));
if tailInf > ventana
    tailInf = ventana-1;
end;

tramas(1:tailInf,nv+1) = signal(nv*Desplazamiento+1:nv*Desplazamiento + tailInf);
tramas(:,nv + 1) = compand(tramas(:,nv + 1).*Window,87.6,maxs,'a/compressor');

end



%%Síntesis de la señal LPC
function [output_signal] = sintetiza_lpc_error(errores, coeficientes,solapamiento,tail,maxs)

[len_trama,n_trama,~] = size(errores);

if solapamiento == 0
    output_signal = zeros(1,len_trama*n_trama);

    for i = 1:n_trama
    
        trama_error = errores(:,i);
        a = coeficientes(:,i)';
    
        trama_recuperada = filter(1, [1 a], trama_error);
    
        % Aplica el inverso de la ley A de compresión
        output_signal((i-1)*len_trama+1:i*len_trama) = compand(trama_recuperada,87.6,maxs,'a/expander');
    
    
    end;
else
    Desplazamiento = (1-solapamiento) * len_trama;
    len = (n_trama) * Desplazamiento + len_trama;
    output_signal = zeros(1,len);
    
    for i = 1:n_trama
        trama_error = errores(:,i);
        a = coeficientes(:,i)';
        trama_recuperada = filter(1, [1 a(2:end)], trama_error);
        output_signal((i-1)*Desplazamiento+1:(i-1)*Desplazamiento+len_trama) = output_signal((i-1)*Desplazamiento+1:(i-1)*Desplazamiento+len_trama) + trama_recuperada';
    end;
    
    hammingWindow = hamming(len_trama,'periodic');
    inverseHammingWindow = 1.08./hammingWindow;
    output_signal = output_signal./1.08;%% Con un solapamiento bien hecho obtendremos la señal original ponderada por 1.08 salvo el comienzo y el final
    
    output_signal(1:len_trama/2) = output_signal(1:len_trama/2).* inverseHammingWindow(1:len_trama/2)';
    output_signal(end-len_trama/2:end) = output_signal(end-len_trama/2:end).* inverseHammingWindow(end-len_trama/2:end)';
    
end;

output_signal(isnan(output_signal)==1) = 0;%% En ocasiones se producen NaN con el análisis LPC, lo dejamos en cero mejor
output_signal = output_signal(1:end-len_trama + tail);
end