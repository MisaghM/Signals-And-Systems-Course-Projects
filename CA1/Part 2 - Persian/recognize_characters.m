function characters = recognize_characters(picture, letters, lettersCount)
    SMALL_OBJECT_AREA = 400;
    BACKGROUND_AREA = 6500;
    SEGMENT_SIZE = [100 80];
    SEGMENT_THRESHOLD = 0.45;
    BINARIZE_SENSITIVITY = 0.4;

    % preprocess the image
    picture = rgb2gray(picture);
    picture = imbinarize(picture, "adaptive", "ForegroundPolarity", "dark", "Sensitivity", BINARIZE_SENSITIVITY);

    % Remove Background and Small Objects
    picture_rmsmall = bwareaopen(picture, SMALL_OBJECT_AREA);
    background = bwareaopen(picture_rmsmall, BACKGROUND_AREA);
    %picture_rmbg = picture_rmsmall - background;
    picture_rmbg = picture_rmsmall;

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

    % Segmentation
    [label_matrix, region_count] = bwlabel(picture);
    regions = regionprops(label_matrix, 'BoundingBox');

    figure('Name', 'Components')
    imshow(picture)
    hold on

    for i = 1:region_count
        rectangle('Position', regions(i).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 1)
    end

    hold off

    % Recognition
    figure('Name', 'Match')
    characters = [];

    for i = 1:region_count
        [rows, cols] = find(label_matrix == i);
        region = picture(min(rows):max(rows), min(cols):max(cols));
        imshow(region)
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

    close
end
