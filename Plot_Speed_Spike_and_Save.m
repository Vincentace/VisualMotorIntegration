%% Initializatoin
% 
clc; clear; close all;
time_seg = 10;%const
calc_seg = 1000; %1000ms
speed_cnt = 20;% divide speed into speed_cnt segment
Change_V_Pos = 49010;
STARTING_TIME = 60;
ENDING_TIME = 20;
speedname = dir('SPEED DATA/*.mat');
spikename = dir('SPIKE DATA/*.mat');
result_cnt = 0;
result = zeros(2, speed_cnt, 3);
Neuron_No = cell(2, 2);
caseNum = 0;
%% for loop
for i = 1:length(speedname)
%% find speed file
    caseNum = caseNum + 1
    fprintf('Processing Speed :  %s\n', speedname(i).name)
    expression = '.*PathData(.+)\.mat';
    [tokens, matches] = ...
    regexp(speedname(i).name, expression, 'tokens', 'match');

%% get experiment coefficient
    if length(tokens) == 1, coe = str2num(tokens{1}{1});
    else coe = 1; end
%% get the spike data of this session
    date = strcat('20', speedname(i).name([1,2,4,5,7,8]));
    ex = '.*Session(.+)_.*'; %upper case in SPEED
    [tokens, matches] = ...
        regexp(speedname(i).name, ex, 'tokens', 'match');
    session = tokens{1}{1};
    st = strcat('.*_session', session, '_.*'); %lower case in SPIKE
    ex = strcat(date, st);
    cnt = 0;  flag = 0;
    for j = 1:length(spikename)
        [s, e] = regexp(spikename(j).name, ex);
        if (s == 1) 
            if flag ~= 0, error('Wrong Data Number, i=%d' , i); end
            flag = j;
        end
    end
    if flag == 0, error('Wrong Data Number, i=%d' , i); end
    spike_num = flag;
    fprintf('Processing Spike :  %s\n', spikename(spike_num).name);
%% get the max spike time
    fin = ['SPIKE DATA/', spikename(spike_num).name];
    load(fin);%data is the matrix saving spikes    
    max_time = max(data(:));
%% calc and discretize speed
    fin = ['SPEED DATA/', speedname(i).name];
    load (fin);
    [visual_speed, running_speed, time_span, speed, sep] ...
         = getSpeed(data, calc_seg, time_seg, ...
            STARTING_TIME, ENDING_TIME, max_time, coe, Change_V_Pos);
    running_res_b = zeros(1, speed_cnt);    
    running_res_a = zeros(1, speed_cnt);
    max_running_speed = min(max(running_speed(1:sep-1)),...
                            max(running_speed(sep+1:end)));
    min_running_speed = max(min(running_speed(1:sep-1)),...
                            min(running_speed(sep+1:end)));
    m_m = max_running_speed - min_running_speed;
    for j = 1:length(running_speed)
        if (running_speed(j) < min_running_speed) ...
            || (running_speed(j) > max_running_speed)
            continue;
        end
        %ignore those data
        tmp = running_speed(j) - min_running_speed;
        tmp = fix(speed_cnt * tmp / m_m) + 1;
        if tmp == speed_cnt + 1, tmp = speed_cnt; end
        if tmp > speed_cnt, error('tmp > speed_cnt + 1'); end
        if j < sep, running_res_b(tmp) = running_res_b(tmp) + 1; end
        % we ignore the case when j == sep
        if j > sep, running_res_a(tmp) = running_res_a(tmp) + 1; end
    end
