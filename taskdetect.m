function [curtasktype, ecodecueon, ecodesacstart, ecodesacend]=taskdetect(codes, curtasktype);

% identifies task, and also tells which ecodes correspond to which event
% called by rex_process_inGUI and by data_info

if nargin<2
    curtasktype=[];
end

global tasktype;

ecodecueon=[];
ecodesacstart=[];
ecodesacend=[];

if size(codes,2)==1
    codes=codes';
end

if iscell(curtasktype)
    curtasktype=cell2mat(curtasktype);
end

alltasktypes={'vg_saccades','base2rem50','memguided','st_saccades','gapstop','gapsac','delayedsac','optiloc','tokens'};
%fsttlecode=floor(allcodes(1,2)/10)*10;
if size(codes,1)>1 %for a full file of ecodes
    ecodetypes=unique(floor(codes(:,2)/10)*10); %gives away the different ecode if mixed task
else %if called during a trial, there's only one line
    ecodetypes=floor(codes(2)/10)*10;
end
if ~sum(curtasktype) || strcmp(curtasktype,'Task') %then find task!
    if ecodetypes(1)==6010 % Visually guided saccades task type, including 'amp', 'dir' and 'optiloc'
        curtasktype=alltasktypes(1);
    elseif ecodetypes(1)==6020
        %make sure this is consistent over older recordings
        % default memory guided saccade is the self-timed saccade, but check if it is correct
        if isempty(find(codes==16386))
            if length(ecodetypes)>1 && find(ecodetypes==6040) && find(ecodetypes==6080)
                curtasktype=alltasktypes(2); %base2rem50
            else
                if ~size(codes,2)
                    taskdisambig = questdlg('Is this a Memory guided task ?','Ambiguous Task','Yes','Yes but self timed','Cancel','Yes');
                    switch taskdisambig
                        case 'Yes'
                            curtasktype=alltasktypes(3); %memory guided
                        case 'Yes but self timed'
                            curtasktype=alltasktypes(4); %self timed saccade task
                        case 'Cancel'
                            return;
                    end
                else
                    if isempty(tasktype)
                        taskdisambig = questdlg('Is this a Memory guided task ?','Ambiguous Task','Yes','Yes but self timed','Cancel','Yes');
                        switch taskdisambig
                            case 'Yes'
                                curtasktype=alltasktypes(3); %memory guided
                                tasktype=alltasktypes(3); %memory guided
                            case 'Yes but self timed'
                                curtasktype=alltasktypes(4); %self timed saccade task
                                tasktype=alltasktypes(4);
                            case 'Cancel'
                                return;
                        end
                    elseif strcmp(tasktype,'memguided')
                        curtasktype=alltasktypes(3); %memory guided
                        tasktype=alltasktypes(3); %memory guided
                    elseif strcmp(tasktype,'st_saccades')
                        curtasktype=alltasktypes(4); %self timed saccade task
                        tasktype=alltasktypes(4);
                    else
                        curtasktype=alltasktypes(3); %memory guided
                        tasktype=alltasktypes(3); %memory guided
                    end
                    
                end
            end
        else
            curtasktype=alltasktypes(4); %self timed saccade task
        end
    elseif ecodetypes(1)==6040
        if length(ecodetypes)>1 && find(ecodetypes==6020) && find(ecodetypes==6080)
            curtasktype=alltasktypes(2); %base2rem50
        elseif length(ecodetypes)>1 && find(ecodetypes==4070)
            curtasktype=alltasktypes(5); %gapstop
        else
            curtasktype=alltasktypes(6); %gapsac
        end
    elseif ecodetypes(1)==6050
        return;
    elseif ecodetypes(1)==6080
        if length(ecodetypes)>1 && find(ecodetypes==6020) && find(ecodetypes==6040)
            curtasktype=alltasktypes(2); %base2rem50
        else
            curtasktype=alltasktypes(7);% delayedsac
        end
    elseif ecodetypes(1)==4050
        return;
    elseif ecodetypes(1)==4060
        curtasktype=alltasktypes(9);% tokens
    elseif ecodetypes(1)==4070
        if length(ecodetypes)>1 && find(ecodetypes==6040)
            curtasktype=alltasktypes(5); %gapstop
        else
            return;
        end
    elseif ecodetypes(1)==4080
        return;
    end
end
%%
if ~isempty(curtasktype) && ~sum(find(codes==17385))
    if iscell(curtasktype)
        curtasktype=cell2mat(curtasktype);
    end
    switch curtasktype
        case 'vg_saccades'
            ecodecueon=7;
            ecodesacstart=8;
            ecodesacend=9;
        case 'base2rem50' %variable
        case 'st_saccades'
            ecodecueon=6;
            ecodesacstart=8;
            ecodesacend=9;
        case 'gapstop'
            ecodecueon=6;
            ecodesacstart=8;
            ecodesacend=9;
        case 'memguided'
            disp('check task ecodes in taskdetect');
            ecodecueon=6;
            ecodesacstart=9;
            ecodesacend=10;
        case 'gapsac' % to change !
            disp('check task ecodes in taskdetect');
            ecodecueon=7;
            ecodesacstart=8;
            ecodesacend=9;
        case 'delayedsac' % to change !
            disp('check task ecodes in taskdetect');
            ecodecueon=6;
            ecodesacstart=8;
            ecodesacend=9;
        case 'tokens'
            %cue on is variable. returns all tokens event numbers
            ecodecueon=find(codes==1501);
            %sacstart is variable too.
            ecodesacstart=find(floor(codes/10)==466);
            if find(codes==16386) %in case it's a saccade to the wrong target, there's no saccade end ecode, but we want the other informations still
                ecodesacend=ecodesacstart;
            else
                ecodesacend=find(floor(codes/10)==486);
            end
    end
end
