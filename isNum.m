function o = isNum(x)
if ischar(x)
    o = 1;
    for i = 1:length(x)
        if x(i) < '0' || x(i) > '9'
            o = 0;
            break
        end
    end
else
    o = 0;
end

end

