function [Y, loss] = UBE(X, nDim, k, maxIter, graphMode, dispFreq, label)
% UBE Performs Unit Ball Embedding on dataset X to reduce its dimensionality
% 
% Usage syntax:
%   [mappedX, loss] = UBE(X)
%   [mappedX, loss] = UBE(X, nDim)
%   [mappedX, loss] = UBE(X, nDim, k)
%   [mappedX, loss] = UBE(X, nDim, k, maxIter)
%   [mappedX, loss] = UBE(X, nDim, k, maxIter, graphMode)
%   [mappedX, loss] = UBE(X, nDim, k, maxIter, graphMode, dispFreq)
%   [mappedX, loss] = UBE(X, nDim, k, maxIter, graphMode, dispFreq, label)
%
% Inputs:
%     X: nxp data matrix with n observation and p dimensions
%     nDim: dimensionality of output (default: 3)
%     k: number of neighbors in connectivity graph (default: 5)
%     maxIter: maximum number of iteration for optimization (default: 500)
%     graphMode: graph edge weight mode (default: 'binary'). 
%                possible values are:
%                 - 'binary': binary adjacency matrix (default)
%                 - 'similarity': 1 - (normalized distances)
%                 - 'gaussian': gaussian similarity on normalized distances
%     dispFreq: frequency of displaying output (default: 10)
%     label: the class labels are not used by the UBE itself, however, 
%            if you provide labels program will plot the mapped data 
%            every dispFreq iterations.
%
% Outputs:
%     mappedX: the low-dimensional embedding found by UBE,
%              a matrix of n observations in nDim dimensional space.
%     loss: values of the objective function at different iterations.
%
% Datasets:
%     some sample datasets can be downloaded at:
%     https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/UXU6Z3
% 
% (C) Behrouz Haji Soleimani, 2016
% email: bh926751@dal.ca
% Dalhousie University, Halifax NS, Canada
% Last updated: 2016-April-04
% 

    if (exist('nDim', 'var') == 0)
        nDim = 3;
    end
    if (exist('k', 'var') == 0)
        k = 5;
    end
    if (exist('maxIter', 'var') == 0)
        maxIter = 500;
    end
    if (exist('graphMode', 'var') == 0)
        graphMode = 'binary';
    end
    if (exist('dispFreq', 'var') == 0)
        dispFreq = 10;
    end
    if (dispFreq > 0)
        tic;
    end
    
    %% initialize low-dimensional data randomly
    n = size(X, 1);
    Y = rand(n, nDim) - 0.5;
    Y = Y ./ repmat(sqrt(sum(Y .^ 2, 2)), 1, nDim);
    
    %% calculate the learning rate for all iterations
    alphaInit = 0.1;
    alphaGD = linspace(alphaInit, 0, maxIter);
    t = (alphaGD .* (13 / alphaInit)) - 6;
    s = 1 ./ (1 + exp(-t));
    alphaGD = (s .* 7 .* alphaInit ./ 8) + (alphaInit ./ 8);
    
    %% build the neighborhood graph
    W = buildNNgraph(X, k, graphMode);
    
    %% gradient descent optimization
    loss = zeros(maxIter, 1);
    lossTxt = '';
    for i = 1:maxIter
        for j = 1:n
            v1 = W(j, :) * Y;
            v2 = (Y * Y(j, :)')' * Y;
            v1 = v1 ./ sqrt(sum(v1 .^ 2));
            v2 = v2 ./ sqrt(sum(v2 .^ 2));
            grad = v2 - v1;
            grad = grad ./ sqrt(sum(grad .^ 2));
            Y(j, :) = Y(j, :) - (alphaGD(i) .* grad);
            Y(j, :) = Y(j, :) ./ sqrt(sum(Y(j, :) .^ 2));
        end
        if (nargout > 1)
            loss(i) = sum(sum((Y*Y' - W) .^ 2)) ./ (n.^2);
            lossTxt = [' - loss: ' num2str(loss(i))];
        end
        
        %% output display
        if (dispFreq > 0 && mod(i, dispFreq) == 0)
            disp(['iteration: ' num2str(i) '/' num2str(maxIter) lossTxt ' - alpha: ' num2str(alphaGD(i)) ' - ' num2str(roundn(toc, -2)) ' seconds past - ' num2str(((maxIter-i)*toc/i)/3600) ' hours remaining...']);
        end
        if (exist('label', 'var') ~= 0 && mod(i, dispFreq) == 0)
            plotData(Y, label, clf);
            drawnow;
        end
    end
end