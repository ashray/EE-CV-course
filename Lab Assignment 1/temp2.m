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
