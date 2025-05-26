clc

Fs = 44100;
fmax = Fs/2;

N = 200;
bands = {'bass',20,250;
    'MidRange',250,2000;
    'Treble',2000,6000;
    'Presence',6000,12000;
    'Brilliance',12000,20000;};

% to store the values
filters = struct();

figure;
hold on;

title(' filter response of paramteric eq bands');

for i=1:size(bands,1)
    bandName = bands{i,1};
    f1=bands{i,2}; 
    f2= bands{i,3};

    % normalise freq
    Wn=[f1 f2]/fmax;

    %bandpass filter with hamming window
    b=fir1(N,Wn,"bandpass",hamming(N+1));
    filters.(bandName)=b;

    [h,w]= freqz(b,1,1024,Fs);
    plot(w,20*log10(abs(h)),'DisplayName',bandName);

end

xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;
legend show;

[x,Fs]= audioread('audio_f1.wav');
x=x(:,1);

gains = struct('bass',1.8,'MidRange',0.7,'Treble',0,'Presence',1,'Brilliance',0.5);

y= zeros(size(x));

bandNames =fieldnames(filters);

for i=1:length(bandNames)
name = bandNames{i};
b= filters.(name);
bandsignal = filter(b,1,x);
y = y+gains.(name)*bandsignal;
end

y= y/(max(abs(y)));
sound(y,Fs);

audiowrite('filterd_audio.wav',y,Fs);
