clear;
clc;
close all;

addpath(genpath('.\MatlabFns'));

% read in images
im1 = double(imread('./Homography/tajold1_downsampled.jpg'));
im2 = double(imread('./Homography/tajold2_downsampled.jpg'));


% Get N matching point-pairs in P1 and P2
% first column in P1 or P2 = x coordinate, second column = Y coordinate
[N,P1,P2] = match(im1,im2);
X1 = P1(:,1); Y1 = P1(:,2);
X2 = P2(:,1); Y2 = P2(:,2);

option = 2;
if option == 1
    % create a data structure for matrix A
    A = zeros(2*N,9);
    for i=1:2*N
        j = ceil(i/2);
        if mod(i,2) == 1
            A(i,:) = [-X1(j) -Y1(j) -1 0 0 0 X2(j)*X1(j) X2(j)*Y1(j) X2(j)];
        else
            A(i,:) = [0 0 0 -X1(j) -Y1(j) -1 Y2(j)*X1(j) Y2(j)*Y1(j) Y2(j)];
        end
    end

    % solve for h
    [U,S,V] = svd(A);
    h = V(:,9);
    H = reshape(h,3,3)'; H21 = H; % H21 is the transformation applied to im1 so that it aligns with im2
else
   H21 = ransacfithomography([X1 Y1]',[X2 Y2]',1);
end

Q2 = H21*[X1 Y1 ones(N,1)]';
Q2 = Q2';
Q2(:,1) = Q2(:,1)./Q2(:,3);
Q2(:,2) = Q2(:,2)./Q2(:,3);

MSE = sum((Q2(:,1:2)-P2(:,1:2)).^2)/(2*N);
fprintf ('\nMSE = %f',MSE);

% %%%
% for i=1:2*N
%     j = ceil(i/2);
%     if mod(i,2) == 1
%         A(i,:) = [-X2(j) -Y2(j) -1 0 0 0 X1(j)*X2(j) X1(j)*Y2(j) X1(j)];
%     else
%         A(i,:) = [0 0 0 -X2(j) -Y2(j) -1 Y1(j)*X2(j) Y1(j)*Y2(j) Y1(j)];
%     end
% end
% 
% [U,S,V] = svd(A);
% h = V(:,9);
% HH = reshape(h,3,3)'; H12 = HH; % H12 is the transformation applied to im2 so that it aligns with im1
% 
% Q1(:,1) = (HH(1,1)*X2 + HH(1,2)*Y2 + HH(1,3))./(HH(3,1)*X2+HH(3,2)*Y2+HH(3,3));
% Q1(:,2) = (HH(2,1)*X2 + HH(2,2)*Y2 + HH(2,3))./(HH(3,1)*X2+HH(3,2)*Y2+HH(3,3));
% Q1(:,3) = 0;
% MSE = sum((Q1(:,1:2)-P1(:,1:2)).^2)/(2*N);
% fprintf ('\nMSE = %f',MSE);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[W1_1,W2_1] = size(im1);
[W1_2,W2_2] = size(im2);
invH21 = inv(H21);
maxx = -10000;
maxy = -10000;
minx = 10000;
miny = 10000;
for i=1:W1_1
    for j=1:W2_1
        v = H21*[j i 1]';
        v(1:2) = floor(v(1:2)/v(3));
        if v(1) > maxx, maxx = v(1); end;
        if v(2) > maxy, maxy = v(2); end;
        if v(1) < minx, minx = v(1); end;
        if v(2) < miny, miny = v(2); end;
    end
end
maxy = max([ceil(maxy) W1_2]);
maxx = max([ceil(maxx) W2_2]);
minx = min([floor(minx) 0]);
miny = min([floor(miny) 0]);

invH21 = inv(H21);
[W1,W2] = size(im1);
warped_im1 = zeros(maxy-miny+2,maxx-minx+2); warped_im1(:,:) = -1;
[newW1,newW2] = size(warped_im1);
for i=miny:maxy
    for j=minx:maxx
        v = invH21*[j i 1]';
        v(1:2) = floor(v(1:2)/v(3));
        if (v(2) >= 1 && v(1) >= 1 && v(2) <= W1_1 && v(1) <= W2_1), warped_im1(i-miny+1,j-minx+1) = im1(v(2),v(1)); end;
    end
end

figure(1); imshow(im1/255);
figure(2); imshow(im2/255);
figure(3); imshow(warped_im1/255);

[yy,xx] = find(warped_im1 < 0);
ly = length(yy);
for i=1:ly
   if yy(i)+miny-1 >= 1 && xx(i)+minx-1 >= 1  && yy(i)+miny-1 <= W1_2 && xx(i)+minx-1 <= W2_2 && warped_im1(yy(i),xx(i)) == -1
    warped_im1(yy(i),xx(i)) = im2(yy(i)+miny-1,xx(i)+minx-1); 
   end
end

figure(4); imshow(warped_im1/255);

