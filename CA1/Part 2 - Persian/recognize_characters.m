function characters = recognize_characters(picture, letters)
    RESIZE_WIDTH = 800;
    SMALL_OBJECT_AREA = 200;
    BACKGROUND_AREA = 7000;
    SEGMENT_SIZE = [100, 80];
    SEGMENT_THRESHOLD = 0.5;
    BINARIZE_SENSITIVITY = 0.4;
    LONG_ASPECT = 4;
    SMALL_AREA = 1000;

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
    label_matrix = bwlabel(picture);
    regions = regionprops(label_matrix, 'BoundingBox');

    figure('Name', 'Components')
    imshow(picture)
    hold on

    i = 1;
    while i <= size(regions, 1)
        w = regions(i).BoundingBox(3);
        h = regions(i).BoundingBox(4);
        area = imcrop(picture, regions(i).BoundingBox);

        if w / h > LONG_ASPECT || h / w > LONG_ASPECT || ...
           (w * h < SMALL_AREA && nnz(area) / numel(area) < 0.3)
            rectangle('Position', regions(i).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 1)
            regions(i) = [];
        else
            rectangle('Position', regions(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 1)
            i = i + 1;
        end
    end

    hold off

    % Recognition
    matchfig = figure('Name', 'Match');
    characters = [];

    for i = 1:size(regions, 1)
        region = imcrop(picture, regions(i).BoundingBox);
        region = imresize(region, SEGMENT_SIZE);
        imshow(region)

        region_corr_num = zeros(1, size(letters.numbers, 2));
        region_corr_alp = zeros(1, size(letters.alphabet, 2));

        for j = 1:size(letters.numbers, 2)
            region_corr_num(j) = corr2(letters.numbers{1, j}, region);
        end
        for j = 1:size(letters.alphabet, 2)
            region_corr_alp(j) = corr2(letters.alphabet{1, j}, region);
        end

        [max_corr_num, pos_num] = max(region_corr_num);
        [max_corr_alp, pos_alp] = max(region_corr_alp);
        [max_corr, p] = max([max_corr_num, max_corr_alp]);

        if max_corr > SEGMENT_THRESHOLD
            if p == 1
                out = cell2mat(letters.numbers(2, pos_num));
            else
                out = cell2mat(letters.alphabet(2, pos_alp));
            end
            characters = [characters out];
        end
    end

    close(matchfig)
end
