% Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% Returns a set of interest points for the input image

% 'image' can be grayscale or color, your choice.
% 'feature_width', in pixels, is the local feature width. It might be
%   useful in this function in order to (a) suppress boundary interest
%   points (where a feature wouldn't fit entirely in the image, anyway)
%   or(b) scale the image filters being used. Or you can ignore it.

% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
% 'confidence' is an nx1 vector indicating the strength of the interest
%   point. You might use this later or not.
% 'scale' and 'orientation' are nx1 vectors indicating the scale and
%   orientation of each interest point. These are OPTIONAL. By default you
%   do not need to make scale and orientation invariant local features.
function [x, y, confidence, scale, orientation] = get_interest_points(image, feature_width)

sigma = 3;
alpha = 0.04;
threshold = 0.02;

g = fspecial('gaussian', 4*sigma+1, sigma);
sobel = fspecial('sobel');

image = imfilter(image, fspecial('gaussian'));

ix = imfilter(image, sobel');
iy = imfilter(image, sobel);

gix2 = imfilter(ix .* ix, g);
giy2 = imfilter(iy .* iy, g);
gixy = imfilter(ix .* iy, g);

corner = gix2 .* giy2 - gixy .* gixy - alpha * (gix2 + giy2) .* (gix2 + giy2);

corner(1:feature_width, :) = 0;
corner(end-feature_width:end, :) = 0;
corner(:, 1:feature_width) = 0;
corner(:, end-feature_width:end) = 0;

maxvalue = max(max(corner));
corner = corner .* (corner > threshold * maxvalue);

result = colfilt(corner, [3 3], 'sliding', inline('max(x)'));
corner = corner .* (corner == result);

[y, x] = find(corner);

imshow(image);
hold on;
plot(x , y, 'r.');
hold off;

end

