% print sample values from the DyadicHead database
ifn=input('Enter data file index in range [1,44] or else 100*dyad+conv: ');
if isempty(ifn)
    ifn=1;
end
[dd,dx,dyc,lab]=readdyh(ifn,'../data/'); % read the data file
dddx=[dd dx]; % concatenate all the fields
nt=size(dd,1);
fprintf('File-ver %d, Software-ver %d, Dyad %d, Conversation %d, Duration %d:%02d (%d samples)\n',dyc,floor(nt/6000), floor(mod(nt,6000)/100), nt);
ix=input('Enter sample number: ');
if isempty(ix)
    ix=1;
end
fprintf('List of field values\n');
for iv=1:38
    if isempty(lab{iv,2})
        fprintf('%2d %11.4g  %s\n',iv,dddx(ix,iv),lab{iv,1});
    else
        fprintf('%2d %11.4g  %s (%s)\n',iv,dddx(ix,iv),lab{iv,1},lab{iv,2});
    end
end
