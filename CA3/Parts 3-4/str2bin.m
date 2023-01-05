function bin = str2bin(str, mapset)
    bin = cell(1, length(str));

    for i = 1:length(str)
        index = strcmp(mapset(1, :), str(i));
        bin{1, i} = mapset{2, index};
    end

    bin = cell2mat(bin);
end
