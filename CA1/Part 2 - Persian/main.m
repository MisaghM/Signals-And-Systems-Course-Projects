%% Initialization

clc
clear
close all

DATASET_FOLDER = 'Map Set';
DATASET_VAR_FILE = 'LICENSE_LETTERS';
OUTPUT_FILE = 'license_plate.txt';

%% Load the Dataset

if ~exist(DATASET_VAR_FILE, 'file')
    letters = make_letterset(DATASET_FOLDER);
    save(DATASET_VAR_FILE, 'letters');
else
    load(DATASET_VAR_FILE);
end

%% Input Image

[file, path] = uigetfile({'*.jpg;*.bmp;*.png;*.tif'}, 'Choose an image of a license plate');
picture = imread([path, file]);

%% License Plate Detection

boundingBoxes = detectplate_bluestrip(picture);
if isempty(boundingBoxes)
    boundingBoxes1 = detectplate_aspect(picture);
    boundingBoxes2 = detectplate_color_changes(picture);
    boundingBoxes = [boundingBoxes1; boundingBoxes2];
    if isempty(boundingBoxes)
        error('License plate not found.')
    end
end

%% Recognition

result = [];
for i = 1:size(boundingBoxes, 1)
    pictureCropped = imcrop(picture, boundingBoxes(i, :));
    chars = recognize_characters(pictureCropped, letters);
    if size(result, 2) < size(chars, 2)
        result = chars;
    end
end

if isempty(result)
    error('No characters extracted.')
end

result = [result(1:end-2) '-' result(end-1:end)];

%% Output

disp(result)
file = fopen(OUTPUT_FILE, 'wt');
fprintf(file, '%s\n', result);
fclose(file);
winopen(OUTPUT_FILE)
