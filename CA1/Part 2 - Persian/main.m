%% Initialization

clc
clear
close all

DATASET_FOLDER = 'Map Set';
DATASET_VAR_FILE_NAME = 'LICENSE_LETTERS';
SMALL_OBJECT_AREA = 400;
BACKGROUND_AREA = 6500;
IMAGE_SIZE = [400 600];
SEGMENT_SIZE = [100 80];
SEGMENT_THRESHOLD = 0.45;
OUTPUT_FILE_NAME = 'license_plate.txt';
BINARIZE_SENSITIVITY = 0.5;

%% Load the Dataset

if ~exist(DATASET_VAR_FILE_NAME, 'file')
    letters = make_letterset(DATASET_FOLDER);
    save(DATASET_VAR_FILE_NAME, 'letters');
else
    load(DATASET_VAR_FILE_NAME);
end

letters_count = size(letters, 2);

%% Input Image

[file, path] = uigetfile({'*.jpg;*.bmp;*.png;*.tif'}, 'Choose an image of a license plate');
picture = imread([path, file]);

%% License Plate Detection

boundixBox = [];

picture = imcrop(picture, boundixBox);
picture = imresize(picture, IMAGE_SIZE);

%% Preprocessing

picture = rgb2gray(picture);
picture = imbinarize(picture, "adaptive", "ForegroundPolarity", "dark", "Sensitivity", BINARIZE_SENSITIVITY);

%% Remove Background and Small Objects

picture_rmsmall = bwareaopen(picture, SMALL_OBJECT_AREA);
background = bwareaopen(picture_rmsmall, BACKGROUND_AREA);
picture_rmbg = picture_rmsmall - background;

% plot the image
figure('Name', 'Removals')
subplot(1, 3, 1)
imshow(picture_rmsmall)
title('Small Objects Removal')
subplot(1, 3, 2)
imshow(background)
title('Background')
subplot(1, 3, 3)
imshow(picture_rmbg)
title('Background Removal')

picture = picture_rmbg;

%% Segmentation

[label_matrix, region_count] = bwlabel(picture);
regions = regionprops(label_matrix, 'BoundingBox');

figure('Name', 'Components')
imshow(picture)
hold on

for i = 1:region_count
    rectangle('Position', regions(i).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 1)
end

hold off

%% Recognition

figure('Name', 'Match')
final_output = [];

for i = 1:region_count
    [rows, cols] = find(label_matrix == i);
    region = picture(min(rows):max(rows), min(cols):max(cols));
    imshow(region)
    region = imresize(region, SEGMENT_SIZE);
    imshow(region)
    pause(0.2)

    region_corr = zeros(1, letters_count);

    for j = 1:letters_count
        region_corr(j) = corr2(letters{1, j}, region);
    end

    [max_corr, pos] = max(region_corr);

    if max_corr > SEGMENT_THRESHOLD
        out = cell2mat(letters(2, pos));
        final_output = [final_output out];
    end

end

close

final_output = [final_output(1:end-2) '-' final_output(end-1:end)];

%% Output

disp(final_output)
file = fopen(OUTPUT_FILE_NAME, 'wt');
fprintf(file, '%s\n', final_output);
fclose(file);
winopen(OUTPUT_FILE_NAME)
