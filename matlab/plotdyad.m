% plot sample values from the DyadicHead database (requires Voicebox)
close all;
ifn=input('Enter data file index in range [1,44] or else 100*dyad+conv (default = 1): ');
if isempty(ifn)
    ifn=1;
end
[dd,dx,dyc,lab]=readdyh(ifn,'../data/'); % read the data file
fns=sprintf('dyad%02dconv%d.dyh',dyc(3:4));
dddx=[dd dx]; % concatenate all the fields
nt=size(dd,1);
fprintf('File-ver %d, Software-ver %d, Dyad %d, Conversation %d, Duration %d:%02d (%d samples = %.1f sec)\n',dyc,floor(nt/6000), floor(mod(nt,6000)/100), nt, nt/100);
ix=input('Enter range of samples e.g. [100 200] (default = all): ');
if isempty(ix)
    ix=[1 nt];
end
dddx=dddx(ix(1):ix(2),:); % extract the required time range
iv=input('Enter list of variables e.g. [4:6 14:16] (default = all): ');
if isempty(iv)
    iv=[1:21 24:38];
end
ip=input('Enter plot folder e.g. ''./figs'' (default = none): ');
% fprintf('List of field values\n');
% for iv=1:38
%     if isempty(lab{iv,2})
%         fprintf('%2d %11.4g  %s\n',iv,dddx(ix,iv),lab{iv,1});
%     else
%         fprintf('%2d %11.4g  %s (%s)\n',iv,dddx(ix,iv),lab{iv,1},lab{iv,2});
%     end
% end
nms=zeros(3,38); % #NaN, mean, std
for i=iv
    figure(i);
    msk=~isnan(dddx(:,i));
    tabmi=mean(dddx(msk,i));
    tabsi=std(dddx(msk,i));
    nms(:,i)=[sum(~msk);tabmi;tabsi];
    plot(dddx([1 end],22),tabmi*[1 1],'-r',dddx([1 end],22),tabmi*[1 1;1 1]+tabsi*[-1 1;-1 1],'--r',dddx(:,22),dddx(:,i),'-b');
    xlabel('Time(s)');
    if isempty(lab{i,2})
        ylabel(sprintf('%s',lab{i,1}));
    else
        ylabel(sprintf('%s (%s)',lab{i,1},lab{i,2}));
    end
    hi=sprintf('%s-%d',fns,i);
    title(hi);
    v_axisenlarge([-1 -1.05]);
    if nms(1,i)>0
        tx=sprintf('\\mu=%.3g,\\sigma=%.3g (%d NaN)',nms([2 3 1],i));
    else
        tx=sprintf('\\mu=%.3g,\\sigma=%.3g',nms([2 3],i));
    end
    v_texthvc(0.05,0.05,tx,'LBk');
    if ~isempty(ip)
        figbolden;
        v_fig2emf(fullfile(ip,sprintf('%s-%d',fns(1:end-4),i))); % this line will save the figure
    end 
end
v_tilefigs; % tile the plots