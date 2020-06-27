function oframes = do_orientation(oframes, octave, S, smin,sigma0 )
% this function computes the major orientation of the keypoint (oframes).
% Note that there can be multiple major orientations. In that case, the
% SIFT keys will be duplicated for each major orientation
% Author: Yantao Zheng. Nov 2006.  For Project of CS5240

frames = [];                  
win_factor = 1.5 ;  
NBINS = 36;                   %直方图36柱
histo = zeros(1, NBINS);      %初始化直方图数组
[M, N, s_num] = size(octave); % M 是图像的高度, N 是图像的宽度; num_level 是该组尺度空间的层数

key_num = size(oframes, 2);        %关键点数目
magnitudes = zeros(M, N, s_num);   %像素向量幅度数组
angles = zeros(M, N, s_num);       %像素幅角数组
% compute image gradients 计算图像梯度
for si = 1: s_num
    img = octave(:,:,si);
    dx_filter = [-0.5 0 0.5];
    dy_filter = dx_filter';%对矩阵进行转置运算
    gradient_x = imfilter(img, dx_filter);
    gradient_y = imfilter(img, dy_filter);
    magnitudes(:,:,si) =sqrt( gradient_x.^2 + gradient_y.^2);
    angles(:,:,si) = mod(atan(gradient_y ./ (eps + gradient_x)) + 2*pi, 2*pi);%计算角度，eps是最小的正值以防分母为零，+２*pi是将负角度转化为正值角度
end

if size(oframes, 2) == 0
    return;
end
% round off the cooridnates and 
x = oframes(1,:);
y = oframes(2,:) ;
s = oframes(3,:);

x_round = floor(oframes(1,:) + 0.5);%向下求整
y_round = floor(oframes(2,:) + 0.5);
scales = floor(oframes(3,:) + 0.5) - smin;


for p=1:key_num         %对每个关键点进行处理
    s = scales(p);
    xp= x_round(p);
    yp= y_round(p);
    sigmaw = win_factor * sigma0 * 2^(double (s / S)) ;  %高斯加权因子　sigma0 * 2^(double (s / S))是当前层图像的高斯尺度，
    W = floor(3.0* sigmaw);                              %高斯加权窗口直径
    
    for xs = xp - max(W, xp-1): min((N - 2), xp + W)%%xp-1是当前点到右边界的矩离，Ｗ就是加权窗口到当前点的矩离，
        for ys = yp - max(W, yp-1) : min((M-2), yp + W)
            dx = (xs - x(p));
            dy = (ys - y(p));
            if dx^2 + dy^2 <= W^2 % 点在高斯加权圆内
               wincoef = exp(-(dx^2 + dy^2)/(2*sigmaw^2));
               bin = round( NBINS *  angles(ys, xs, s+ 1)/(2*pi) + 0.5); %最近取整，确定所在方向直方图的柱

               histo(bin) = histo(bin) + wincoef * magnitudes(ys, xs, s+ 1); %用高斯加权后的向量幅度做直方图值累加
            end
            
        end
    end
    
    theta_max = max(histo);   %找到直方图峰值
    theta_indx = find(histo> 0.8 * theta_max); %关键点方向索引，大于80%峰值的角度
    
    for i = 1: size(theta_indx, 2)
        theta = 2*pi * theta_indx(i) / NBINS;
        frames = [frames, [x(p) y(p) s theta]']; %%%%%%%       
    end   
end

oframes = frames;
% for each keypoint