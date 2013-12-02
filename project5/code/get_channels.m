function channels = get_channels(img)
%'img' is height x width x 3 (RGB)
%'channels' is height x width x 14, with the 14 channels specified in
%sketch tokens Section 2.2.1

% helpful functions: I = rgbConvert(I,'luv') and imfilter

channels = zeros(size(img, 1), size(img, 2), 14);

luv = rgbConvert(img, 'luv');

channels(:, :, 1:3) = luv;

sigma1 = 0;
sigma2 = 1.5;
sigma3 = 5;

gray = rgb2gray(img); 

gaussian1 = gray;
gaussian2 = imfilter(gray, fspecial('gaussian', sigma2*6, sigma2));
gaussian3 = imfilter(gray, fspecial('gaussian', sigma3*6, sigma3));

sobel = fspecial('sobel');

f1 = sobel;
f2 = imrotate(sobel, 45, 'nearest', 'crop');
f3 = imrotate(sobel, 90, 'nearest', 'crop');
f4 = imrotate(sobel, 135, 'nearest', 'crop');

d11 = imfilter(gaussian1, f1, 'symmetric');
d12 = imfilter(gaussian1, f2, 'symmetric');
d13 = imfilter(gaussian1, f3, 'symmetric');
d14 = imfilter(gaussian1, f4, 'symmetric');
mag1 = sqrt(d11.*d11+d13.*d13);

d21 = imfilter(gaussian2, f1, 'symmetric');
d22 = imfilter(gaussian2, f2, 'symmetric');
d23 = imfilter(gaussian2, f3, 'symmetric');
d24 = imfilter(gaussian2, f4, 'symmetric');
mag2 = sqrt(d21.*d21+d23.*d23);

d31 = imfilter(gaussian3, f1, 'symmetric');
d33 = imfilter(gaussian3, f3, 'symmetric');
mag3 = sqrt(d31.*d31+d33.*d33);

channels(:,:,4) =  mag1     / norm(mag1);
channels(:,:,5) =  mag2     / norm(mag2);
channels(:,:,6) =  mag3     / norm(mag3);
channels(:,:,7) =  abs(d11) / norm(d11);
channels(:,:,8) =  abs(d12) / norm(d12);
channels(:,:,9) =  abs(d13) / norm(d13);
channels(:,:,10) = abs(d14) / norm(d14);
channels(:,:,11) = abs(d21) / norm(d21);
channels(:,:,12) = abs(d22) / norm(d22);
channels(:,:,13) = abs(d23) / norm(d23);
channels(:,:,14) = abs(d24) / norm(d24);

channels = imfilter(channels, fspecial('gaussian', 6, 1));
