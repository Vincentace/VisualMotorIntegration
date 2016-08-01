%% Initialization
clc; clear; close all;
load('xandy_speed_spike_coe_rcb_rca.mat') %  result
load('xandy_Neuron_No.mat') % Neuron_No
cnt = zeros(7, 1); % coe 4,   2,   1,   0.6,  0.6;   >1,   <1
coe = zeros(size(result, 1), 1);
ab = 0;
pValue = zeros(1, size(result, 1)); % pValues without adjustment
COEARRAY = [4 2 1 0.6 0.4];

%% for every neuron, do the wilcoxon signed rank test
for i = 1:size(result, 1)
    Y1 = result(i, :, 2);
    Y2 = result(i, :, 3);
    coe(i) = result(i,1,1); tmp = coe(i);
    coe_num = find(COEARRAY == coe(i));
    cnt(coe_num) = cnt(coe_num) + 1;
    if coe(i) > 1
        cnt(6) = cnt(6) + 1;
    end
    if coe(i) < 1
        cnt(7) = cnt(7) + 1;
    end
    j = 1;
    while true
        if Y1(j) == 0 || Y2(j) == 0
            Y1 = [Y1(1:j-1), Y1(j+1:end)];
            Y2 = [Y2(1:j-1), Y2(j+1:end)];
        end
        j = j + 1;
        if j > length(Y1)
            break
        end
    end
    if length(Y1) ~= 20
        ab = ab + 1; % only for testing purpose
    end
    pValue(i) = signrank(Y1, Y2);
end
%% save the raw pValues
save('xandy_HTest_Speed_Spike_pValues.mat', 'pValue') 

%% doing FDR adjustment
fdr = mafdr(pValue, 'BHFDR', true);
%original pValues
%then do some adjustment, save significant ones neuron number in wsr
wsr = zeros(1, 2); wsr_cnt = 0;
%wsr == wilcoxon signed rank......Array of active neuron numbers
for i = 1:length(fdr)
    if fdr(i) < 0.05
        wsr_cnt = wsr_cnt + 1;
        wsr(wsr_cnt) = i;
    end
end

wsr_cnt = length(wsr);
save('xandy_wsr.mat', 'wsr');
% save result... xandy means the running speed is calculated using
% Euclidean distance of x and y axis

%% print result
fprintf('H0:mean spike frequency are the same before/after changing\n');
fprintf('number of independent neurons for coe = \n');
fprintf('4,       2,       1,       0.6,     0.4;     >1,      <1\n');
for i = 1:7
    fprintf('%-9d', cnt(i));
end
fprintf('\n');

%% plot the speed-spike graph of active(significant) neurons
speed_cnt = 0;
ROW = 1 + fix(sqrt(length(wsr)));
COL = ROW;
figure
for i = 1:wsr_cnt
    ax = subplot(ROW, COL, i);
    hold on
    min_running_speed = result(wsr(i), 2, 1);
    max_running_speed = result(wsr(i), 3, 1);
    m_m = max_running_speed - min_running_speed;
    zz = linspace(min_running_speed, max_running_speed, ...
                    length(result(wsr(i),:,2)));
    zz = zz';
    zz = zz * 100;
    RC = [result(wsr(i),:,2); result(wsr(i),:,3)]';
    bar(ax, zz, RC, 'grouped');

    if flag == 0
        flag = 1;
        xlabel(['speed(cm/s) min: ', num2str(100*min_running_speed),...
                    ' max: ', num2str(100*max_running_speed)]);
        ylabel(['(spike num / second num) in speed interval, ',...
                    'interval number:', num2str(speed_cnt)])
        legend('running frequency before', 'running frequency after');
        %title(['Running Speed-Spike Graph, ', ' Num : ', num2str(i)]);
        sttt = ['coe', num2str(result(wsr(i), 1, 1)), ',',...
            Neuron_No{wsr(i)}{1}(5:end-4), ',', ...
            num2str(Neuron_No{wsr(i)}{2})];
        title(sttt);
    else
        xlabel(['speed(cm/s) min: ', num2str(100*min_running_speed),...
                    ' max: ', num2str(100*max_running_speed)]);
        ylabel('spike number / second number');
        legend('RF before', 'RF after');
        sttt = ['coe',num2str(result(wsr(i), 1, 1)), ',',...
            Neuron_No{wsr(i)}{1}(5:end-4), ',', ...
            num2str(Neuron_No{wsr(i)}{2})];
        title(sttt);
    end
end
%% save the graph
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 32 24])
figure_name = 'xandy WSR significant speed-spike bar graph.jpg';
saveas(gcf, figure_name);
fprintf('program done\n');