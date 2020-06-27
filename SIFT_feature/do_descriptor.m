function [descriptors] = do_descriptor(octave, oframes, sigma0, S, smin, varargin)
%DO_DESCRIPTOR is used to calculate descriptor for every feature
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input:
%octave --- a group of Gaussian scale space
%oframes --- include scale and orient of key point
%sigma0 --- base value of sigma
%S --- the number of scale level of the octave
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Output:
%descriptors --- the descriptors of every key point
for k=1:2:length(varargin)
	switch lower(varargin{k})
      case 'magnif'
        magnif = varargin{k+1} ;%%3.0
        
      case 'numspatialbins'
        NBP = varargin{k+1} ;  %%NBP=4
        
      case  'numorientbins'
        NBO = varargin{k+1} ;   %%NBO=8
        
      otherwise
        error(['Unknown parameter ' varargin{k} '.']) ;
     end
end 
      
                               
num_spacialBins = NBP;
num_orientBins = NBO;
key_num = size(oframes, 2);
% calculate vector and orient of picture
[M, N, s_num] = size(octave); % M is the height of picture, N is the wide of picture,num_level is the number of scale level of the octave
descriptors = [];
magnitudes = zeros(M, N, s_num);
angles = zeros(M, N, s_num);
% compute image gradients
for si = 1: s_num
    img = octave(:,:,si);
    dx_filter = [-0.5 0 0.5];
    dy_filter = dx_filter';
    gradient_x = imfilter(img, dx_filter);%x方向的梯度图
    gradient_y = imfilter(img, dy_filter);%y方向的梯度图
    magnitudes(:,:,si) =sqrt( gradient_x.^2 + gradient_y.^2);%幅度图
%     if sum( gradient_x == 0) > 0
%         fprintf('00');
%     end
    angles(:,:,si) = mod(atan(gradient_y ./ (eps + gradient_x)) + 2*pi, 2*pi);%角度
end

x = oframes(1,:);%关键点的坐标以及在第几层图像，精确坐标，浮点数
y = oframes(2,:);
s = oframes(3,:);
% round off　
x_round = floor(oframes(1,:) + 0.5);
y_round = floor(oframes(2,:) + 0.5);
scales =  floor(oframes(3,:) + 0.5) - smin;

for p = 1: key_num  %对各个关键点处理

    s = scales(p);%四会五入后的坐标
    xp= x_round(p);
    yp= y_round(p);
    theta0 = oframes(4,p);% the orient of key point,accurately
    sinth0 = sin(theta0) ;
    costh0 = cos(theta0) ;
    sigma = sigma0 * 2^(double (s / S)) ;%本层的尺度
    SBP = magnif * sigma;%%3.0*sigma%%%m*sigma
    %W =  floor( sqrt(2.0) * SBP * (NBP + 1) / 2.0 + 0.5);
    W =   floor( 0.8 * SBP * (NBP + 1) / 2.0 + 0.5);%确定实际计算的图像区域
    
    descriptor = zeros(NBP, NBP, NBO);%创建４*４*８的矩阵存储图像附近点的矢量描述
    
    % within the big square, select the pixels with the circle and put into
    % the histogram. no need to do rotation which is very expensive
    %在大正方形中用高斯加权圆选择像素点放入方向直方图中，不需要做昂贵的图像旋转
    for dxi = max(-W, 1-xp): min(W, N -2 - xp)%1－xp表示图像左边界区域到特征点的增量，Ｎ－２－ＸＰ表示图像右边界到特征点的增量
        for dyi = max(-W, 1-yp) : min(+W, M-2-yp)
            mag = magnitudes(yp + dyi, xp + dxi, s); % 当前点(yp + dyi, xp + dxi)的梯度幅值
            angle = angles(yp + dyi, xp + dxi, s) ;  % 当前点(yp + dyi, xp + dxi)的梯度幅角
%           angle = mod(-angle + theta0, 2*pi);      % 用关键点的主方向调整角度 并且 mod it with 2*pi
            angle = mod(angle - theta0, 2*pi);
            dx = double(xp + dxi - x(p));            % x(p) 是关键点的精确位置 (浮点数). dx 相对于该关键点当前像素的位置
            dy = double(yp + dyi - y(p));            % dy 相对于该关键点当前像素的位置
            
            nx = ( costh0 * dx + sinth0 * dy) / SBP ; % nx 是旋转(dx, dy)后的规格化位置 with the major orientation angle. this tells which x-axis spatial bin the pixel falls in 
            ny = (-sinth0 * dx + costh0 * dy) / SBP ; 
            nt = NBO * angle / (2* pi) ;%属于第几个角度范围
            wsigma = NBP/2 ;
            wincoef =  exp(-(nx*nx + ny*ny)/(2.0 * wsigma * wsigma)) ;%高斯函数指数部分
            
            binx = floor( nx - 0.5 ) ; % nx 是旋转(dx, dy)后的规格化位置
            biny = floor( ny - 0.5 ) ;
            bint = floor( nt );
            rbinx = nx - (binx+0.5) ;%rbinx求出的是nx的小数部分，浮点部分
            rbiny = ny - (biny+0.5) ;
            rbint = nt - bint ;
         %%%%%%%这边就是要构造每一维方向在４*４*８的坐标，仔细看吧相信你能看懂    
            for(dbinx = 0:1) %步长缺省值为１
               for(dbiny = 0:1) 
                   for(dbint = 0:1) 
                        % if condition limits the samples within the square
                        % width W. binx+dbinx is the rotated x-coordinate.
                        % therefore the sampling square is effectively a
                        % rotated one
                        %如果条件限制在用宽度W设定的方形内的样点，binx+dbinx是旋转后的x坐标
                        %因此采样方形的旋转是有效的。
                        %binx是旋转后的取整的位置binx = floor( nx - 0.5 ) ; % nx 是旋转(dx, dy)后的规格化位置
                        if( binx+dbinx >= -(NBP/2) && ...
                            binx+dbinx <   (NBP/2) && ...
                            biny+dbiny >= -(NBP/2) && ...
                            biny+dbiny <   (NBP/2) &&  isnan(bint) == 0) %isnan判断一个数是否为无穷，非无穷数返回值为0，否则返回1
                             %判断在正方形内 
                              weight = wincoef * mag * abs(1 - dbinx - rbinx) ...   %%%%%%%%%这个地方后面乘的那三个绝对值不知道是啥意思
                                  * abs(1 - dbiny - rbiny) ...
                                  * abs(1 - dbint - rbint) ;
                                   %NBP=4   
                                   %+NBP是将可能坐标为负的坐标转化为正值，+１是matlab中的坐标点是从１开始的
                              descriptor(binx+dbinx + NBP/2 + 1, biny+dbiny + NBP/2+ 1, mod((bint+dbint),NBO)+1) = ...
                                  descriptor(binx+dbinx + NBP/2+ 1, biny+dbiny + NBP/2+ 1, mod((bint+dbint),NBO)+1 ) +  weight ;
                        end
                   end
               end
               
            end
        end
            
    end
    descriptor = reshape(descriptor, 1, NBP * NBP * NBO);%用一维向量表示各梯度值
    descriptor = descriptor ./ norm(descriptor); %归一化处理梯度值
            
            %Truncate at 0.2
    indx = find(descriptor > 0.2);%找出幅值大于0.2的梯度值
    descriptor(indx) = 0.2;       %大于0.2的梯度值直接取0.2
    descriptor = descriptor ./ norm(descriptor);  %再次归一化梯度值
    
    descriptors = [descriptors, descriptor'];
end
