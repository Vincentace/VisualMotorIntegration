function [bool, num] = findNeuronNumber(spike_name, ch, NN, WSR)
LOAD = load(NN);
Neuron_No = LOAD.Neuron_No;
LOAD = load(WSR);
wsr = LOAD.wsr;
num = 0;
%if nargin < 2
%    for i = 1:size(Neuron_No, 1)
for i = 1:size(Neuron_No, 1)
    if (strcmp(spike_name, Neuron_No{i}{1})) && (ch == Neuron_No{i}{2})
        num = i;
        break;
    end
end

bool = ~isempty(find(wsr==num, 1));