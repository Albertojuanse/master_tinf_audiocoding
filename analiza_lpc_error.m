function [errores, coeficientes,tail,maxs] = analiza_lpc_error(signal, duracion_trama,solapamiento, p, fs)
%ANALIZA_LPC_ERROR Funci�n para realizar el an�lisis LPC de corto plazo

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