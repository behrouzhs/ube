function [W, idx, D, maxD] = buildNNgraph(data, k, weightMode)
    if (exist('weightMode', 'var') == 0)
        weightMode = 'binary';
    end
    mink = 2;
    
    [idx, D, maxD] = knnfast(data, data, k + 1);

    Dtemp = D(:, 2:end);
    mn = min(min(Dtemp));
    md = median(Dtemp(:));
    ix = Dtemp > (md + (0.6666 * (md - mn)));
    ix = logical([zeros(size(D, 1), mink+1) ix(:, mink+1:end)]);
    D(ix) = 0;
    idx(ix) = 0;
    
    S = D ./ maxD;
    switch weightMode
        case {'binary', 'Binary', 'bin'}
            W = sparseBuild(idx);
        case {'similarity', 'Similarity', 'sim'}
            S(idx > 0) = 1 - S(idx > 0);
            W = sparseBuild(idx, S);
        case {'gaussian', 'Gaussian', 'gauss'}
            S(idx > 0) = exp(-(S(idx > 0) .^ 2));
            W = sparseBuild(idx, S);
        otherwise
            W = sparseBuild(idx);
    end
end