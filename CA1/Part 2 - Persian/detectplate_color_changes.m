function boundingBoxes = detectplate_color_changes(picture, filter_by_aspect_ratio)
    GRAYSCALE_COLOR_CHANGE_THRESHOLD = 40;
    ROW_SIDE_ERROR = 10;
    BLUE_VALUE_THRESHOLD = 180;
    COMPONENT_MINIMUM_HEIGHT_PERCENTAGE = 0.05;
    SMALL_OBJECT_AREA = double(int32(size(picture, 1) * size(picture, 2) * 0.0001));
    BINARIZE_SENSITIVITY = 0.5;
    REGION_ASPECT_RATIO_THRESHOLDS = [0.4 6];
    MERGEABLE_REGIONS_DISTANCE_THRESHOLD = 0.02 * size(picture, 2);

    if nargin < 2
        filter_by_aspect_ratio = false;
    end

    pictureGray = rgb2gray(picture);
    colorChanges = zeros(1, size(pictureGray, 1));
    colorChangesCount = zeros(1, size(pictureGray, 1));

    for i = 1:size(pictureGray, 1)
        sumRowColorChange = 0;
        rowColorChangeCount = 0;
        for j = 2:size(pictureGray, 2)
            if abs(pictureGray(i, j) - pictureGray(i, j - 1)) > GRAYSCALE_COLOR_CHANGE_THRESHOLD
                sumRowColorChange = sumRowColorChange + abs(pictureGray(i, j) - pictureGray(i, j - 1));
                rowColorChangeCount = rowColorChangeCount + 1;
            end
        end
        colorChanges(i) = sumRowColorChange;
        colorChangesCount(i) = rowColorChangeCount;
    end

    avgColorChange = mean(colorChanges);
    avgColorChangeCount = mean(colorChangesCount);

    nonEmptyRows = zeros(1, size(picture, 1));
    for i = ROW_SIDE_ERROR + 1:size(picture, 1) - ROW_SIDE_ERROR
        % ignore rows which don't contain blue
        maxBlue = 0;
        for j = 1:size(picture, 2)
            if picture(i, j, 3) > maxBlue
                maxBlue = picture(i, j, 3);
            end
        end
        if colorChanges(i) > avgColorChange && colorChangesCount(i) > avgColorChangeCount &&...
            maxBlue > BLUE_VALUE_THRESHOLD
            for j = i - ROW_SIDE_ERROR:i + ROW_SIDE_ERROR
                nonEmptyRows(j) = 1;
            end
        end
    end

    picture = pictureGray;

    nonEmptyRows = logical(nonEmptyRows);

    modifiedPicture = imbinarize(picture, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', BINARIZE_SENSITIVITY);
    modifiedPicture(~nonEmptyRows, :) = 0;
    modifiedPicture = bwareaopen(modifiedPicture, SMALL_OBJECT_AREA);

    % plot the image
    figure('Name', 'Color Change Search')
    subplot(1, 3, 1)
    imshow(picture)
    title('Original')
    subplot(1, 3, 2)
    imshow(picture)
    hold on
    for i = 1:size(picture, 1)
        if nonEmptyRows(i)
            plot([1 size(picture, 2)], [i i], 'r')
        end
    end
    hold off
    title('Selected Rows')
    subplot(1, 3, 3)
    imshow(modifiedPicture)
    title('Empty Rows Removed')

    [label_matrix, regionCount] = bwlabel(modifiedPicture);
    regions = regionprops(label_matrix, 'BoundingBox');

    if filter_by_aspect_ratio
        % ignore the regions that do not have the correct aspect ratio
        newRegions = [];
        figure('Name', 'Regions')
        imshow(modifiedPicture)
        hold on
        for i = 1:regionCount
            aspectRatio = regions(i).BoundingBox(3) / regions(i).BoundingBox(4);
            heightPercentage = regions(i).BoundingBox(4) / size(picture, 1);
            if heightPercentage < COMPONENT_MINIMUM_HEIGHT_PERCENTAGE ||...
                aspectRatio < REGION_ASPECT_RATIO_THRESHOLDS(1) ||...
                aspectRatio > REGION_ASPECT_RATIO_THRESHOLDS(2)
                rectangle('Position', regions(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 1)
                continue
            end
            newRegions = [newRegions regions(i)];
            rectangle('Position', regions(i).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 1)
        end
        hold off

        regions = newRegions;
    else
        regions = regions';
    end

    boundingBoxes = [];
    if size(regions, 2) == 0
        return
    end

    % merge regions which are close to each other
    mergedRegions = [];
    for i = 1:size(regions, 2)
        if size(mergedRegions, 2) == 0
            mergedRegions = [mergedRegions regions(i)];
            continue
        end
        merged = false;
        for j = 1:size(mergedRegions, 2)
            if abs(mergedRegions(j).BoundingBox(1) + mergedRegions(j).BoundingBox(3) - regions(i).BoundingBox(1)) < MERGEABLE_REGIONS_DISTANCE_THRESHOLD &&...
                (abs(mergedRegions(j).BoundingBox(2) + mergedRegions(j).BoundingBox(4) - regions(i).BoundingBox(2)) < MERGEABLE_REGIONS_DISTANCE_THRESHOLD ||...
                abs(mergedRegions(j).BoundingBox(2) - regions(i).BoundingBox(2) - regions(i).BoundingBox(4)) < MERGEABLE_REGIONS_DISTANCE_THRESHOLD ||...
                abs(mergedRegions(j).BoundingBox(2) - regions(i).BoundingBox(2)) < MERGEABLE_REGIONS_DISTANCE_THRESHOLD ||...
                abs(mergedRegions(j).BoundingBox(2) + mergedRegions(j).BoundingBox(4) - regions(i).BoundingBox(2) - regions(i).BoundingBox(4)) < MERGEABLE_REGIONS_DISTANCE_THRESHOLD ||...
                (mergedRegions(j).BoundingBox(2) > regions(i).BoundingBox(2) && mergedRegions(j).BoundingBox(2) + mergedRegions(j).BoundingBox(4) < regions(i).BoundingBox(2) + regions(i).BoundingBox(4)) ||...
                (mergedRegions(j).BoundingBox(2) < regions(i).BoundingBox(2) && mergedRegions(j).BoundingBox(2) + mergedRegions(j).BoundingBox(4) > regions(i).BoundingBox(2) + regions(i).BoundingBox(4)))
                mergedRegions(j).BoundingBox(1) = min(regions(i).BoundingBox(1), mergedRegions(j).BoundingBox(1));
                mergedRegions(j).BoundingBox(3) = max(regions(i).BoundingBox(1) + regions(i).BoundingBox(3), mergedRegions(j).BoundingBox(1) + mergedRegions(j).BoundingBox(3)) - mergedRegions(j).BoundingBox(1);
                mergedRegions(j).BoundingBox(2) = min(regions(i).BoundingBox(2), mergedRegions(j).BoundingBox(2));
                mergedRegions(j).BoundingBox(4) = max(regions(i).BoundingBox(2) + regions(i).BoundingBox(4), mergedRegions(j).BoundingBox(2) + mergedRegions(j).BoundingBox(4)) - mergedRegions(j).BoundingBox(2);
                merged = true;
                break
            end
        end
        if ~merged
            mergedRegions = [mergedRegions regions(i)];
        end
    end

    regions = mergedRegions;

    % merge overlapping regions
    mergedRegions = [];
    for i = 1:size(regions, 2)
        if size(mergedRegions, 2) == 0
            mergedRegions = [mergedRegions regions(i)];
            continue
        end
        merged = false;
        for j = 1:size(mergedRegions, 2)
            if regions(i).BoundingBox(1) > mergedRegions(j).BoundingBox(1) &&...
                regions(i).BoundingBox(1) < mergedRegions(j).BoundingBox(1) + mergedRegions(j).BoundingBox(3) &&...
                ~(regions(i).BoundingBox(2) > mergedRegions(j).BoundingBox(2) + mergedRegions(j).BoundingBox(4) ||...
                regions(i).BoundingBox(2) + regions(i).BoundingBox(4) < mergedRegions(j).BoundingBox(2)) ||...
                regions(i).BoundingBox(1) + regions(i).BoundingBox(3) > mergedRegions(j).BoundingBox(1) &&...
                regions(i).BoundingBox(1) + regions(i).BoundingBox(3) < mergedRegions(j).BoundingBox(1) + mergedRegions(j).BoundingBox(3) &&...
                ~(regions(i).BoundingBox(2) > mergedRegions(j).BoundingBox(2) + mergedRegions(j).BoundingBox(4) ||...
                regions(i).BoundingBox(2) + regions(i).BoundingBox(4) < mergedRegions(j).BoundingBox(2))
                mergedRegions(j).BoundingBox(1) = min(regions(i).BoundingBox(1), mergedRegions(j).BoundingBox(1));
                mergedRegions(j).BoundingBox(3) = max(regions(i).BoundingBox(1) + regions(i).BoundingBox(3), mergedRegions(j).BoundingBox(1) + mergedRegions(j).BoundingBox(3)) - mergedRegions(j).BoundingBox(1);
                mergedRegions(j).BoundingBox(2) = min(regions(i).BoundingBox(2), mergedRegions(j).BoundingBox(2));
                mergedRegions(j).BoundingBox(4) = max(regions(i).BoundingBox(2) + regions(i).BoundingBox(4), mergedRegions(j).BoundingBox(2) + mergedRegions(j).BoundingBox(4)) - mergedRegions(j).BoundingBox(2);
                merged = true;
                break
            end
        end
        if ~merged
            mergedRegions = [mergedRegions regions(i)];
        end
    end

    regions = mergedRegions;

    % plot the regions
    figure('Name', 'Merged Regions')
    imshow(picture)
    hold on
    for i = 1:size(regions, 2)
        rectangle('Position', regions(i).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 1)
    end
    hold off
    
    for i = 1:size(regions, 2)
        boundingBoxes = [boundingBoxes; regions(i).BoundingBox];
    end
end
