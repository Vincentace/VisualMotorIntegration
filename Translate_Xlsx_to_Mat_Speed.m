clc; clear; close all;
time_seg = 10;%const


filename=dir('SPEED DATA/*.xlsx');
for i = 1:length(filename)
    fprintf('Processing Data %d\n', i)
%    st = num2str(i, '%0.2d');
%    st = strcat('speed', st);
%    st = strcat(st, '.mat');
    data = xlsread(strcat('SPEED DATA/', filename(i).name));
    expression = '.*\.xlsx';
    [s, e] = regexp(filename(i).name, expression);
    st = filename(i).name(s:e-5)
    st = strcat(st, '.mat');
    st = strcat('SPEED DATA/', st);
    save(st, 'data')
end
fprintf('Done!')
