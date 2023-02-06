function AdaptedDR_Attenuatedimage_map(I,row,column,pxlLength_mm)
figure(5)
        set(gcf,'Units','centimeters','Position',[34 3 14 10])
        Mtop=zeros(size(I));
        Mbot=Mtop;
        for j=1:column
            Mtop(:,j)=mask2top(I(j,:),pxlLength_mm,0.09);
        end
        for j=1:column
            Mbot(:,j)=mask2bot(I(j,:),pxlLength_mm,0.09);
        end
        mu_matrix=zeros(length(I)-1,length(I));
        for i=1:length(I)
            in=find(I(:,i).*Mbot(:,i)~=0);
            [~,mu_matrix(in(1):in(end-12),i)]=vermeer2u(z/100,I(in(1):in(end-11),i),0.7);
        end
        ac_grapher(mu_matrix.*Mtop(1:end-1,:),I,5,5,1)
        save('Workspace_ScatteringMatrix')
end

