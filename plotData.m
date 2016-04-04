function plotData(X, label, hFig)
    if (size(X, 2) > 3)
        cv = cov(X);
        coeff = pcacov(cv);
        X = X * coeff(:, 1:3);
        clear cv coeff;
    end

    X = X';
    [d,n] = size(X);
    if nargin < 2 || isempty(label)
        label = ones(n,1);
    end
    assert(n == length(label));

    color = 'rgbmcykrgbmcykrgbmcykrgbmcykrgbmcykrgbmcykrgbmcykrgbmcykrgbmcykrgbmcykrgbmcykrgbmcykrgbmcyk';
    marker = 'oooooooxxxxxxx.......sssssss^^^^^^^ppppppp+++++++*******dddddddvvvvvvv>>>>>>><<<<<<<hhhhhhh';
    m = length(color);
    unq = unique(label);
    c = numel(unq);

    if (exist('hFig', 'var') == 0)
        figure;
    end
    hold on;
    axis equal;
    switch d
        case 2
            view(2);
            for i = 1:min(c, m)
                idc = (label==unq(i));
                plot(X(1,idc),X(2,idc),[marker(i) color(i)],'MarkerSize',10);
            end
        case 3
            view(3);
            for i = 1:min(c, m)
                idc = (label==unq(i));
                plot3(X(1,idc),X(2,idc),X(3,idc),[marker(i) color(i)],'MarkerSize',5);
            end
    end
    hold off;
end