function CF_Attenuatedimage_map(I,z)
 figure(1)
          set(gcf,'Units','centimeters','Position',[1 1 12 17])
          imshow(I, []);
          title('Select a Range to apply CF:')
          axis on
          set(gca,'XTick',[0 100 200 300 400 500])
          set(gca,'XTickLabel',[0 1 2 3 4 5])
          set(gca,'YTick',[0 50 100 150 200 250 300 350 400 450 500])
          set(gca,'YTickLabel',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5])
          ylabel('Depth [mm]')
          xlabel('Transverse Length [mm]')  
          [~, rangey]=ginput;
          %I4=rangecutter2d(I,[rangey(1) rangey(2)])
          I4=[];
          for i=1:length(I)
              [~,Ia]=rangecutter(z,I,[rangey(1) rangey(2)]);
              I4(:,i)=Ia;
          end
          size1=size(I4);
          avg=zeros(size1(1),1);
          for i=1:length(size1(2))
              avg=avg+I4(:,i);
          end
          [zavg, ~]=rangecutter(z,I(:,1),[rangey(1) rangey(2)]);
          figure(5)
          plot(zavg/100,avg)
          set(gcf,'Units','centimeters','Position',[34 3 14 10])
          avg=avg/length(size(2));
          xlabel('Depth [mm]')
          ylabel('OCT Measurement')
          title('Averaged OCT A Scan')
          [rangex, rangey]=ginput;
          %u=cf(zavg/1000,avg,[rangex(1) rangex(2)]/10);% divide zavg/100 to account for my unit blunder and delete the /10 on the range matrix(pixel units to mm)
          %it would be run like this:  u=cf(zavg/100,avg,[rangex(1) rangex(2)]);
          u=cf(zavg/100,avg,[rangex(1) rangex(2)]);
          fprintf('Fitted coefficient: %.3f \n',u(1));
end

