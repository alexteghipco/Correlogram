function [bcR, p] = pdc(x,y,z)
    [xy, ~, ~, ~] = bcdistcorr(x, y);
    [xz, ~, ~, ~] = bcdistcorr(x, z);
    [zy, ~, ~, ~] = bcdistcorr(z, y);
    p1 = xy-xz*zy;
    p2 = (1-xz^2)^0.5*(1-zy^2)^0.5;
    if p1 == 0
        bcR = 0;
    else
        bcR = p1/p2;
    end
    p = 1-chi2cdf(bcR*size(x,1)+1,1);
end