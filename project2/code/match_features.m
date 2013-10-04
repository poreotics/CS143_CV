% Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% 'features1' and 'features2' are the n x feature dimensionality features
%   from the two images.
% If you want to include geometric verification in this stage, you can add
% the x and y locations of the features as additional inputs.
%
% 'matches' is a k x 2 matrix, where k is the number of matches. The first
%   column is an index in features 1, the second column is an index
%   in features2. 
% 'Confidences' is a k x 1 matrix with a real valued confidence for every
%   match.
% 'matches' and 'confidences' can empty, e.g. 0x2 and 0x1.
function [matches, confidences] = match_features(features1, features2)

% This function does not need to be symmetric (e.g. it can produce
% different numbers of matches depending on the order of the arguments).

% To start with, simply implement the "ratio test", equation 4.18 in
% section 4.1.3 of Szeliski. For extra credit you can implement various
% forms of spatial verification of matches.

% Placeholder that you can delete. Random matches and confidences
num_features1 = size(features1, 1);
num_features2 = size(features2, 1);

max_size = min(num_features1, num_features2);

if num_features1 > num_features2
    tmp = features1;
    features1 = features2;
    features2 = tmp;
end

matches = zeros(max_size, 2);
confidences = zeros(max_size, 1);

match_index = 1;

for i = 1:num_features1
    distances = zeros(num_features2, 1);
    for j = 1:num_features2
        distances(j) = norm(features1(i) - features2(j));
    end
    [sorted_distances, idx] = sort(distances);
    if sorted_distances(2) > 0
        ratio = sorted_distances(1) / sorted_distances(2);
        if ratio < 0.8
            matches(match_index, :) = [i, idx(1)];
            confidences(match_index) = 1 - ratio;
            match_index = match_index + 1;
        end
    end
end

matches(match_index:end, :) = [];
confidences(match_index:end, :) = [];

% Sort the matches so that the most confident onces are at the top of the
% list. You should probably not delete this, so that the evaluation
% functions can be run on the top matches easily.
[confidences, ind] = sort(confidences, 'descend');
matches = matches(ind,:);