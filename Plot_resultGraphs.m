%% Plot Graphs like the paper "Visuomoter"
clc; clear; close all;
time_seg = 10;%const
calc_seg = 1000; %1000ms
Change_V_Pos = 49010;
STARTING_TIME = 60;
ENDING_TIME = 20;
baseLevel = 1;
sec_seg = 10; % the number of partitions of Cnt
time_specify = 10; % x second before/after

speedname = dir('SPEED DATA/*.mat');
spikename = dir('SPIKE DATA/*.mat');

COEARRAY = [4 2 1 0.6 0.4];

for SNi = 1:length(speedname)
%% find the speed and corresponding spike.mat
    %fprintf('Processing Speed :  %s\n', speedname(i).name)
    expression = '16.*PathData(.+)\.mat';
    [tokens, matches] = ...
    regexp(speedname(SNi).name, expression, 'tokens', 'match');
    if length(tokens) == 1
        coe = str2num(tokens{1}{1});
    end
    
    date = strcat('20', speedname(SNi).name([1,2,4,5,7,8]));
    ex = '.*Session(.+)_.*'; %upper case in SPEED
    [tokens, matches] = ...
        regexp(speedname(SNi).name, ex, 'tokens', 'match');
    session = tokens{1}{1};
 %   expression = '16.05.28.*PathData(.+)\.mat';
    st = strcat('.*_session', session, '_.*'); %lower case in SPIKE
    ex = strcat(date, st);
    cnt = 0;
    flag = 0;
    for j = 1:length(spikename)
        [s, e] = regexp(spikename(j).name, ex);
        if (s == 1) 
            if flag ~= 0
                fprintf('Wrong Data Number, i=%d' , i);
                pause
            end
            flag = j;
        end
    end
    if flag == 0
        fprintf('Wrong Data Number, i=%d' , SNi);
        pause;%not exit, but... how to terminate 
    end
    spike_num = flag;

%% get the speed
    fin = strcat('SPIKE DATA/', spikename(spike_num).name);
    load(fin);%data is the matrix saving spikes    
    max_time = max(data(:));
    
    fin = strcat('SPEED DATA/', speedname(SNi).name);
    load (fin);
    [visual_speed, running_speed, time_span, ...
        speed, sep, sep_time, IDV, IDR] ...
            = getSpeed(data, calc_seg, time_seg, ...
                STARTING_TIME, ENDING_TIME, max_time, coe, Change_V_Pos);
    sep_time = sep_time / 1000;
    %convert to second
    
    fprintf('Processing Spike :  %s\n', spikename(spike_num).name);
    fin = strcat('SPIKE DATA/', spikename(spike_num).name);
    load(fin);%data is the matrix saving spikes
    
    max_va_speed = max(max(visual_speed), max(running_speed));
    %% for every channel in that session
    for chan = 1:size(data, 2)
        NAN = find(isnan(data(:,chan)), 1)-1;
        if length(NAN) == 0
            NAN = size(data, 1);
        end
        len = min(size(data, 1), NAN);

        %% calculate spike frequency
        matrix = zeros(30, 30);
        speed_index = 1; spike_index = 1;
        di = speed_index; ei = spike_index;
        j = chan;
        while data(ei, j) * 1000 < time_span(1)-10, ei = ei + 1; end
        ei_start = ei; % ignore spikes that occurs before STARTING_TIME
        for ei = ei_start:length(data(:, j))
            % deal with spikes one by one
            if isnan(data(ei, j)), break; end
            if data(ei, j) > time_span(end)/1000, break; end
            if data(ei, j) < time_span(1)/1000, continue; end
            % MATLAB reads blank Excel segment as NaN
            while data(ei, j)*1000 > time_span(di)
                di = di + 1;
                if di > length(time_span), break; end
            end
            if di > length(time_span), break; end
            as = running_speed(di)*100; vs = visual_speed(di)*100;
            as = fix(as)+1; vs = fix(vs)+1;
            if as > 30, as = 30; end;
            if vs > 30, vs = 30; end
            matrix(vs,as) = matrix(vs,as)+1;
        end

        %% Normalization
        cntMat = zeros(size(matrix, 1), size(matrix, 2));
        for ii = 1:length(time_span)
            as = running_speed(ii)*100; vs = visual_speed(ii)*100;
            as = fix(as)+1; vs = fix(vs)+1;
            if as > 30, as = 30; end;
            if vs > 30, vs = 30; end
            cntMat(vs, as) = cntMat(vs, as) + 1;
        end
        for vs = 1:size(matrix, 1)
            for as = 1:size(matrix, 2)
                if cntMat(vs, as) > 0
                    matrix(vs, as) = matrix(vs, as) / cntMat(vs, as);
                end
            end
        end

        %% plot visual_speed - running_speed spike frequency graph and save
        figure
        hold on
        colorDepth = 1000;
        colormap(jet(colorDepth));
        
        [x, y] = meshgrid(1:30, 1:30); 
        pcolor(x,y,matrix);  shading interp

        ax = gca;
        ax.FontSize = 22;
        ax.FontName = 'monospaced';
        ax.XScale = 'log';
        ax.XTick = [1, 10, 30];
        ax.XLim = [1, 30];
        ax.YScale = 'log';
        ax.YTick = [1, 10, 30];
        ax.YLim = [1, 30];
        ax.XLabel.String = ({'Visual Speed,', 'V (cm s^{-1})'});
        ax.YLabel.String = ({'Running Speed,', 'R (cm s^{-1})'});
        ax.FontAngle = 'italic';
        
        fi = gcf;
        fi.PaperUnits = 'inches';
        fi.PaperType = 'A4';
        fi.PaperPosition = [0 0 32 24];
        
        co = colorbar('southoutside');
        co.Label.String = 'Firing Rate (spikes s^{-1})';
        
        
        ax.TitleFontSizeMultiplier = 2;
        st = [speedname(SNi).name, ' Channel:', num2str(chan)];
        title(st, 'interpreter', 'none');
    
        saveas(gcf, ['Spike Freq ', st, '.jpg']);
        %imwrite
        %st = ['0801/' , ...
        
%% plot speed - position (running speed and actual displacement)
%  notice that we deleted data of [0, STARTING_TIME] and [end-ENGING_TIME..
        %{
        [visual_speed, running_speed, time_span, speed, sep, sep_time] ...
         = getSpeed(data, calc_seg, time_seg, ...
                 STARTING_TIME, ENDING_TIME, max_time, coe, Change_V_Pos);
        %PSD = partial sum of displacement (running_speed)
        PSD = zeros(1, length(running_speed));
        PSD(1) = running_speed(1);
        for ii = 2:length(running_speed)
            PSD(ii) = PSD(ii-1) + running_speed(ii);
        end
        %for ii = 1:length(time_span)
            
%% cannot have it, not enough data(only one run,
        %the paper got one neuron in 15 runs)
        
        %}
        
        %break;
    end % for channel
    %break;
end % for i in speedname
fprintf('program ended')
close all; clear; clc