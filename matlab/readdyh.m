function [dd,dx,dyc,lab]=readdyh(fn,dir)
% Read the head and gaze movement data that was given in [1].
%
%  Inputs: fn        File name OR file number (1<=fn<=44) OR 100*dyad+conversation
%          dir       Base folder name containing the database (e.g. '../DyadicHead/')
%                    (optional if full file name is given in fn)
%
% Outputs: dd(:,21)  Raw data values (one row per 10 ms time frame)
%          dx(:,17)  Additional derived values that may be useful
%                    See list below for the data in each field in [dd dx]
%          dyc(1,4)  Gives the file-version, function-version, dyad and conversation numbers of the file 
%          lab{33,2} Variable names and units for the columns of [dd dx]
%
% Refs: [1] L. V. Hadley, W. O. Brimijoin, and W. M. Whitmer.
%           Speech, movement, and gaze behaviours during dyadic conversation in noise.
%           Scientific Reports, 9 (1), jul 2019. doi: 10.1038/s41598-019-46416-0.
%
% Talker-1    Talker-2    Quantity
% --------    --------    --------
%   ==   dd(:,1)  ==      Noise level (dB)
% dd(:,2)     dd(:,12)    Speech level (dB)
% dd(:,3)     dd(:,13)    Voice activity (0 or 1)
% dd(:,4:6)   dd(:,14:16) x,y,z position (metres)
% dd(:,7:9)   dd(:,17:19) yaw,pitch,roll of head (radians)
%                         (pi radians are added to yaw of talker 2 so its value is near zero)
% dd(:,10:11) dd(:,20:21) yaw,pitch of eye relative to head (radians)
%   ==   dx(:,1)  ==      Time stamp starting at 0 (sec)
%   ==   dx(:,2)  ==      Frame number starting at 1
%   ==   dx(:,3)  ==      Change in Noise level (dB)
%   ==   dx(:,4)  ==      Separation between talkers 1 & 2 at centre of head (metres)
%             dx(:,5:7)   x,y,z of talker-2 head centre relative to talker-1 (negate to swap 1<->2)
% dx(:,8:9)               yaw, pitch offset for talker-1 to make relative to centre of talker-2's head (negate pitch only to swap 1<->2)
% dx(:,10:11) dx(:,14:15) yaw, pitch of head relative to the centre of the other talker's head
% dx(:,12:13) dx(:,16:17) gaze direction relative to the centre of the other talker's head
%
% Mapping to fields in original text data files. Note that units have
% been changed from (degrees, millimetres) to (radians, metres).
% 1=dx(1), 2=dx(2), 3=dd(1), 4=dx(3) but with 0 instead of NaN,
% 5:7=dd(7:9), 8=dd(17)-pi, 9:10=dd(18:19), 11:13=dd(4:6), 14:16=dd(14:16), 17=dd(2),
% 18=dd(12), 19=dd(3), 20=dd(13), 21=dd(10), 22=dd(20), 23=dd(11), 24=dd(21), 25=dx(10),
% 26=dx(14), 27=dx(11), 28=dx(15), 29=dx(12), 30=dx(16), 31=dx(13), 32=dx(17), 33=dx(4)
%
% Setup and coordinate system.
% The setup is shown in Fig. 1 of [1] and consists of two seated talkers facing each other at a
% distance of 1.5 m; a ring of eight loudspeakers provided speech-shaped background noise. From the
% viewpoint of talker-1, the positive x axis is to the right, y ahead and z upwards; the coordinate
% origin is on the floor midway between the talkers. Head and gaze rotations are performed in the order yaw,
% pitch, roll using intrinsic coordinates that rotate with the head. A positive yaw turns to the right,
% a positive pitch tilts downwards and a positive roll tilts to the left. 
%
% File Format:
% The .dyh file consists of 21N+13 little-endian 16-bit integers where N is the number of frames.
% The 13-value header consists of the characters 'DyadicHead' followed by the File-format, Dyad and Conversation
% numbers. The 21 numbers in each 10 ms frame are the contents of the dd output matrix listed above.
persistent labx
if isempty(labx)
            labx={'noise-level','dB';
                't1-level','dB';'t1-vad','';'t1-xpos','m';'t1-ypos','m';'t1-zpos','m';'t1-head-y','rad';'t1-head-p','rad';'t1-head-r','rad';'t1-eye-y','rad';'t1-eye-p','rad';
                't2-level','dB';'t2-vad','';'t2-xpos','m';'t2-ypos','m';'t2-zpos','m';'t2-head-y','rad';'t2-head-p','rad';'t2-head-r','rad';'t2-eye-y','rad';'t2-eye-p','rad';
                'time','s';'frame-num','';'delta-noise','dB';'separation','m';'t2-x-rt1','m';'t2-y-rt1','m';'t2-z-rt1','m';
                't1-add-y-rt2','rad';'t1-add-p-rt2','rad';'t1-head-y-rt2','rad';'t1-head-p-rt2','rad';'t1-gaze-y-rt2','rad';'t1-gaze-p-rt2','rad';'t2-head-y-rt1','rad';'t2-head-p-rt1','rad';'t2-gaze-y-rt1','rad';'t2-gaze-p-rt1','rad'};
