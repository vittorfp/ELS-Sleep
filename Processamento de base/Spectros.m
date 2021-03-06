%% Calcula spectro de frequencia dos dados (costuma demorar bastante)
%[41:44 47:50 52 54:60 41:44 47:50 52 54:60] 

folder = '/home/vittorfp/data/';
folder2 = sprintf('%skhz/',folder);
folder3 = sprintf('%slight/',folder);

tamanho_epoca = 5;%(segundos)
for rat_num = [41:44 47:50 52 54:60 ] 
   for slice_num = 1:4
	   
        srate=1000;
        WINDOW=10;  
        NOVERLAP=5;
		
		file = sprintf('%sR%dHIPO%d_1khz.mat',folder2,rat_num,slice_num);
        disp('Processando LFP:');
		disp(file);
		
        load(file, 'HIPO_1khz');
		n_epocas = floor(length(HIPO_1khz)/(tamanho_epoca*srate) ) - 1;
		
        utreshold =  mean(HIPO_1khz) + (4*std(HIPO_1khz)); 
        ltreshold =  -utreshold;
        
		A = find(HIPO_1khz > utreshold | HIPO_1khz < ltreshold);
		eA = ceil( A/(tamanho_epoca*srate) );
        eA = unique(eA);
		for i = eA'
			range = 1 + (i - 1) * tamanho_epoca*srate:tamanho_epoca*srate;
			h(range) = 0;
		end
		
        [S,F,T,P] = spectrogram(HIPO_1khz,WINDOW*srate,NOVERLAP*srate,[],srate);
        %A1 = floor( A ./ ( length(HIPO_1khz)/length(T) ) );
		
        clear HIPO_1khz
        %save(sprintf('%sR%d_%d_spectrogram.mat',folder3, rat_num,slice_num ),'S','F','T','P');

        clear S T  
		
		file = sprintf('%sR%dMIO%d_1khz.mat',folder2,rat_num,slice_num);
        disp('Processando MIO:');	
		disp(file);
        load( file, 'MIO_1khz');
        
		%Calcula o envelope do EMG, isso faz com que o dado seja mais suave
        y = hilbert(MIO_1khz);
        MIO_1khz = abs(y);
        clear y

        [S2,F2,T2,P2] = spectrogram(MIO_1khz,WINDOW*srate,NOVERLAP*srate,[],srate); 
		
        utreshold =  mean(MIO_1khz) + (3*std(MIO_1khz)); %Definido empiricamente
        ltreshold =  -utreshold; %Definido empiricamente
        A = find(MIO_1khz > utreshold | MIO_1khz < ltreshold);
        
		%A2 = floor( A ./ ( length(MIO_1khz)/length(T2) ) );
        %A = [A1' A2'];
		
		eA2 = ceil( A/(tamanho_epoca*srate) );
        eA2 = unique(eA2);
		for i = eA2'
			range = 1 + (i - 1) * tamanho_epoca*srate:i*tamanho_epoca*srate;
			h(range) = 0;
		end
		
        clear MIO_1khz A1 A2
        %save(sprintf('%sR%d_%d_spectrogram.mat',folder3, rat_num,slice_num ),'S2','F2','T2','P2','-append');
        clear S2 T2 A utreshold ltreshold Aq A2

        clear srate WINDOW NOVERLAP

        
        %Faz a suavização dos dados filtrados, aplicando uma media de 6 epocas

        %load( sprintf('%sR%d_%d_spectrogram.mat',folder3, rat_num,slice_num ), 'F','F2','P','P2','A');
        
		disp('Somando as bandas');
		
		
        banda_theta = find(F >5 & F < 12 );
        banda_delta = find(F >1 & F < 4);
        banda_gamma = find(F >33 & F < 55);
        banda_emg = find(F2 > 300 & F2 < 500);
		
        Emg   = sum( P2(banda_emg , : ) );
        Theta = sum( P(banda_theta, : ) );
        Delta = sum( P(banda_delta, : ) );
        Gamma = sum( P(banda_gamma, : ) );

		clear P P2 F F2
		
		Emg(eA) = 0;
		Theta(eA) = 0;
		Delta(eA) = 0;
		Gamma(eA) = 0;
		
        Theta_s = [];
        Delta_s = [];
        Gamma_s = [];
        Emg_s = [];

		epocas_media = 6;
        c = length(Delta)-epocas_media;
		
        for i = epocas_media+1:c

            y = i-epocas_media;
            z = i+epocas_media;

            Theta_s = [Theta_s mean( Theta(y:z) ) ];
            Delta_s = [Delta_s mean( Delta(y:z) ) ];
            Gamma_s = [Gamma_s mean( Gamma(y:z) ) ];
            Emg_s   = [Emg_s   mean(  Emg(y:z)  ) ];

        end

        %save('spectrogram.mat','Delta','Theta','Gamma','Delta_s','Theta_s','Gamma_s');
		file = sprintf('%sR%d_%d_spectrogram.mat',folder3, rat_num , slice_num );
		disp('Salvando em:');
		disp(file);
        save(file,'Delta_s','Theta_s','Gamma_s','Emg_s','Delta','Theta','Gamma','Emg','-append');
        clear i z y c A S F P S2 F2 P2 banda_gamma banda_emg banda_delta banda_theta Emg Emg_s Gamma Gamma_s Delta Delta_s Theta Theta_s

        
   end
