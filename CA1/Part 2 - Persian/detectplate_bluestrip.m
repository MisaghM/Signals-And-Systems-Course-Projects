function bounding_box = detectplate_bluestrip(picture_full, open_figure)
    BLUESTRIP_FILE = 'bluestrip.png';
    BLUESTRIP_BIG_FILE = 'bluestrip_big.png';
    RESIZE_WIDTH = 800;
    ERR_MARGIN = 10;
    BLUE2PLATE_RATIO = 14;
    SUCCESS_THRESHOLD = 0.5;

    if nargin < 2
        open_figure = true;
    end

    if ~exist(BLUESTRIP_FILE, 'file') || ~exist(BLUESTRIP_BIG_FILE, 'file')
        error('Blue strip image file not found.')
    end

    bluestrip = imread(BLUESTRIP_FILE);
    bluestrip_big = imread(BLUESTRIP_BIG_FILE);

    picture = imresize(picture_full, [NaN, RESIZE_WIDTH]);
    ratio = size(picture_full, 1) / size(picture, 1);

    [corr_mix, corr_max, bbox] = rgb_corr2(bluestrip, picture);

    if size(picture, 1) > size(bluestrip_big, 1)
        [corr_mixB, corr_maxB, bboxB] = rgb_corr2(bluestrip_big, picture);
        if corr_maxB > corr_max
            [corr_mix, corr_max, bbox] = deal(corr_mixB, corr_maxB, bboxB);
        end
    end

    bbox_full = [round((bbox(1) - ERR_MARGIN) * ratio), ...
                round((bbox(2) - ERR_MARGIN) * ratio), ...
                round((bbox(3) + 2 * ERR_MARGIN) * ratio), ...
                round((bbox(4) + 2 * ERR_MARGIN) * ratio)];

    bounding_box = bbox_full;
    bounding_box(3) = BLUE2PLATE_RATIO * bbox(3) * ratio;

    if open_figure
        figure('Name', 'Blue Strip Search');
        subplot(2, 2, 1)
        imshow(picture)
        title('Picture')
        subplot(2, 2, 2)
        imshow(bluestrip)
        title('Template')
        subplot(2, 2, 3)
        imshow(corr_mix, [])
        title('Correlation')
        subplot(2, 2, 4)
        imshow(picture_full)
        hold on
        rectangle('Position', bbox_full, 'edgecolor', 'r', 'linewidth', 2);
        rectangle('Position', bounding_box, 'edgecolor', 'g', 'linewidth', 1);
        if corr_max < SUCCESS_THRESHOLD
            title('Match [Failed]')
        else
            title('Match [Success]')
        end
    end

    if corr_max < SUCCESS_THRESHOLD
        bounding_box = [];
    end
end

function [corr_mix, corr_max, bbox] = rgb_corr2(template, pic)
    corrRed = normxcorr2(template(:, :, 1), pic(:, :, 1));
    corrGrn = normxcorr2(template(:, :, 2), pic(:, :, 2));
    corrBlu = normxcorr2(template(:, :, 3), pic(:, :, 3));
    corr_mix = (corrRed + corrGrn + corrBlu) / 3;

    [corr_max, corrIdx] = max(abs(corr_mix(:)));
    [peakY, peakX] = ind2sub(size(corr_mix), corrIdx(1));
    corr_offset = [peakX - size(template, 2), peakY - size(template, 1)];
    bbox = [corr_offset(1), corr_offset(2), size(template, 2), size(template, 1)];
end
