function letters = make_letterset(datasetFolder)
    NUMBERS_FOLDER = [datasetFolder, '\', 'Numbers'];
    ALPHABET_FOLDER = [datasetFolder, '\', 'Alphabet'];

    letters.numbers = read_folder(NUMBERS_FOLDER);
    letters.alphabet = read_folder(ALPHABET_FOLDER);
end

function inside = read_folder(path)
    folder = dir(path);
    content = {folder.name};
    files = content(3:end);
    len = length(files);

    inside = cell(2, len);

    for i = 1:len
        inside(1, i) = {imread([path, '\', cell2mat(files(i))])};
        temp = cell2mat(files(i));
        inside(2, i) = {temp(1:find(temp == '.')-1)};
    end
end
