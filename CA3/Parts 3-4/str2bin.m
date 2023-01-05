function bin = str2bin(str, mapset)
    bin = cell(1, length(str));
    for i = 1:length(str)
        bin{1, i} = findCode(str(i), mapset);
    end
    bin = cell2mat(bin);
end

function bin = findCode(char, mapset)
    for i = 1:length(mapset)
        if mapset{1, i} == char
            bin = mapset{2, i};
            break;
        end
    end
end
