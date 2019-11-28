function [output_signal] = sintetiza_lpc_error(errores, coeficientes,solapamiento,tail,maxs)

%SINTETIZA_LPC_ERROR Synthesis of LPC signal
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