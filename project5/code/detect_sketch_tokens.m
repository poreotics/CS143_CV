function pb = detect_sketch_tokens(img, forest, feature_params)

% 'img' is a test image.
% 'forest' is the structure returned by 'forestTrain'.

% 'pb' is the probability of boundary for every pixel.

%feature_params.CR = radius of the channel-derived patches. E.g. radius of
%7 would imply 15x15 features. The other entries of feature_params are for
%calling 'compute_daisy', which you probably don't need here (unless you've
%decided to use the DAISY descriptor as an image feature, which might be a
%decent idea).

[height, width, cc] = size(img);
num_sketch_tokens = max(forest(1).hs) - 1; %-1 for background class

patch_radius = feature_params.CR;
patch_size = patch_radius * 2 + 1;

img_pad = imPad(img, patch_radius, 'symmetric');
channels = get_channels(img_pad);

features = single(zeros(width * height, patch_size * patch_size * 14));
index = 1;
for row = 1:height
    for col = 1:width
        patch = channels(row:row+patch_size-1, col:col+patch_size-1, :);
        features(index, :) = patch(:);
        index = index + 1;
    end
end

[hs, ps] = forestApply(features, forest);
pb = 1 - ps(:, 1);
pb = reshape(pb, width, height)';

pb = imfilter(pb, fspecial('gaussian', 9, 1.5));

pb = stToEdges(pb);

% Stack all of the image features into one matrix. This will be redundant
% (a single pixel will appear in many patches) but it will be faster than
% calling 'forestApply' for every single pixel.

% Call 'forestApply', use the resulting probabilities to build the output
% 'pb'
