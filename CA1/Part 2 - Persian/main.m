%% Initialization

clc
clear
close all

DATASET_FOLDER = 'Map Set';
DATASET_VAR_FILE_NAME = 'LICENSE_LETTERS';
IMAGE_SIZE = [400 600];
OUTPUT_FILE_NAME = 'license_plate.txt';

%% Load the Dataset

if ~exist(DATASET_VAR_FILE_NAME, 'file')
    letters = make_letterset(DATASET_FOLDER);
    save(DATASET_VAR_FILE_NAME, 'letters');
else
    load(DATASET_VAR_FILE_NAME);
end

lettersCount = size(letters, 2);

%% Input Image

[file, path] = uigetfile({'*.jpg;*.bmp;*.png;*.tif'}, 'Choose an image of a license plate');
picture = imread([path, file]);

%% License Plate Detection

boundingBoxes = detect_with_color_changes(picture);

%% Recognition

result = [];
for i = 1:size(boundingBoxes, 1)
    pictureCropped = imcrop(picture, boundingBoxes(i, :));
    pictureCropped = imresize(pictureCropped, IMAGE_SIZE);
    chars = recognize_characters(pictureCropped, letters, lettersCount);
    if size(result, 2) < size(chars, 2)
        result = chars;
    end
end

result = [result(1:end-2) '-' result(end-1:end)];

%% Output

disp(result)
file = fopen(OUTPUT_FILE_NAME, 'wt');
fprintf(file, '%s\n', result);
fclose(file);
winopen(OUTPUT_FILE_NAME)