end

%% Versão que esta no server

folder = '/home/vittorfp/data/';
folder2 = sprintf('%skhz/',folder);
folder3 = sprintf('%sspectrograms/light/',folder2);

for i = [41:44 47:50 52 54:59] 
        rat_num = i;

   for j = 1:4
        srate=1000;
        WINDOW=10;  
        NOVERLAP=5;

        slice_num = j;
        disp(sprintf('Rato %d - %d',rat_num,slice_num) );
        disp('Processando LFP ...');
        load( sprintf('%sR%dHIPO%d_1khz.mat',folder2,rat_num,slice_num), 'HIPO_1khz');

        utreshold =  1.5; %Definido empiricamente
        ltreshold =  -1.5; %Definido empiricamente
        A = find(HIPO_1khz > utreshold | HIPO_1khz < ltreshold);

        [S,F,T,P] = spectrogram(HIPO_1khz,WINDOW*srate,NOVERLAP*srate,[],srate);
        A1 = floor( A ./ ( length(HIPO_1khz)/length(T) ) );
        clear HIPO_1khz
        %save(sprintf('%sR%d_%d_spectrogram.mat',folder3, rat_num,slice_num ),'S','F','T','P');

        clear S  T  
        disp('Processando o miograma ...');
        load( sprintf('%sR%dMIO%d_1khz.mat',folder2,rat_num,slice_num), 'MIO_1khz');

		%Calcula o envelope do EMG, isso faz com que o dado seja mais suave
        y = hilbert(MIO_1khz);
        MIO_1khz = abs(y);
        clear y

        [S2,F2,T2,P2] = spectrogram(MIO_1khz,WINDOW*srate,NOVERLAP*srate,[],srate); 

        utreshold =  1.5; %Definido empiricamente
        ltreshold =  -1.5; %Definido empiricamente
        A = find(MIO_1khz > utreshold | MIO_1khz < ltreshold);
        A2 = floor( A ./ ( length(MIO_1khz)/length(T2) ) );
        A = [A1' A2'];

        clear MIO_1khz A1 A2
        %save(sprintf('%sR%d_%d_spectrogram.mat',folder3, rat_num,slice_num ),'S2','F2','T2','P2','A','-append');
        clear S2  T2   utreshold ltreshold Aq A2

        clear srate WINDOW NOVERLAP

        % %%

		        %Faz a suavização dos dados filtrados, aplicando uma media de 6 epocas

        %load( sprintf('%sR%d_%d_spectrogram.mat',folder3, rat_num,slice_num ), 'F','F2','P','P2','A');

        banda_theta = find(F >5 & F < 12 );
        banda_delta = find(F >1 & F < 4);
        banda_gamma = find(F >33 & F < 55);
        banda_emg = find(F2 > 300 & F2 < 500);

        P(banda_theta,A) = NaN;
        P(banda_delta,A) = NaN;
        P(banda_gamma,A) = NaN;
        P(banda_emg , A) = NaN;
 %Emg   = sum( P2(banda_emg , : ) , 'includenan');
        %Theta = sum( P(banda_theta, : ) , 'includenan');
        %Delta = sum( P(banda_delta, : ) , 'includenan');
        %Gamma = sum( P(banda_gamma, : ) , 'includenan');
        Emg   = nansum( P2(banda_emg , : ) );
        Theta = nansum( P(banda_theta, : ) );
        Delta = nansum( P(banda_delta, : ) );
        Gamma = nansum( P(banda_gamma, : ) );
        clear P P2 F F2

        Theta_s = [];
        Delta_s = [];
        Gamma_s = [];
        Emg_s = [];

        c = length(Delta)-3;
        for w = 4:c

            y = w-3;
            z = w+3;

            Theta_s = [Theta_s nanmean( Theta(y:z) ) ];
            Delta_s = [Delta_s nanmean( Delta(y:z) ) ];
            Gamma_s = [Gamma_s nanmean( Gamma(y:z) ) ];
            Emg_s   = [Emg_s   nanmean(  Emg(y:z)  ) ];

        end

        %save('spectrogram.mat','Delta','Theta','Gamma','Delta_s','Theta_s','Gamma_s');
        save(sprintf('%sR%d_%d_spectrogram.mat',folder3, rat_num,slice_num ),'Delta_s','Theta_s','Gamma_s','Emg_s','Delta','Theta','Gamma','Em$
        clear i z y c A S F P S2 F2 P2 banda_gamma banda_emg banda_delta banda_theta Emg Emg_s Gamma Gamma_s Delta Delta_s Theta Theta_s


   end
end

