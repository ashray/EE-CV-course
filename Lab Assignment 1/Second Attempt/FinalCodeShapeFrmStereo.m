close all
I1 = rgb2gray(imread('view1.png'));
I2 = rgb2gray(imread('view5.png'));

%%
% Input Images
imshowpair(I1, I2,'montage');
title('I1 (left); I2 (right)');
figure;
imshowpair(I1,I2,'ColorChannels','red-cyan');
title('Composite Image (Red - Left Image, Cyan - Right Image)');

%%
% Detect features
blobs1 = detectSURFFeatures(I1, 'MetricThreshold', 2000);
blobs2 = detectSURFFeatures(I2, 'MetricThreshold', 2000);

%%
% Displaying region of interests
figure;
imshow(I1);
hold on;
plot(selectStrongest(blobs1, 30));
title('Thirty strongest SURF features in I1');

figure;
imshow(I2);
hold on;
plot(selectStrongest(blobs2, 30));
title('Thirty strongest SURF features in I2');

%%
% Extract features
[features1, validBlobs1] = extractFeatures(I1, blobs1);
[features2, validBlobs2] = extractFeatures(I2, blobs2);

indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD', ...
  'MatchThreshold', 5);

matchedPoints1 = validBlobs1(indexPairs(:,1),:);
matchedPoints2 = validBlobs2(indexPairs(:,2),:);

figure;
showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2);
legend('Putatively matched points in I1', 'Putatively matched points in I2');

%%

[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'RANSAC', ...
  'NumTrials', 10000, 'DistanceThreshold', 0.1, 'Confidence', 99.99);

inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

figure;
showMatchedFeatures(I1, I2, inlierPoints1, inlierPoints2);
legend('Inlier points in I1', 'Inlier points in I2');

%%
[t1, t2] = estimateUncalibratedRectification(fMatrix, ...
  inlierPoints1.Location, inlierPoints2.Location, size(I2));
tform1 = projective2d(t1);
tform2 = projective2d(t2);

%%
I1Rect = imwarp(I1, tform1, 'OutputView', imref2d(size(I1)));
I2Rect = imwarp(I2, tform2, 'OutputView', imref2d(size(I2)));

% transform the points to visualize them together with the rectified images
pts1Rect = transformPointsForward(tform1, inlierPoints1.Location);
pts2Rect = transformPointsForward(tform2, inlierPoints2.Location);

figure;
showMatchedFeatures(I1Rect, I2Rect, pts1Rect, pts2Rect);
legend('Inlier points in rectified I1', 'Inlier points in rectified I2');

%%
% Now we have I1Rect and I2Rect. To search for a corresponding point, we
% will search for areas say -10 to +10 pixel differences.
%
% Let us consider a window size of k*k pixels.
%
% Since these are rectified images, we know that we only have to search on
% a horizontal line.
m = 10;
window_size = 3;
[M,N] = size(I1Rect);
disp_generated = zeros(M,N);
loop_disp = zeros(2*m+1,1);
h = waitbar(0,'Please wait...');
for j = 1:M
    for k = 1:N
        for i = -m:m
            if(((j+i)>1)&&((j+i+window_size)<M)&&((j+window_size)<M)&&((k+window_size)<N))
                small1 = I1Rect((j+i):(j+i+window_size), (k):(k+window_size));
                small2 = I2Rect((j:j+window_size), (k:k+window_size));
                loop_disp(i+m+1) = sumsqr(small1-small2);
            end
        end
        index = find(loop_disp == min(loop_disp(:)));
        % index will be a number between 1 to 2m+1
        disp_generated(j,k) = index(1)-m-1;
        loop_disp = zeros(2*m+1,1);
        index = 0;
        waitbar(j / M);
    end
end

% Observe disp_generated