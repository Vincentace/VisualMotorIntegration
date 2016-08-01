function res = hash(st)
%HASH Summary of this function goes here
%   Detailed explanation goes here
res = str2num(st(1:2));
res = res * 100 + str2num(st(4:5));
res = res * 100 + str2num(st(7:8));
res = res - 160500;
end

