function [img_features, labels] = ... 
    get_sketch_tokens(train_img_dir, train_gt_dir, feature_params, num_sketch_tokens)

% 'img_features' is N x feature dimension. You probably want it to be
% 'single' precision to save memory. 
% 'labels' is N x 1. labels(i) = 1 implies non-boundary, labels(i) = 2
% implies boundary or sketch token 1, labels(i) = 3 implies sketch token 2,
% etc... max(labels) should be num_sketch_tokens + 1;

%feature_params.CR = radius of the channel-derived patches. E.g. radius of
%7 would imply 15x15 features. The other entries of feature_params are for
%calling 'compute_daisy', but the starter code simply has the default
%DAISY values (which do work OK).

train_imgs = dir( fullfile( train_img_dir, '*.jpg' ));
num_imgs = length(train_imgs); % You don't need to sample them all while debugging.

num_samples = 100000;
pos_ratio   = 0.5;

pos_samples = num_samples * pos_ratio;
neg_samples = num_samples - pos_samples;

pos_samples_per_image = pos_samples / num_imgs;
neg_samples_per_image = neg_samples / num_imgs;

daisy_radius = feature_params.R;
daisy_feature_dims = feature_params.RQ * feature_params.TQ * feature_params.HQ + feature_params.HQ;
sketch_features = zeros(num_samples, daisy_feature_dims, 'single');

feature_radius = feature_params.CR;
feature_size = feature_radius * 2 + 1;
  
pad_radius = max(feature_radius, daisy_radius);

labels = zeros(num_samples, 1);
img_features = zeros(num_samples, feature_size * feature_size * 14, 'single');

index = 1;
for i = 1:num_imgs
    fprintf(' Sampling patches / annotations from %s\n', train_imgs(i).name);
    [cur_pathstr, cur_name, cur_ext] = fileparts(train_imgs(i).name);
    cur_img = imread(fullfile(train_img_dir, train_imgs(i).name));
    cur_img = im2single(cur_img);
    cur_gt = zeros(size(cur_img, 1), size(cur_img, 2));
    
    annotation_struct  = load(fullfile(train_gt_dir, [cur_name '.mat']));
    num_gt = 2; % length(annotation_struct.groundTruth);
    
    for j = 1:num_gt
        cur_gt = single(annotation_struct.groundTruth{j}.Boundaries); 
        
        [pos_row, pos_col] = find(cur_gt);
        [neg_row, neg_col] = find(cur_gt == 0);

        num_pos_samples = min(size(pos_row, 1), uint32(pos_samples_per_image / num_gt));
        pos_index = randperm(size(pos_row, 1), num_pos_samples);

        num_neg_samples = min(size(neg_row, 1), uint32(neg_samples_per_image / num_gt));
        neg_index = randperm(size(neg_row, 1), num_neg_samples);

        image_height = size(cur_img, 1);
        image_width = size(cur_img, 2);

        channels = get_channels(imPad(cur_img, pad_radius, 'symmetric'));
        pad_gt = imPad(cur_gt, pad_radius, 'symmetric');
        daisy = compute_daisy(pad_gt);

        for i = 1:num_pos_samples
            y = pos_row(pos_index(i));
            x = pos_col(pos_index(i));

            patch = channels(y-feature_radius+pad_radius : y+feature_radius+pad_radius, ...
                x-feature_radius+pad_radius : x+feature_radius+pad_radius, :);
            img_features(index, :) = patch(:);

            sketch_patch = get_descriptor(daisy, y+pad_radius, x+pad_radius);
            sketch_features(index, :) = sketch_patch(:);

            labels(index) = 2;
            index = index + 1;
        end

        for i = 1:num_neg_samples
            y = neg_row(neg_index(i));
            x = neg_col(neg_index(i));

            patch = channels(y-feature_radius+pad_radius : y+feature_radius+pad_radius, ...
                x-feature_radius+pad_radius : x+feature_radius+pad_radius, :);
            img_features(index, :) = patch(:);

            labels(index) = 1;
            index = index + 1;
        end
    end
end

img_features(index:end, :) = [];
labels(index:end, :) = [];
sketch_features(index:end, :) = [];

sketch_indices = labels > 1;

[centers, assighments] = vl_kmeans(sketch_features(sketch_indices)', num_sketch_tokens);

labels(sketch_indices) = assighments + 1;

