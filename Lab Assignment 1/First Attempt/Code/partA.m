load('Hmodel.mat')
% Hinv = inv(Hmodel);
warped_image = zeros(size(goi1_downsampled));
[M, N] = size(goi1_downsampled);
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
imwrite(warped_image, 'WarpedImage.jpg', 'jpg');
%% 
% Now we have the warped image in warped_image and the orginal image. We
% need to use SIFT to estimate homography.
% [X, Y] = match('goi1_downsampled.jpg', 'goi2_downsampled.jpg');
% [X, Y] = match('goi1_downsampled.jpg', 'WarpedImage.jpg');
% 
% pin = Y';
% pout = X';
% n = size(pin, 2);
% x = pout(1, :); y = pout(2,:); X = pin(1,:); Y = pin(2,:);
% rows0 = zeros(3, n);
% rowsXY = -[X; Y; ones(1,n)];
% hx = [rowsXY; rows0; x.*X; x.*Y; x];
% hy = [rows0; rowsXY; y.*X; y.*Y; y];
% h = [hx hy];
% 
% [U, S, V] = svd(h);
% M = U(:, 9);
% M = reshape(M,3,3)';
% M = M./M(3,3);
% Homography_Matrix = M;
% disp(M)