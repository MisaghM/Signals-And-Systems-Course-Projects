clc
clear
close all

FOLDER = 'Map Set';

folder = dir(FOLDER);
content = {folder.name};
files = content(3:end);
len = length(files);

letters = cell(2, len);

for i = 1:len
   letters(1, i) = {imread([FOLDER, '\', cell2mat(files(i))])};
   temp = cell2mat(files(i));
   letters(2, i) = {temp(1)};
end

save('LICENSE_LETTERS.mat', 'letters')
clear
