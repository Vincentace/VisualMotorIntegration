clc; clear; close all;
time_seg = 10;%const
calc_seg = 1000; %1000ms


%How to calc the exact speed at the specific time point(10ms)
%just usethe average speed in a 100ms window
root = 'Raw Data/20160617 data/';%at most one subfolder
target = 'SPIKE DATA/';
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
           % fprintf('Processing Data Folder %d File %d\n', i, j)
            path = strcat(root, Folder(i).name, '/', filename(j).name);
            [type, sheetname] = xlsfinfo(path); 
            m = size(sheetname, 2);
            coe = -1;
            for k = 1:m
                Sheet = char(sheetname(1,k));
                xlRange = 'A1:G1';
                [num, txt, raw] = xlsread(path, Sheet, xlRange);
                expression = 'running speed = ([\.\d]+) visual speed';
                for col = 1:length(raw)
                    if isnan(raw{col}) 
                        continue
                    end
                    if ~ischar(raw{col})
                        continue
                    end
                    [tokens, matches] = ...
                        regexp(raw{col}, expression, 'tokens', 'match');
                    if length(tokens) == 1
                        coe = str2num(tokens{1}{1});
                        out_cnt = out_cnt + 1;
                        fprintf('%s\n', strcat(path, '___', tokens{1}{1}));
                        break
                    end
                end   
            end
            if coe == -1
                fprintf('%s\n', strcat(path, '___1'));
            end
           % data = xlsread(path);
           % save_path = strcat(target, filename(j).name(1:end-5), '.mat');
           % save(save_path, 'data');
        end
    end
end
fprintf('done')
