function characters = recognize_characters(picture, letters)
    RESIZE_WIDTH = 800;
    SMALL_OBJECT_AREA = 400;
    BACKGROUND_AREA = 7000;
    SEGMENT_SIZE = [100, 80];
    SEGMENT_THRESHOLD = 0.45;
    BINARIZE_SENSITIVITY = 0.4;

    lettersCount = size(letters, 2);

    % preprocess the image
    picture = imresize(picture, [NaN, RESIZE_WIDTH]);
    picture_gray = rgb2gray(picture);
    picture_bitmap = ~imbinarize(picture_gray, "adaptive", "ForegroundPolarity", "dark", "Sensitivity", BINARIZE_SENSITIVITY);

    % Remove Background and Small Objects
    picture_rmsmall = bwareaopen(picture_bitmap, SMALL_OBJECT_AREA);
    background = bwareaopen(picture_rmsmall, BACKGROUND_AREA);
    picture_rmbg = picture_rmsmall - background;

    % plot images
    figure('Name', 'Manipulations')
    subplot(2, 3, 1)
    imshow(picture)
    title('Original')
    subplot(2, 3, 2)
    imshow(picture_gray)
    title('Grayscale')
    subplot(2, 3, 3)
    imshow(picture_bitmap)
    title('Bitmap')
    subplot(2, 3, 4)
    imshow(picture_rmsmall)
    title('Small Objects Removal')
    subplot(2, 3, 5)
    imshow(background)
    title('Background')
    subplot(2, 3, 6)
    imshow(picture_rmbg)
    title('Background Removal')

    picture = picture_rmbg;

    % Segmentation
    [label_matrix, region_count] = bwlabel(picture);
    regions = regionprops(label_matrix, 'BoundingBox');

    figure('Name', 'Components')
    imshow(picture)
    hold on

    for i = 1:region_count
        rectangle('Position', regions(i).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2)
    end

    hold off

    % Recognition
    matchfig = figure('Name', 'Match');
    characters = [];

    for i = 1:region_count
        [rows, cols] = find(label_matrix == i);
        region = picture(min(rows):max(rows), min(cols):max(cols));
        region = imresize(region, SEGMENT_SIZE);
        imshow(region)
        pause(0.2)

        region_corr = zeros(1, lettersCount);

        for j = 1:lettersCount
            region_corr(j) = corr2(letters{1, j}, region);
        end

        [max_corr, pos] = max(region_corr);

        if max_corr > SEGMENT_THRESHOLD
            out = cell2mat(letters(2, pos));
            characters = [characters out];
        end

    end

    close(matchfig)
end
