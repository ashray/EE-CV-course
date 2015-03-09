function []  = seepoint(im1,im2,common1,common2,index)
    ind1 = uint16(common1(index,:));
    ind2 = uint16(common2(index,:));
    l1x = size(im1,2);
    l1y = size(im1,1);
    l2x = size(im2,2);
    l2y = size(im2,1);
    
    w = 3;
    bandy1 = max(ind1(1)-w,0):min(ind1(1)+w,l1y);
    bandx1 = max(ind1(2)-w,0):min(ind1(2)+w,l1x);
    bandy2 = max(ind2(1)-w,0):min(ind2(1)+w,l2y);
    bandx2 = max(ind2(2)-w,0):min(ind2(2)+w,l2x);

    figure()
    red1 = im1;
    green1 = im1;
    blue1 = im1;    
    red1(bandy1,bandx1) = 255;
    green1(bandy1,bandx1) = 0;
    blue1(bandy1,bandx1) = 0;
    final1 = cat(3,red1,green1,blue1);
    imshow(final1);
    
    figure()
    red2 = im2;
    green2 = im2;
    blue2 = im2;    
    red2(bandy2,bandx2) = 255;
    green2(bandy2,bandx2) = 0;
    blue2(bandy2,bandx2) = 0;
    final2 = cat(3,red2,green2,blue2);
    imshow(final2);    
end