end
sver=1; % software version
if isnumeric(fn)
    if fn<100                               % file index specified (1<=fn<=44
        ico=mod(fn-(fn<6),3)+1;
        idy=floor((fn-(fn<6))/3)+1;
    else                                    % file index specified by dyad and conversation
        ico=mod(fn,10);
        idy=floor(fn/100);
    end
    fn=sprintf('dyad%02dconv%d.dyh',idy,ico);
end
if nargin>1
    fn=fullfile(dir,fn);                    % pre-append the parent folder name
end
fid=fopen(fn,'rb','l');                     % the file of shorts is binary little-endian
if fid<0
    error('cannot open input file');
end
dr=fread(fid,Inf,'int16');                  % read all the data
fclose(fid);
if ~strcmp(char(dr(1:10)'),'DyadicHead')    % first 10 values should always be 'DyadicHead'
    error('File does not begin with ''DyadicHead''');
end
dyc=[dr(11) sver dr(12) dr(13)];            % File-version, software-version, Dyad and Conversation numbers
dd=reshape(dr(14:end),21,[])';              % reshape into array with 21 columns
if nargout>1
    tydb=[1 2 12];                          % dB noise level
    typos=[4:6 14:16];                      % head position
    tyang=[7:9 17:19 10 20 11 21];          % head/eye angles   
    dd(:,tydb)=dd(:,tydb)*0.01;             % multiply by 0.01 to convert to dB
    dd(:,typos)=dd(:,typos)*0.0001;        	% convert to metres
    ddang=dd(:,tyang);                      % extract angle fields
    ddang(ddang==-32768)=NaN;            	% set NaN values (coded as -32768 in file)
    dd(:,tyang)=ddang*pi/18000;             % convert to radians
    nt=size(dd,1);                          % number of frames
    % create derived quantities
    dx=zeros(nt,17);
    x2rel=dd(:,14:16)-dd(:,4:6);
    dx(:,1:9)=[0.01*(0:nt-1)' (1:nt)' dd(:,1)-[0;dd(1:end-1,1)] sqrt(sum(x2rel.^2,2)) x2rel -atan2(x2rel(:,1),x2rel(:,2)) atan2(x2rel(:,3),sqrt(sum(x2rel(:,1:2).^2,2)))];
    dx(:,[10 11 14 15])=[dd(:,7:8)+dx(:,8:9) dd(:,17)+dx(:,8) dd(:,18)-dx(:,9)];
    dx(:,[12 13 16 17])=dd(:,[10 11 20 21])+dx(:,[10 11 14 15]);
    lab=labx;
end
