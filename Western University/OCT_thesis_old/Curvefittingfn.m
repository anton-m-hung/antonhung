function Curvefittingfn(I,z)
    A=mean(I,2); dispfig4(z,A);  %Average image of the A-scan for reference
    figure;
    dispfig1(I)   %Image display
    [xrange,yrange]=ginput;   %Graphic range selector
    xrange=floor(xrange);
    yrange=floor(yrange);
    %Plotting the region selected with a red rectangle:
    hold on; plot([xrange(1) xrange(2)],[yrange(1) yrange(1)],'r','LineWidth',1.5); 
    hold on; plot([xrange(1) xrange(2)],[yrange(2) yrange(2)],'r','LineWidth',1.5); 
    hold on; plot([xrange(1) xrange(1)],[yrange(1) yrange(2)],'r','LineWidth',1.5); 
    hold on; plot([xrange(2) xrange(2)],[yrange(1) yrange(2)],'r','LineWidth',1.5); 
    mustorage=0;   %Arrays used for storing values
    stdstorage=0;
    %----index and block menu------%
    prompt = {'Enter index of refraction:','Number of blocks:'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'1.34','1'};
    uianswer=inputdlg(prompt,dlgtitle,dims,definput);
    n2=str2num(uianswer{1});   %Index or refraction. Change it or predefine it in order to avoid using the prompt
    n3=str2num(uianswer{2});   %Number of blocks inside the rectangle
    blocklength=floor((xrange(2)-xrange(1))/n3);
    %-----------Curve Fits-----------------%
    for i=1:n3
        signal=mean(I(:,floor(xrange(1))+blocklength*(i-1):floor(xrange(1))+blocklength*i),2); %A-scan averaged from the blocks
        [zw,yw,w,we,wr]=cf222(z,signal,0.000001,yrange); %Fitting the curve
        percent80=(yrange(2)-yrange(1))*0.20/2; %Getting the number of pixels needed for that 80% region of interest
        percent60=(yrange(2)-yrange(1))*0.40/2; %Getting the number of pixels needed for that 60% region of interest
        [~,~,w1,~,~]=cf222(z,signal,0.000001,[yrange(1)+percent80 yrange(2)-percent80]);
        [~,~,w2,~,~]=cf222(z,signal,0.000001,[yrange(1)+percent60 yrange(2)-percent60]);
        stdstorage(1,i)=std([w w1 w2]*n2/2);  %Standard deviation of the coefficients of 100% 80% and 60% of the region of inetrest
        mustorage(1,i)=w*n2/2;   mustorage(2,i)=we*n2/2;

    end
    dispfig2(z,signal); plot(zw,yw,'r--','Linewidth',2.5) %Display last A-scan along with its fitted curve
    figure (2)
    legend('OCT signal','Fitted Curve')
    title(['OCT A Scan (R^2: ',num2str(wr),')'])
    %Calculating the mean of the values from the fitted coefficients and their errors
    %factor multiplied here (1000)
    wmean=mean(mustorage(1,:,1),2)*1000;        wemean=mean(mustorage(2,:,1),2)*1000;
    %Calculating the standard error of the mean which accounts for using several A-scans
    R=(max(mustorage(1,:))-min(mustorage(1,:)))/(2*length(mustorage(1,:))^0.5);
    fprintf('----------A-scans: %d-------------\n',xrange(2)-xrange(1))
    fprintf('Model                 Value   FitError   AreaError   ROIError\n') 
    fprintf('Beer:                 %.3f +/- %.3f +/- %.3f +/- %.3f (mm^-1)\n',wmean,wemean,R,mean(stdstorage(1,:))) %mean of stdstorage is the mean in the error from using 100,80,60 percent of the region of interest
    fprintf('Total error (Beer): +/- %.3f  (mm^-1)\n',unc([wemean,R,mean(stdstorage(1,:))]))
    fprintf('\n')
       
end

