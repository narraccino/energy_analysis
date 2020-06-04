%*************************************************************************
%                          Analisi Energetica                            * 
%*************************************************************************

clear;
clc;
path_rilev='Rilevazioni/';
path_risult='Risultati Analisi Energetica/';

%Inserisco il nome della versione del Firmware
prompt = 'Inserisci versione Firmware (SW, HW o HYB) --> ';
str1 = input(prompt, 's')
str1=  upper(str1);

%Specifico il livello di sicurezza
prompt = 'Inserisci LIVELLO (1-7) --> ';
str2 = input(prompt, 's')
level= str2double(str2);

prompt = 'Inserisci M (millisecondi) --> ';
millisec_str = input(prompt, 's')
millisec= str2double(millisec_str);
interval_c= ((millisec/1000)*10)/2500;


path_risult= strcat(path_risult,str1,'-',str2,'/');
nomecartella= strcat(str1,'-',str2);
mkdir(path_risult);


%Carico i valori dei tempi ti4,ti5,ti6,ti9 e slotDuration di tutti i
%livelli e li inserisco in una matrice
fileTempi= strcat(path_rilev,'Tempi.xlsx');
tabella = xlsread(fileTempi);

%Estraggo, in base al nome della versione i valori in TICKS dei tempi
if isequal(str1,'HW')
    valoriticks = tabella(1:7,1:5);
    ti4= valoriticks(level, 1);
    ti5= valoriticks(level, 2);
    ti8= valoriticks(level,3);
    ti9= valoriticks(level, 4);
    slotDuration = valoriticks(level, 5); 
elseif isequal(str1,'HYB')
    valoriticks = tabella(8:14,1:5);
    ti4= valoriticks(level, 1);
    ti5= valoriticks(level, 2);
    ti8= valoriticks(level, 3);
    ti9= valoriticks(level, 4);
    slotDuration = valoriticks(level, 5);
elseif isequal(str1,'SW')
    valoriticks = tabella(15:22,1:5);
    level= level+1;
    ti4= valoriticks(level, 1);
    ti5= valoriticks(level, 2);
    ti8= valoriticks(level, 3);
    ti9= valoriticks(level, 4);
    slotDuration = valoriticks(level, 5);
else
    disp('+ + + + ERRORE + + + +')
end

% carico in una matrice output i valori dei tempi e delle ampiezze rilevate
% dall'oscilloscopio
str = strcat(path_rilev, str1,'-',str2,'.csv');
[output,header] = caricaCSV(str);

tempi=0:interval_c:((interval_c*2500)-interval_c);
output(:,1) = transpose(tempi);
plot(output(:,1),output(:,2))
xlabel('sec')
ylabel('A')


disp('Scegli il picco di TX');
%Dopo aver estratto il valore di ti4, continuo e clicco su SI
while(1)

choice = menu('Procedo nel calcolo?','Si','No');
if choice==1 || choice==0
   break;
end
end

%Estraggo il valore di riga del valore che è contenuto in output
rowEndti4 = ;

%Calcolo il numero di righe della durata di ti4
rowti4 = fix((ti4/32768)/interval_c);
%Calcolo il numero di righe della durata di slotDuration
rowSlotDuration = fix((slotDuration/32768)/interval_c);
%Calcolo il numero di riga di inizio dello slot
rowStart = rowEndti4 - rowti4;
%Calcolo il numero di riga di fine dello slot
rowEnd = rowStart + rowSlotDuration;

%Estraggo l'Array delle ampiezze dello slot
amplitudeArray = output(rowStart:rowEnd, 2);

%Preparo le variabili necessarie per il calcolo dell'integrale
stopTrapzTime= (numel(amplitudeArray)-1)*interval_c;
timeArray= transpose( 0:interval_c:stopTrapzTime);

%Calcolo il valore in mJ dell'energia consumata durante lo slot
mJ= trapz(timeArray, amplitudeArray)*2.4*1000;

sprintf('Valore energia  (milliJOULE) =  %f', mJ)
h=figure;
plot(timeArray,amplitudeArray)
xlabel('sec')
ylabel('A')



%Salvo l'immagine jpeg del plot
nomeImmagineFile=strcat(path_risult,'Slot-',str1,'-',str2,'.jpeg');
saveas(h,nomeImmagineFile,'jpg')

%Salvo in formato xls l'array delle ampiezze
nomeArrayFile= strcat(path_risult,'AmplitudeArray-', str1,'-',str2,'.csv');
csvwrite(nomeArrayFile, amplitudeArray);

%Estraggo l'array delle ampiezze della fase Sleep che precede
% la trasmissione del pacchetto
amplitudeArray_1 = output(rowStart:rowEndti4,2);

