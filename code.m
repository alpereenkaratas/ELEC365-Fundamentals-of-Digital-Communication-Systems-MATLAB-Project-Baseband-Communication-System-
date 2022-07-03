clc;
clear all;
close all;

N = 10^7; % Her bir SNR degeri icin gonderilen bit sayisi
Eb = 1; % Bit enerjisi Eb=1 olarak belirlendi
si = randsrc(1,N,[1,0;1/3,2/3]); % Alicinin girisindeki isaret
si_out = zeros(1,N); % Karar verici cikisindaki isaret
Ps1 = 1/3; % 1 biti olasiligi
Ps2 = 2/3; % 0 biti olasiligi
ai = si*2-1; % si 2 ile carpilip 1 cikarildiginda, si'nin 1 biti icin a1=1 ve si'nin 0 biti icin a2=-1 elde edilir (a1 ve a2 degerleri analitik olarak bulunmustu). 
a1 = 1; % analitik olarak bulunan a1 degeri
a2 = -1; % analitik olarak bulunan a2 degeri
Pb_sim_v = zeros(0,17); % Her bir simulasyon SNR degeri icin bit hata olasiliklarini barindiricak vektor
Pb_analytical_v = zeros(0,17); % Her bir analitik SNR degeri icin bit hata olasiliklarini barindiricak vektor

for db_SNR = 0:17
    
    SNR = 10^(db_SNR/10); % dB_SNR = 10logSNR oldugu bilindigine gore formul duzenlenir
    N0 = Eb/SNR; % SNR = Eb/N0'dan N0 cekilir
    
    % sigma0^2=(N0/4)*((A^2)T) formulu geregi, Eb=1 oldugu icin (A^2)T = 4
    % olur; buradan sigma0 = sqrt(N0) gelir
    sigma0 = sqrt(N0); 
    
    % Kanal gurultusu asagidaki gibi eklenir. randn fonksiyonu 0 ortalamali
    % 1 standart sapmali duzgun dagilim uretir. Dagilim uygun alfa
    % sabitiyle carpilirsa istenen dagilim elde edilir. Bu dagilimda istenen 
    % varyans=N0 oldugu icin randn fonksiyonu sigma0 ile carpilir.
    z = ai + sigma0*randn(1,N);
    
    % gamma0 = ((sigma0^2 / ((A^2)T/2))) * ln(Ps2/Ps1) + (a1+a2)/2sigma0^2
    % formulu geregi teorik olarak bulunan sonuclar formulde yerine
    % koyuldugunda gamma0 = (N0/2) * ln(Ps2/Ps1) bulunur.
    gamma0 = (N0/2)*log(Ps2/Ps1); % ln, matlabda log ile ifade edilir
    
    % Belirlenen gama degerine gore gurultu eklenmis isaretin karar devresi
    % cikisi icin asagidaki kontrol gerceklestirilir
    for i = 1:N
        if z(i) > gamma0
            si_out(i) = 1; % Orneklenmis isaret gamma0'dan buyukse 1 bitine karar verilir
        else
            si_out(i) = 0; % Orneklenmis isaret gamma0'dan kucukse 0 bitine karar verilir
        end
    end
              
    % Hangi bitlerin hatali karar verildigini bulmak icin si ve si_out
    % vektorleri karsilastirilir
    errors = si~=si_out;
    
    % Simulasyon ustunden hesaplanmis bit hata olasiligi
    Pb_sim = sum(errors)/N;
    % Her bir SNR degeri icin hesaplanan deger vektore ekleniyor
    Pb_sim_v = [Pb_sim_v Pb_sim];
    
    % Analitik olarak hesaplanmis bit hata olasiligi
    Pb_analytical = (1-qfunc((gamma0-a1)/sigma0))*Ps1 + (qfunc((gamma0-a2)/sigma0))*Ps2;
    % Her bir SNR degeri icin hesaplanan deger vektore ekleniyor
    Pb_analytical_v = [Pb_analytical_v Pb_analytical];
end

dB_SNR = 0:17;
figure()
semilogy(dB_SNR,Pb_sim_v,'bo-');
hold on;
semilogy(dB_SNR,Pb_analytical_v,'r*-');
hold on;
legend('sim', 'analytical')
grid on;
title('BER curve versus SNR - 1801022022');
xlabel('SNR(dB)');
ylabel('Pb');
ylim([10^-7, 10^0]);