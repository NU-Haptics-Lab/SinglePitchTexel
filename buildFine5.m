function [output,pitchlog,phaselog] = buildFine5(texelnum,texellength,pitchcurve,irregcurve,plots,quantization)

%Quantization=0 indicates no quantization

    t=1:texellength;
    output = [];
    phase=rand()*2*pi(); % Seed phase with a random number
    for i=1:texelnum
        pd=makedist('Normal',log10(pitchcurve(i)),irregcurve(i));
        pull=random(pd);
        if (quantization>0)
            pull=quantization*round(pull/quantization);
        end
        pitchlog(i)=10^pull;
        pitch=(10^pull)*.0053;
        if (i>1)
            phase=2*pi()*pitchlog(i-1)*.0053*texellength+phase;
        end
        phaselog(i)=phase;
        output = [output sin(2*pi()*pitch*t+phase)];
    end
if (plots)
figure(10)
clf
subplot(5,1,1)
    plot(linspace(0,length(output)*.0053,length(output)),(output+1)/2);
    xlim([0 .0053*length(output)]);
    xlabel('Position [mm]');
    ylabel('Friction Reduction Amplitude');
    title('Scaled Texture');
subplot(5,1,2)
    x=linspace(-1,2,1000);
    y=pdf(pd,x);
    plot(x,y);
    xlim([-1 2]);
    xlabel('10^{Pitch} [cycles/mm]');
    ylabel('Distribution Amplitude');
    hold on
    yyaxis right
    ylabel('Texel Count');
    histogram(log10(pitchlog),50);
    hold off
    title('Pitch Distribution / Histogram (Log Scale)')
subplot(5,1,4)
    x1=linspace(0,20,1000);
    x=log10(x1);
    y=pdf(pd,x);
    plot(x1,y)
    hold on
    yyaxis right
    histogram(pitchlog,50);
    xlabel('Pitch [cycles/mm])')
    ylabel('Texel Count')
    xlim([0 20])
    title('Pitch Distribution / Histogram (Linear Scale)')
subplot(5,1,3)
    for i=1:length(output)
        freqs(i)=(i-1)*1/(length(output)*.0053);
    end
    semilogx(freqs,abs(fft(output)));
    xlim([.1 100]);
    xlabel('Pitch [cycles/mm]');
    ylabel('FFT Magnitude');
    title('Texture Spectrum Magnitude (Log Scale)');
subplot(5,1,5)
    for i=1:length(output)
        freqs(i)=(i-1)*1/(length(output)*.0053);
    end
    plot(freqs,abs(fft(output)));
    xlim([0 20]);
    xlabel('Pitch [cycles/mm]');
    ylabel('FFT Magnitude');
    title('Texture Spectrum Magnitude (Linear Scale)');    
end
end