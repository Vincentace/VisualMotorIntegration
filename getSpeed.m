function [visual_speed, running_speed, time_span, ...
    speed, sep, sep_time, IDV, IDR] ...
= getSpeed(data, calc_seg, time_seg, ST, EN, max_time, coe, Change_V_Pos)
%% Input:
%data:  speed data
%calc_seg:  how many milisecond we do the average
%time_seg:  how many milisecond before ...
%           the machine record the distance next time (default 10)
%ST:    how many seconds after the beginning of recording of data is marked 
%       as starting time
%EN:    how many seconds before the ending of recording of data is marked 
%       as ending time
%max_time:  the last spike time ?in seconds)
%coe:   running speed is coe times visual speed after changing
%Change_V_Pos: exact distance of movement of the change
%% Output:
%speed: xandy speed in "10ms' all speed
%       because the time_seg is not always 10ms
%       speed is not accurate, only for illustration purpose
%visual_speed, running_speed:   ave_speed in (calc_seg/time_seg) * "10ms":
%       may not be exactly 1s, because of the measuring error
%       does divided by actual time span,
%time_span: time passed in ms(NOT 10ms!), at the end of the calc_seg
%       interval
%sep:   the index of array when the visual speed change occurs
%sep_time:  the exact time when the change occurs (milisecond)
%IDV:   initial_displacement of visual_speed (The displacement of the first
%ST seconds
%IDR:   initial_displacement of running_speed
%% Notice
% The Excel output is visual speed. 
% The machine cancreate an open field(2D) virtual reality 
% instead of an one-way corridor
% pmm is the parameter of the machine, not some language in neural science
% the machine automatically divide the recorded running speed by coe after
% the change, and take the result as visual speed (i.e. the output)
% If coe == 2, then the visual speed is 0.5 times running speed after
% change. And the running speed is 2 times the v_speed(which is the output
% of the Excel file)
%% ...
if nargin < 7
    coe = 1;
end

%% Check if the time recorded is right
del_line = zeros(1, size(data,1));
count = 0;
for i = 1:0%size(data, 1)
    p = datestr(data(i,1), 'HH:MM:SS.FFF');
    if length(p) == 12 && isnum(p([1,2,4,5,7,8,10,11,12])) ...
        && strcmp(p([3,6,9]), '::.')
    else
        count = count+1;
        del_line(count) = i;
    end
end
%good, speed 1_1 passed

if count > 0
    fprintf('wrong data')
    %how to delete multiple(separated) lines
    pause;
end

for i = 1:0%size(data, 1)-1   
    p = datestr(data(i,1), 'HH:MM:SS.FFF');
    q = datestr(data(i+1,1), 'HH:MM:SS.FFF');
    hp = str2num(p([1,2])); hq = str2num(q([1,2]));
    mp = str2num(p([4,5])); mq = str2num(q([4,5]));
    sp = str2num(p([7,8])); sq = str2num(q([7,8]));
    fp = str2num(p(10:12)); fq = str2num(q(10:12));
    timep = (((hp*60)+mp)*60+sp)*1000+fp;
    timeq = (((hq*60)+mq)*60+sq)*1000+fq;
    if timeq - timep < 5 || timeq - timep > 20
        count = count + 1;
        del_line(count) = i+1;
    end
end

if count > 0
    %32 out of 10000 is not 10ms segment
    %3 out of 135798(speed_1_1.xlsx) is < 5ms segment
    %(3, 3, 1)
    %None is > 20ms segment
    fprintf('wrong data')
    for i = 1:count
        last = datestr(data(del_line(i)-1,1),'HH:MM:SS.FFF')
        now = datestr(data(del_line(i),1),'HH:MM:SS.FFF')
    end
    %how to delete multiple(separated) lines
end
%check complete

%% some initialization work
START = ST * 100;%delete first 60 seconds (unit: "10ms"?
END = EN * 100;%delete last 20 seconds (unit: "10ms")
%we roughly take one line as 10ms

y = data(START+1:end-END+1, 4)';
x = data(START+1:end-END+1, 5)';
xandy_dis = zeros(1, length(y)-1);
% Euclidiean distance of movement in "10ms", running/actuall movement
y_dis = zeros(1, length(y)-1);
% distance of movement in only y-axis, running/actuall movement
flag = 0; 
multiplier = 1;
for i = 1:length(xandy_dis)
    if abs(y(i+1)) > Change_V_Pos && flag == 0
        flag = 1;
        p = datestr(data(i, 1), 'HH:MM:SS.FFF');
        hp = str2num(p(1:2)); mp = str2num(p(4:5));
        sp = str2num(p(7:8)); fp = str2num(p(10:12));
        sep_time = (((hp*60)+mp)*60+sp)*1000+fp;
        IDV = sum(y_dis(1:i-1));
        IDR = sum(xandy_dis(1:i-1));
        multiplier = multiplier * coe;
        %the time when the speed changes
    end
    y_dis(i) = abs(y(i+1) - y(i)) * multiplier;
    xandy_dis(i) = abs(sqrt(y(i+1)*y(i+1)+x(i+1)*x(i+1)) ...
                    - sqrt(y(i)*y(i)+x(i)*x(i))) * multiplier;
end
p = datestr(data(1,1), 'HH:MM:SS.FFF');
hp = str2num(p(1:2)); mp = str2num(p(4:5));
sp = str2num(p(7:8)); fp = str2num(p(10:12));
start_time = (((hp*60)+mp)*60+sp)*1000+fp;
m_mm = 1000;%const 1meter == 1000 milimeter
mul = round(calc_seg/time_seg); %multiplier
visual_speed = zeros(1, fix((length(y_dis)-1) / mul)); %m/s
running_speed = zeros(1, length(visual_speed));
time_span = zeros(1, length(visual_speed));
%the time passed at the point of visual_speed(i)
speed = xandy_dis(1:fix(length(y_dis)/mul)*mul) / time_seg;
%only calculate Integer seconds, leave out the rest
LENGTH = length(visual_speed);
%% Calculate visual/running speed
flag = 0;
for i = 1:length(visual_speed)
    p = datestr(data((i-1)*mul+1,1), 'HH:MM:SS.FFF');
    q = datestr(data(i*mul+1,1), 'HH:MM:SS.FFF');
    hp = str2num(p([1,2])); hq = str2num(q([1,2]));
    mp = str2num(p([4,5])); mq = str2num(q([4,5]));
    sp = str2num(p([7,8])); sq = str2num(q([7,8]));
    fp = str2num(p(10:12)); fq = str2num(q(10:12));
    timep = (((hp*60)+mp)*60+sp)*1000+fp;
    timeq = (((hq*60)+mq)*60+sq)*1000+fq;
    Time = timeq - timep;
%% distance of movement in (roughly) 1 second    
    visual_speed(i) = sum(y_dis((i-1)*mul+1 : i*mul+1));
    visual_speed(i) = visual_speed(i) / m_mm;
    visual_speed(i) = visual_speed(i) / (Time/1000);
    running_speed(i) = sum(xandy_dis((i-1)*mul+1 : i*mul+1));
    running_speed(i) = running_speed(i) / m_mm;
    running_speed(i) = running_speed(i) / (Time/1000);
    time_span(i) = timeq - start_time;
    
    if flag == 1 % after change
        visual_speed(i) = visual_speed(i) / coe;
    end % visual_speed is running_speed / coe
    if timep <= sep_time && sep_time < timeq && flag == 0
        flag = 1; sep = i; % get the exact sep index
        tmp = sep_time - timep + coe * (timeq - sep_time);
        visual_speed(i) = tmp * visual_speed(i) / Time;
    end

    if time_span(i) > max_time*1000 
        % if there is no spike in and after this calc_seg, delete and break
        LENGTH = i-1;
        break;
    end
%    if (flag == 1) && (time_span(i) > 2*time_span(sep))
%        LENGTH = i-1;
%        break;
%    end
end
visual_speed = visual_speed(1:LENGTH);
running_speed = running_speed(1:LENGTH);
time_span = time_span(1:LENGTH);

sep_time = sep_time - start_time;
%adjust sep_time
end

