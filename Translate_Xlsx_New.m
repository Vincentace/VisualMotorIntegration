clc; clear; close all;
time_seg = 10;%const
calc_seg = 1000; %1000ms


%How to calc the exact speed at the specific time point(10ms)
%just usethe average speed in a 100ms window
root = 'Raw Data/20160617 data/';%at most one subfolder
Folder = dir(root);
out = zeros(1, 10000);
out_cnt = 0;
%{
'16.05.31_0938-1003_No.10_Session1_PathData'
'20160523_no.10_session1_channel spike'
    data = xlsread(strcat('SPEED DATA/', filename(i).name));
    expression = '.*\.xlsx';
    [s, e] = regexp(filename(i).name, expression);
    st = filename(i).name(s:e-5)
    st = strcat(st, '.mat');
    st = strcat('SPEED DATA/', st);
    save(st, 'data')
    %}
for i = 1:length(Folder)
    if Folder(i).isdir == 1
        %Folder(i).name
        st = strcat(root, Folder(i).name, '/*.xlsx');
        filename = dir(st);
        fprintf('\n\n');
        for j = 1:length(filename)
            if filename(j).name(1) == '~'
                continue
            end
            fprintf('Processing Data Folder %d File %d\n', i, j)
            path = strcat(root, Folder(i).name, '/', filename(j).name);
            [type, sheetname] = xlsfinfo(path); 
            m = size(sheetname, 2);
            coe = -1;
            for k = 1:2
                Sheet = char(sheetname(1,k));
                %xlRange = 'A1:G1';
                [data, txt, raw] = xlsread(path, Sheet);
                if k == 1
                    expression = 'f.*=[^\.\d]*([\.\d]+)[^\.\d]*';
                    %expression = 'f.*=.*([\.\d]+)';
                    %Wrong regexpr!!! KEEP IN MIND
                    coe = -1; % some impossible value
                    for row = 1:size(txt, 1)
                        for col = 1:size(txt, 2)
                            if isnan(txt{row,col}) 
                                continue
                            end
                            if ~ischar(txt{row,col})
                                continue
                            end
                            [tokens, matches] = ...
                            regexp(txt{row,col}, expression, 'tokens', 'match');
                            if length(tokens) == 1
                                coe = str2num(tokens{1}{1});
                                out_cnt = out_cnt + 1;
                                break
                            end
                        end
                        if coe ~= -1
                            break
                        end
                    end 
                    target = 'SPEED DATA/';
                    save_path = [target, ...
                        filename(j).name(1:end-5), num2str(coe), '.mat'];
                    save(save_path, 'data');
                elseif k == 2
                    target = 'SPIKE DATA/';
                    fn = filename(j).name;
                    date = strcat('20', fn([1,2,4,5,7,8]));
                    ex = '.*Session(.+)_.*'; %upper case in SPEED
                    [tokens, matches] = ...
                        regexp(fn, ex, 'tokens', 'match');
                    session = tokens{1}{1};
                    st = [date, '_no.10_session', num2str(session),...
                          '_channel_spike.mat'];
                    save_path = [target, st];
                    save(save_path, 'data');
                end
            end
        end
    end
end
fprintf('done')
