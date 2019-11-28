function [tramas,tailInf,maxs] = obtiene_tramas(signal, fs, duracion_trama,solapamiento)
%OBTIENE_TRAMAS Funci�n de enventanado de la se�al y compresi�n de rango
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