% Salvo il plot in una immagine jpeg
h=figure;
lunghezza=(numel(amplitudeArray_1)-1)*interval_c;
tempi = 0:interval_c:lunghezza;
plot(tempi',amplitudeArray_1)
title('Sleep PRE-Radio')
xlabel('sec')
ylabel('A')
fileImmagine= strcat(path_risult,'1.Sleep PRE-RADIO.jpeg');
saveas(h,fileImmagine,'jpg')


%Calcolo il numero di righe della durata di ti5
rowti5 = fix((ti5/32768)/interval_c);
%Calcolo l'indice di riga dove si trova ti5
rowEndti5 = rowStart + rowti5;
%Estraggo l'array delle ampiezze della fase TX
amplitudeArray_2 = output((rowEndti4+1):rowEndti5,2);
%Salvo l'immagine jpeg del plot
h=figure;
lunghezza=(numel(amplitudeArray_2)-1)*interval_c;
tempi = 0:interval_c:lunghezza;
plot(tempi',amplitudeArray_2)
title('TX')
xlabel('sec')
ylabel('A')
fileImmagine= strcat(path_risult,'2.TX.jpeg');
saveas(h,fileImmagine,'jpg')



%Calcolo il numero di righe della durata di ti8
rowti8 = fix((ti8/32768)/interval_c);
%Calcolo il numero di riga di fine dell'array CPU
rowEndti8 = rowStart + rowti8;
%Estraggo l'array delle ampiezze della fase CPU
amplitudeArray_3 = output((rowEndti5+1):rowEndti8,2);
%Salvo l'immagine jpeg del plot
h=figure;
lunghezza=(numel(amplitudeArray_3)-1)*interval_c;
tempi = 0:interval_c:lunghezza;
plot(tempi',amplitudeArray_3)
title('CPU')
xlabel('sec')
ylabel('A')
fileImmagine= strcat(path_risult,'3.CPU.jpeg');
saveas(h,fileImmagine,'jpg')


%Calcolo il numero di righe della durata di ti9
rowti9 = fix((ti9/32768)/interval_c);
%Calcolo il numero di riga di fine dell'array RX
rowEndti9 = rowStart + rowti9;
%Estraggo l'array delle ampiezze della fase RX
amplitudeArray_4 = output((rowEndti8+1):rowEndti9,2);
%Salvo l'immagine jpeg del plot
h=figure;
lunghezza=(numel(amplitudeArray_4)-1)*interval_c;
tempi = 0:interval_c:lunghezza;
plot(tempi',amplitudeArray_4)
title('RX')
xlabel('sec')
ylabel('A')
fileImmagine= strcat(path_risult,'4.RX.jpeg');
saveas(h,fileImmagine,'jpg')


%Estraggo l'array delle ampiezze della sleep post RX
amplitudeArray_5 = output((rowEndti9+1):rowEnd,2);
%Salvo l'immagine jpeg del plot
h=figure;
lunghezza=(numel(amplitudeArray_5)-1)*interval_c;
tempi = 0:interval_c:lunghezza;
plot(tempi',amplitudeArray_5)
title('Sleep POST-Radio')
xlabel('sec')
ylabel('A')
fileImmagine= strcat(path_risult,'5.Sleep POST-Radio.jpeg');
saveas(h,fileImmagine,'jpg')


% Salvo le varie fasi in un file formato csv
stringexcel = strcat(path_risult,str1,'-',str2,'-SLEEP.csv');
csvwrite(stringexcel, amplitudeArray_1);
stringexcel = strcat(path_risult,str1,'-',str2,'-TX.csv');
csvwrite(stringexcel, amplitudeArray_2);
stringexcel = strcat(path_risult,str1,'-',str2,'-CPU.csv');
csvwrite(stringexcel, amplitudeArray_3);
stringexcel = strcat(path_risult,str1,'-',str2,'-RX.csv');
csvwrite(stringexcel, amplitudeArray_4);
stringexcel = strcat(path_risult,str1,'-',str2,'-SLEEP-POST_RX.csv');
csvwrite(stringexcel, amplitudeArray_5);


while(1)

choice = menu('Vuoi filtrare il segnale?','Si','No');
if choice==1 || choice==0
   break;
end
end

fileVMedi= strcat(path_rilev,'Valori medi.xlsx');
valoriMedi = xlsread(fileVMedi);

if isequal(str1,'HW')
    SLEEP=valoriMedi(1,1);
    TX= valoriMedi(1,2);
    CPU= valoriMedi(1,3);
    RX= valoriMedi(1,4);  
elseif isequal(str1,'HYB')
    SLEEP=valoriMedi(2,1);
    TX= valoriMedi(2,2);
    CPU= valoriMedi(2,3);
    RX= valoriMedi(2,4);  
elseif isequal(str1,'SW')
    SLEEP=valoriMedi(3,1);
    TX= valoriMedi(3,2);
    CPU= valoriMedi(3,3);
    RX= valoriMedi(3,4);  
else
    disp('+ + + + ERRORE + + + +')
end

%Costruisco il nuovo array dei valori di ampiezza
amplitudeArray_filtered(1:rowti4)= SLEEP;
amplitudeArray_filtered((rowti4+1):rowti5)= TX;
amplitudeArray_filtered((rowti5+1):rowti8)= CPU;
amplitudeArray_filtered((rowti8+1):rowti9)= RX;
amplitudeArray_filtered((rowti9+1):numel(amplitudeArray))= 0;
amplitudeArray_filtered=transpose(amplitudeArray_filtered);

%Calcolo dell'energia con segnale filtrato
mJ_new= trapz(timeArray, amplitudeArray_filtered)*2.4*1000;

sprintf('Valore energia del segnale filtrato (milliJOULE) =  %f', mJ_new)


%Salvo in una immagine il segnale filtrato
h= figure;
title('Signal filtered')
plot(timeArray,amplitudeArray_filtered)
nomeImmagineFiltrata= strcat(path_risult,'Signal Filtered-',str1,'-',str2,'jpeg');
xlabel('sec')
ylabel('A')
saveas(h,nomeImmagineFiltrata,'jpg');