%% calculate the spike frequency in specify speed interval
    fin = strcat('SPIKE DATA/', spikename(spike_num).name);
    load(fin);%variable "data" is the matrix which saves spikes data
    flag = 0;
    for j = 1:size(data, 2) % j is the No. of spike channel
        running_cnt_b = zeros(1, speed_cnt);    
        running_cnt_a = zeros(1, speed_cnt);
        speed_index = 1; 
        spike_index = 1;
        di = speed_index; ei = spike_index;
        while data(ei,j) * 1000 < time_span(1), ei = ei + 1; end
        ei_start = ei; % ignore spikes that occurs before STARTING_TIME
        for ei = ei_start:length(data(:,j)) % deal with spikes one by one
            if isnan(data(ei, j)), break; end
            % MATLAB reads blank Excel segment as NaN
            while data(ei,j)*1000 > time_span(di)
                di = di + 1;
                if di > length(time_span), break; end
            end
            if di > length(time_span), break; end
            if (running_speed(di) < min_running_speed) ...
                || (running_speed(di) > max_running_speed)
                continue;
            end
            tmp = running_speed(di) - min_running_speed;
            tmp = fix(speed_cnt * tmp / m_m) + 1;
            if tmp == speed_cnt + 1, tmp = speed_cnt; end
            if tmp > speed_cnt, error('tmp > speed_cnt + 1'); end
            if data(ei, j)*1000 <= time_span(sep-1)
                % notice that it is impossible for sep == 1
                running_cnt_b(tmp) = running_cnt_b(tmp) + 1;
            end
            % we ignore the case when date(ei, j)*1000 falls in
            % the No.sep second
            if data(ei, j)*1000 > time_span(sep)
                running_cnt_a(tmp) = running_cnt_a(tmp) + 1; 
            end
        end
        for k = 1:speed_cnt
            if running_cnt_a(k) ~= 0
                running_cnt_a(k) = running_cnt_a(k) / running_res_a(k);
            end
            if running_cnt_b(k) ~= 0
                running_cnt_b(k) = running_cnt_b(k) / running_res_b(k);
            end          
        end

        NUM = size(data,2);
        ROW = 1 + fix(sqrt(NUM));
        COL = ROW;

        %ax = subplot(ROW, COL, j);
        %hold on

        zz = linspace(min_running_speed, max_running_speed, speed_cnt);
        zz = zz * 100;
        RC = [running_cnt_b; running_cnt_a]';
        %bar(ax, zz, RC, 'grouped');
        
        result_cnt = result_cnt + 1;
        ttt = ones(speed_cnt, 1) * coe; 
        ttt(2) = min_running_speed;
        ttt(3) = max_running_speed;
        tmp = [ttt, RC];
        %tmp contains information of a single neuron firing infomation
        %tmp[1][1] = coe(iffient)
        %tmp[2][1] = min_running_speed;
        %tmp[3][1] = max_running_speed;
        %tmp[4:][1] are meaningless
        %tmp[:][2] : running_cnt_b
        %tmp[:][3] : running_cnt_a
        result(result_cnt,:,:) = tmp;
        Neuron_No{result_cnt}{1} = spikename(spike_num).name;
        Neuron_No{result_cnt}{2} = j;
      
        %{
        if flag == 0
            flag = 1;
            xlabel(['speed(cm/s) min: ', num2str(100*min_running_speed),...
                    ' max: ', num2str(100*max_running_speed)]);
            ylabel(['(spike num / second num) in speed interval, ',...
                    'interval number:', num2str(speed_cnt)]);
            legend('running frequency before', 'running frequency after');
            title(['Running Speed-Spike Graph, ', ' Ch : ', num2str(j)]);
        else
            xlabel(['speed(cm/s) min: ', num2str(100*min_running_speed),...
                    ' max: ', num2str(100*max_running_speed)]);
            ylabel('spike number / second number');
            legend('RF before', 'RF after');
            title(['Running Speed-Spike Graph, ', ' Ch : ', num2str(j)] );   
        end
        %}
    end
    %{
    set(gcf,'PaperUnits','inches','PaperPosition',[0 0 32 24])
    figure_name = [speedname(i).name(1:end-4), 'Coe = ', ...
                   num2str(coe), '.jpg'];
    saveas(gcf, figure_name);
    %}
end
%% print
fprintf('Done')
save('xandy_speed_spike_coe_rcb_rca.mat', 'result');
% main result
save('xandy_Neuron_No.mat', 'Neuron_No');
% Neuron number
% close all