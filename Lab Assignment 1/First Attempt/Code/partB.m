
[X, Y] = match('goi1_downsampled.jpg', 'goi2_downsampled.jpg');
pin = Y';
pout = X';
n = size(pin, 2);
x = pout(1, :); y = pout(2,:); X = pin(1,:); Y = pin(2,:);
rows0 = zeros(3, n);
rowsXY = -[X; Y; ones(1,n)];
hx = [rowsXY; rows0; x.*X; x.*Y; x];
hy = [rows0; rowsXY; y.*X; y.*Y; y];
h = [hx hy];

[U, S, V] = svd(h);
M = U(:, 9);
M = reshape(M,3,3)';
M = M./M(3,3);
Homography_Matrix = M;
disp(M)
%%
% M is the homography matrix. We use technique similar to part A to warp
% the first image to second.
warped_image = zeros(size(goi1_downsampled));
[M, N] = size(goi1_downsampled);
Hmodel = Homography_Matrix;
for i = 1:M
    for j=1:N
        new_coordinates = Hmodel/[i, j, 1];
        new_coordinates = new_coordinates';
        new_coordinates = new_coordinates./new_coordinates(1,3);
        new_coordinates = round(new_coordinates);
        if ((0< new_coordinates(1))&& (new_coordinates(1) < M) && (0< new_coordinates(2))&& (new_coordinates(2) < N))
            warped_image(i,j) = goi1_downsampled(new_coordinates(1), new_coordinates(2));
        end
    end
end

subplot(1,3,1); imshow('goi1_downsampled.jpg'); title('goi1Downsampled')
subplot(1,3,2); imshow('goi2_downsampled.jpg'); title('goi2Downsampled')
subplot(1,3,3); imshow(warped_image/255); title('First Image Warped onto Second')