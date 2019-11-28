function baselineAudioProcesses(audioWavFilenameInputUncompressed)
% Funci�n "Baseline" de codificaci�n de audio LPC sin p�rdidas, para
% pr�ctica de codificaci�n de audio sin p�rdidas de TiCom
%
% El c�digo de este fichero no constituye la entrega de la pr�ctica, sino
% que est� pensado para servir de base para los desarrollos posteriores del
% estudiante.
%
% La funci�n realiza un c�dec de audio LPC, pero sin comprimir la se�al de
% audio. Simplemente realiza la codifciaci�n de audio LPC a corto plazo y
% la dedodificaci�n posterior para reconstruir la se�al de audio, para as�
% liberar al estudiante de la tarea de realizar dicho procesado de audio.
%
% Es importante notar que el c�dec utiliza una ley de compresi�n de audio
% utilizando Ley A, necesaria para evitar distorsi�n en la reconstrucci�n
% de la se�al.
%
% En concreto, la funci�n sigue los siguientes pasos:
%
%   * Divisi�n de se�al en fragmentos enventanados a corto plazo.
%
%   * Separaci�n de cada ventana de se�al en coeficientes LPC y se�al
%     error.
%
%   * S�ntesis LPC para recuperar las tramas de audio a corto plazo, a
%     partir de la se�al de error y los coeficientes de los filtros LPC.
%
%   * Reconstruir la se�al de audio a partir de las ventanas a corto plazo.
%
% El c�digo est� pensado para codificar y decodificar audio wav PCM con 16
% bits por muestra y una frecuencia de muestreo de 44100 Hz.
%
% El c�digo est� convenientemente comentado para facilitar su uso por parte
% del estudiante
%
% AUTOR: Daniel Ramos Castro, a partir del c�digo de la Pr�ctica de TiCom
% de Alejandro Pe�a Almansa durante el curso 2018-19 (c�digo utilizado y
% publicado bajo consentimiento del autor).

% Par�metros de la codificaci�n LPC a corto plazo
% EL ESTUDIANTE PUEDE CAMBIARLOS A CONVENIENCIA SI LO CONSIDERA NECESARIO
duracion_trama = 0.02; % Duraci�n de una trama en segundos
solapamiento = 0; % Tanto por uno de solapamiento de ventanas
p = 15; % N�mero de coeficientes del filtro LPC

% Lectura del fichero de audio
% SE RECOMIENDA EXPLORAR LAS FUNCIONES DE AUDIO RELACIONADAS (audioplayer,
% play, etc.). Ver "doc audioplayer" para referencia en Matlab(TM)
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

% S�ntesis LPC y reconstrucci�n de la se�al de audio a partir de sus tramas
% a corto plazo
[outputSignal] = sintetiza_lpc_error(errores,coeficientes,solapamiento,tail,maxs); 

% Reproduce la se�la de audio
% sound(outputSignal,fs);

% Escribe audio a fichero WAV PCM
audiowrite('baselineAutputAudioFile.wav',outputSignal,fs); 

end

%%Funci�n para realizar el an�lisis LPC de corto plazo
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

%%Funci�n de enventanado de la se�al y compresi�n de rango
% ENTRADAS:
%   * signal: audio de entrada (seg�n se extrae del fichero wav).
%   * fs: frecuencia de muestreo del audio
%   * duracion_trama: duraci�n de la trama definida en el c�dec.
%   * Solapamiento define el solapamiento entre tramas.
% 
% SALIDAS:
%   * tramas: array de tramas, ocn tantas filas como muestras por
%      tramas, y tantas columnas como tramas.
%   * tailInf: tama�o de la �ltima ventana (podr�a ser menor que el tama�o
%      del resto de ventanas).
%   * maxs: m�ximo valor de la se�al de audio.
function [tramas,tailInf,maxs] = obtiene_tramas(signal, fs, duracion_trama,solapamiento)

%%Por defecto se aplicar� una ventana Hamming a las tramas
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
    % La siguiente l�nea plica una ley A de compresi�n, que favorece que se
    % d� m�s importancia a las partes de se�al m�s cercanas a cero.
    % Supuestamente favorece la compresi�n desde el punto de vista del
    % error de reconstrucci�n del audio al decodificar.
    tramas(:,i) = compand(trama,87.6,maxs,'a/compressor');
end;

tailInf = length(signal(nv*Desplazamiento+1:end));
if tailInf > ventana
    tailInf = ventana-1;
end;

tramas(1:tailInf,nv+1) = signal(nv*Desplazamiento+1:nv*Desplazamiento + tailInf);
tramas(:,nv + 1) = compand(tramas(:,nv + 1).*Window,87.6,maxs,'a/compressor');

end



%%S�ntesis de la se�al LPC
function [output_signal] = sintetiza_lpc_error(errores, coeficientes,solapamiento,tail,maxs)

[len_trama,n_trama,~] = size(errores);

if solapamiento == 0
    output_signal = zeros(1,len_trama*n_trama);

    for i = 1:n_trama
    
        trama_error = errores(:,i);
        a = coeficientes(:,i)';
    
        trama_recuperada = filter(1, [1 a], trama_error);
    
        % Aplica el inverso de la ley A de compresi�n
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
    output_signal = output_signal./1.08;%% Con un solapamiento bien hecho obtendremos la se�al original ponderada por 1.08 salvo el comienzo y el final
    
    output_signal(1:len_trama/2) = output_signal(1:len_trama/2).* inverseHammingWindow(1:len_trama/2)';
    output_signal(end-len_trama/2:end) = output_signal(end-len_trama/2:end).* inverseHammingWindow(end-len_trama/2:end)';
    
end;

output_signal(isnan(output_signal)==1) = 0;%% En ocasiones se producen NaN con el an�lisis LPC, lo dejamos en cero mejor
output_signal = output_signal(1:end-len_trama + tail);
end