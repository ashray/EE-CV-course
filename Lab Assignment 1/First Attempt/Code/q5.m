clc
clear all
close all
addpath('./Homography');
% Calculate the salient points using SIFT
im1 = 'tajnew1_downsampled.jpg';
im2 = 'tajnew2_downsampled.jpg';

[im1, des1, loc1] = sift(im1);
[im2, des2, loc2] = sift(im2);

match = zeros(size(des1,1),1);
distRatio = 0.6;   

% For each descriptor in the first image, select its match to second image.
des2t = des2';                          % Precompute matrix transpose
for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end

number_of_matches = sum(sum(match > 0))
num = number_of_matches;
P1 = zeros(num,2);
P2 = zeros(num,2);
j=1;
for i = 1: size(des1,1)
  if (match(i) > 0)
    P1(j,:) = loc1(i,1:2);
    P2(j,:) = loc2(i,1:2);
    j=j+1;
  end
end
P1 = P1';
P2 = P2';
