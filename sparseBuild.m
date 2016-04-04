function W = sparseBuild(idx, D, n2)
    if (sum(sum(idx == 0)) == 0)
        [n1, k] = size(idx);
        if (exist('n2', 'var') == 0)
            n2 = n1;
        end

        ir = zeros(1, n1*k);
        ic = zeros(1, n1*k);
        wv = ones(1, n1*k);

        for i = 1:n1
            ir((i-1)*k+1:i*k) = repmat(i, 1, k);
            ic((i-1)*k+1:i*k) = idx(i, :);
        end
        if (exist('D', 'var') ~= 0 && (numel(D) == n1*k))
            for i = 1:n1
                wv((i-1)*k+1:i*k) = D(i, :);
            end
        end
        W = sparse(ir, ic, wv, n1, n2);
    else
        [n, k] = size(idx);
        ir = repmat(1:n, 1, k);
        ic = idx(:)';
        wv = ones(1, n*k);
        
        if (exist('D', 'var') ~= 0 && (numel(D) == n*k))
            wv = D(:)';
        end
        
        ix0 = find(ic == 0);
        ir(ix0) = [];
        ic(ix0) = [];
        wv(ix0) = [];
        W = sparse(ir, ic, wv, n, n);
    end
end