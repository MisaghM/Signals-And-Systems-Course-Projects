function bounding_boxes = detectplate_aspect(picture_full)
    PLATE_ASPECT_RATIO = 4;
    ERR_MARGIN = 0.8;
    RESIZE_WIDTH = 800;
    BLUE_THOLD = 100;
    AREA_THOLD = 400;

    picture = imresize(picture_full, [NaN, RESIZE_WIDTH]);
    ratio = size(picture_full, 1) / size(picture, 1);

    picture_gray = rgb2gray(picture);
    picture_bitmap = ~imbinarize(picture_gray);

    [label_matrix, region_count] = bwlabel(picture_bitmap);
    regions = regionprops(label_matrix, 'BoundingBox');

    figure('Name', 'Aspect Search')
    imshow(picture_bitmap)
    hold on

    bounding_boxes = [];

    for i = 1:region_count
        region = regions(i);
        w = round(region.BoundingBox(3));
        h = round(region.BoundingBox(4));

        if w * h < AREA_THOLD
            continue
        end

        if w / h > PLATE_ASPECT_RATIO - ERR_MARGIN && ...
                w / h < PLATE_ASPECT_RATIO + ERR_MARGIN
            picture_region = imcrop(picture, region.BoundingBox);

            left_part = picture_region(:, 1:round(0.2 * end), :);
            right_part = picture_region(:, round(0.8 * end):end, :);
            [LR, LG, LB] = imsplit(left_part);
            [RR, RG, RB] = imsplit(right_part);
            left_mask = LB > BLUE_THOLD & LR < BLUE_THOLD & LG < BLUE_THOLD;
            right_mask = RB > BLUE_THOLD & RR < BLUE_THOLD & RG < BLUE_THOLD;

            if nnz(left_mask) / numel(left_mask) > 0.2 && ...
                    nnz(right_mask) / numel(right_mask) < 0.1
                rectangle('Position', region.BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2)
                bbox = [round(region.BoundingBox(1) * ratio), ...
                        round(region.BoundingBox(2) * ratio), ...
                        round(region.BoundingBox(3) * ratio), ...
                        round(region.BoundingBox(4) * ratio)];
                bounding_boxes = [bounding_boxes; bbox];
                continue
            end

            rectangle('Position', region.BoundingBox, 'EdgeColor', 'b', 'LineWidth', 1)
            continue
        end
        rectangle('Position', region.BoundingBox, 'EdgeColor', 'g', 'LineWidth', 1)
    end
end
