function [idx, D, maxD] = knnfast(Qry, Ref, k)
    nr = size(Ref, 1);
    nq = size(Qry, 1);
    lr = sum(Ref .^ 2, 2);
    lq = sum(Qry .^ 2, 2);
    maxD = -1;
    
    idx = zeros(nq, k);
    D = idx;
    
    if (size(Qry, 2) < max(nq, nr))
        if (nq < nr)
            Qry = 2 .* Qry;
        else
            Ref = 2 .* Ref;
        end
        for i = 1:nq
            d = lr + lq(i) - (Ref * Qry(i, :)');
            [srtD, srtIX] = sort(d, 'ascend');
            D(i, :) = srtD(1:k);
            idx(i, :) = srtIX(1:k);
            if (srtD(end) > maxD)
                maxD = srtD(end);
            end
        end
    else
        for i = 1:nq
            d = lr + lq(i) - (2 .* (Ref * Qry(i, :)'));
            [srtD, srtIX] = sort(d, 'ascend');
            D(i, :) = srtD(1:k);
            idx(i, :) = srtIX(1:k);
            if (srtD(end) > maxD)
                maxD = srtD(end);
            end
        end
    end
    
    if (nargout > 1)
        D(D < 0) = 0;
        D = sqrt(D);
    end
    if (nargout > 2)
        maxD = sqrt(maxD);
    end
end