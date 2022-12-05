% This script reads the raw text data files for the DyadicHead database and
% writes out the binary files.
%
% Mike Brookes, Jan 2020
%
% File Format:
% The .dyh file consists of 21N+13 little-endian 16-bit integers where N is the number of frames.
% The 13-value header consists of the characters 'DyadicHead' followed by the File-format, Dyad and Conversation
% numbers. The 21 numbers in each 10 ms frame are the contents of the dd output matrix listed above.
fver=1; % file format version
for idy=1:15
    for icon=1:3
        if ~(idy==2 && icon==3) % one conversation is mising
            bfn=sprintf('dyad%dconv%d',idy,icon);
            bfn2=sprintf('dyad%02dconv%d',idy,icon);
            fn=['../raw/' bfn '.txt'];
            tab=table2array(readtable(fn));
            [nt,nv]=size(tab); % number of header lines
            dd=zeros(nt,21); % space for output data
            tydb=[3 17 18;1 2 12]; % dB noise level
            tyvad=[19 20;3 13]; % VAD
            typos=[11:16;4:6 14:16]; % head position
            tyang=[5:10 21:24; 7:9 17:19 10 20 11 21]; % head/eye angles
            dd(:,tydb(2,:))=round(tab(:,tydb(1,:))*100); % units of 0.01 dB
            dd(:,tyvad(2,:))=round(tab(:,tyvad(1,:))); % VAD values are 0 or 1
            dd(:,typos(2,:))=round(tab(:,typos(1,:))*10); % units of 0.1 mm
            ddang=round(tab(:,tyang(1,:))*100); % units of 0.01 degree
            ddang(:,4)=ddang(:,4)+18000; % add 180 degrees to talker2 yaw to make it close to zero
            ddang=mod(ddang+18000,36000)-18000; % force in range +-18000
            ddang(isnan(ddang))=-32768; % special value corresponding to NaN
            dd(:,tyang(2,:))=ddang;
            if any(dd(:)>32767 | dd(:)<-32768)
                error('value outside range of short');
            end
            fid=fopen(['../data/' bfn2 '.dyh'],'wb','l'); % always binary little-endian
            if fid<0
                error('cannot open output file');
            end
            hdr=['DyadicHead' fver idy icon];
            cnt=fwrite(fid,hdr,'int16');
            if cnt~=13
                error('did not write all header');
            end
            cnt=fwrite(fid,dd','int16');
            if cnt~=length(dd(:))
                error('did not write all data');
            end
            fclose(fid);
        end
    end
end
