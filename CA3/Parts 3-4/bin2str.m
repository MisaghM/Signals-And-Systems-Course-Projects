function str = bin2str(bin, mapset)
    bin = bin(1:5 * floor(length(bin) / 5));
    str = blanks(length(bin) / 5);

    for i = 1:5:length(bin)
        index = strcmp(mapset(2, :), bin(i:i + 4));
        str((i + 4) / 5) = mapset{1, index};
    end
end
