clc
clear
close all

load LICENSE_LETTERS
letters_count = size(letters, 2);

[file, path] = uigetfile({'*.jpg;*.bmp;*.png;*.tif'}, 'Choose an image of a license plate.');
picture = imread([path, file]);

%%

% Resize image, RGB to GRAY to BITMAP
picture_resized = imresize(picture, [400 600]);
picture_gray = rgb2gray(picture_resized);
picture_bitmap = ~imbinarize(picture_gray);

figure('Name', 'Manipulations')
subplot(2, 2, 1)
imshow(picture)
title('Image')
subplot(2, 2, 2)
imshow(picture_resized)
title('Resized')
subplot(2, 2, 3)
imshow(picture_gray)
title('Grayscale')
subplot(2, 2, 4)
imshow(picture_bitmap)
title('Bitmap')

picture = picture_bitmap;

%%

% Remove background and small objects
picture_rmsmall = bwareaopen(picture, 200);
background = bwareaopen(picture_rmsmall, 4000);
picture_rmbg = picture_rmsmall - background;

figure('Name', 'Removals')
subplot(1, 3, 1)
imshow(picture_rmsmall)
title('Small objects removed')
subplot(1, 3, 2)
imshow(background)
title('Background')
subplot(1, 3, 3)
imshow(picture_rmbg)
title('Background removed')

picture = picture_rmbg;

%%

% Labeling connected components
[label_matrix, region_count] = bwlabel(picture);
regions = regionprops(label_matrix, 'BoundingBox');

figure('Name', 'Components')
imshow(picture)
hold on

for i = 1:region_count
    rectangle('Position', regions(i).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 1)
end

hold off

%%

% Decision making
figure('Name', 'Match')
final_output = [];

for i = 1:region_count
    [rows, cols] = find(label_matrix == i);
    region = picture(min(rows):max(rows), min(cols):max(cols));
    imshow(region)
    region = imresize(region, [100, 80]);
    imshow(region)
    pause(0.2)

    region_corr = zeros(1, letters_count);

    for j = 1:letters_count
        region_corr(j) = corr2(letters{1, j}, region);
    end

    [max_corr, pos] = max(region_corr);

    if max_corr > .45
        out = cell2mat(letters(2, pos));
        final_output = [final_output out];
    end

end

close

%%

% Write the plate to a file
file = fopen('number_plate.txt', 'wt');
fprintf(file, '%s\n', final_output);
fclose(file);
winopen('number_plate.txt')
