%% P1: Demodulacion de una señal FSK binaria mediante la STFT

% Autor: Roberto Martín

% Cada uno de los caracteres ASCII se ha codificado con 8 bits/carácter para obtener 
% una secuencia de 0 y 1 que luego se ha modulado a una señal FSK mediante la asignación 
% de una frecuencia f0 para los ceros y otra f1 para los unos. Vamos a
% seguir los pasos del enunciado:

%Limpiamos
clc
clear

%% Lectura de la señal incógnita del archivo “incógnita.mat”.

load incognita.mat; 

%% Representación de la señal incógnita mediante la función spectrogram().

%El enunciado dice lo siguiente: Para ver la estructura del espectro conviene no cargar
%toda la señal, es decir, bastaría con cargar las primeras 500 muestras

signal = incognita(1:500);


% Ventana, especificada como un entero o como un vector de fila o columna. 
% Se utiliza para dividir la señal en segmentos:window. Si es un entero (como es en nuestro caso), 
% se divide en segmentos de longitud y ventanas de cada segmento con una ventana Hamming de esa longitud
% Esta ventana la calculamos a partir de Vbit [ periodo * frecuencia de muestreo(fs)]. 
% Transparencias Tema 4 DFT, página 15 ejemplo.

window = (1/Vbit)*fs;


% Número de muestras superpuestas, especificada como un entero positivo.
% Se recomienda no solapar las ventanas

noverlap = 0;


% Número de puntos DFT, especificado como un escalar entero positivo. 
% la longitud de las dft-s, sea igual o dos o tres veces mayor que la longitud de window.
% En nuestro caso lo hacemos por 3.

nfft = 3*window;


% El espectrograma de las 500 muestras de la señal 

figure('Name','Espectrograma 500 muestras','NumberTitle','off');
spectrogram(signal,window,noverlap,nfft,fs)


%% Obtener secuencia de ceros y unos

% Empezamos cambiando la señal. En vez de las muestras, cogemos la señal
% completa. Vector conteniendo la señal

signal = incognita; 


% El espectrograma de todas las muestras de la señal 

figure('Name','Espectrograma completo','NumberTitle','off');
spectrogram(signal,window,noverlap,nfft,fs);


% La ventana (window) va a ser la misma que la que usamos para las 500
% muestras. Se mantiene el valor.


% En vez de usar nfft para calcular la secuencia, es mucho mas sencillo hacer
% uso de f (cyclical frequencies). Cyclical frequencies, specified as a vector. 
% f must have at least two elements, because otherwise the function interprets 
% it as nfft. The units of f are specified by the sample rate, fs.
% Teniendo en cuenta que nuestras frecuencias son f0 (1250) y f1 (1850):

f = [f0,f1];

% w = [(2*pi*f0)/fs,(2*pi*f1)/fs];
% https://es.mathworks.com/matlabcentral/answers/265969-how-to-understand-spectrogram-function

% Con spectrogram se devuelve el espectrograma a las frecuencias cíclicas especificadas en f
% https://es.mathworks.com/help/releases/R2020b/signal/ref/spectrogram.html?lang=en&browser=F1help

[S,F,T] = spectrogram(signal,window,noverlap,f,fs);

%{

---- S: Short-time Fourier transform ----
Returned as a matrix. Time increases across the columns of s and frequency 
increases down the rows, starting from zero.

If x is a signal of length Nx, then s has k columns, where
    k = ⌊(Nx – noverlap)/(window – noverlap)⌋ if window is a scalar.
    k = ⌊(Nx – noverlap)/(length(window) – noverlap)⌋ if window is a vector.

If x is real and nfft is even, then s has (nfft/2 + 1) rows.

If x is real and nfft is odd, then s has (nfft + 1)/2 rows.

If x is complex, then s has nfft rows.


---- F: Cyclical frequencies ----
Cyclical frequencies, returned as a vector. 
f has a length equal to the number of rows of s.


---- T: Time instants ----
Time instants, returned as a vector. 
The time values in t correspond to the midpoint of each segment.

%}

% Ahora vamos a hacer uso de la función max
% https://es.mathworks.com/help/releases/R2020b/matlab/ref/max.html?lang=en&browser=F1help
% Del help hacemos uso del ejemplo "Largest Element Indices" el cual
% muestra como encontrar el maximo dos a dos en una matriz y utilizar el
% indice.

signalabs = abs(S);
[M,I] = max(signalabs);

% Ahora en I tenemos guardado el índice del valor maximo de la columna (que
% será 1 o 2 dependiendo si es f0 o f1)

% Sabiendo que tenemos un array con los indices 1 o 2, para conseguir la
% secuencia de 0 y 1 es tan sencillo como restarle uno.

secuencia= I - 1;

%% Obtener mensaje ASCII

% Para convertir la secuencia de 0 y 1 a un mensaje ASCII vamos a usar
% varias funciones que proporciona matlab.

% Primero vamos a convertir la secuencia de numeros que tenemos a String
% con num2str (Number to String), la cual: "Convierte números a array de
% caracteres" 

secuenciaString = num2str(secuencia);

% Lo siguiente que vamos a hacer es quitar los espacios que aparecen entre
% los 0s y los 1s. Para ello utilizamos strrep, la cual: "Find and 
% replace substrings" que en nuestro caso consiste en sustituir en
% secuenciaString el espacio por nada.

secuenciaString = strrep(secuenciaString,' ',''); 

% Del enunciado sacamos: "cada uno de los caracteres ASCII se ha
% codificado con 8 bits/carácter". Por lo tanto:

% El primer caracter ASCII empezará en el bit numero 1 y terminará en el bit
% numero 8:

first = 1; 
last = 8;

% La longitud del texto será la longitud de la secuencia de 0 y 1 dividido
% entre 8 (para saber cuantos caracteres hay):

num_caracteres = length(secuenciaString)/8;

% Ahora creamos con strings un "Square Array of Empty Strings" de 1x1 que
% servirá para almacenar el caracter en el que nos encontramos en el bucle:

letra = strings(1);

% Otra variable igual "texto", que guardará varias "letra":

texto = strings(1);


for i = 1:num_caracteres
    
    % Cogemos el primer paquete de ocho (desde first hasta last) que vamos
    % a convertir a caracter
    
    pack8 = secuenciaString(first:last);
    
    % Ahora tenemos que convertir esos 8 bits (binario) a decimal. Por
    % suerte, matlab nos da la solución. bin2dec (binary to decimal) 
    % convert text representation of binary integer to double value:
    
    num_decimal = bin2dec(pack8);
    
    % Una vez tenemos el numero decimal, solo falta convertir ese numero a
    % ASCII. Para ello, tenemos char. Del help hacemos uso del primer
    % ejemplo: Convertir una matriz numérica en una matriz de caracteres.
    % Los enteros de 32 a 127 corresponden a caracteres ASCII imprimibles.
        
    letra = char(num_decimal);
    
    % Ya tenemos la letra, solo queda unirla al texto completo, para ir
    % juntando todas las letras y formar el mensaje.
    
    texto = texto + letra;

    % Lo ultimo que queda es cambiar el valor de first y last para que
    % cojan el siguiente pack de 8
    
    first = first + 8;
    last = last + 8;
    
end

%mensaje = bin2txt(secuencia);
mensaje = texto;

fprintf('MENSAJE:\n\n');
fprintf(mensaje);
fprintf('\n\n');
        