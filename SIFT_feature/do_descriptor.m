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
    gradient_x = imfilter(img, dx_filter);%x������ݶ�ͼ
    gradient_y = imfilter(img, dy_filter);%y������ݶ�ͼ
    magnitudes(:,:,si) =sqrt( gradient_x.^2 + gradient_y.^2);%����ͼ
%     if sum( gradient_x == 0) > 0
%         fprintf('00');
%     end
    angles(:,:,si) = mod(atan(gradient_y ./ (eps + gradient_x)) + 2*pi, 2*pi);%�Ƕ�
end

x = oframes(1,:);%�ؼ���������Լ��ڵڼ���ͼ�񣬾�ȷ���꣬������
y = oframes(2,:);
s = oframes(3,:);
% round off��
x_round = floor(oframes(1,:) + 0.5);
y_round = floor(oframes(2,:) + 0.5);
scales =  floor(oframes(3,:) + 0.5) - smin;

for p = 1: key_num  %�Ը����ؼ��㴦��

    s = scales(p);%�Ļ�����������
    xp= x_round(p);
    yp= y_round(p);
    theta0 = oframes(4,p);% the orient of key point,accurately
    sinth0 = sin(theta0) ;
    costh0 = cos(theta0) ;
    sigma = sigma0 * 2^(double (s / S)) ;%����ĳ߶�
    SBP = magnif * sigma;%%3.0*sigma%%%m*sigma
    %W =  floor( sqrt(2.0) * SBP * (NBP + 1) / 2.0 + 0.5);
    W =   floor( 0.8 * SBP * (NBP + 1) / 2.0 + 0.5);%ȷ��ʵ�ʼ����ͼ������
    
    descriptor = zeros(NBP, NBP, NBO);%������*��*���ľ���洢ͼ�񸽽����ʸ������
    
    % within the big square, select the pixels with the circle and put into
    % the histogram. no need to do rotation which is very expensive
    %�ڴ����������ø�˹��ȨԲѡ�����ص���뷽��ֱ��ͼ�У�����Ҫ�������ͼ����ת
    for dxi = max(-W, 1-xp): min(W, N -2 - xp)%1��xp��ʾͼ����߽�������������������Σ������أб�ʾͼ���ұ߽絽�����������
        for dyi = max(-W, 1-yp) : min(+W, M-2-yp)
            mag = magnitudes(yp + dyi, xp + dxi, s); % ��ǰ��(yp + dyi, xp + dxi)���ݶȷ�ֵ
            angle = angles(yp + dyi, xp + dxi, s) ;  % ��ǰ��(yp + dyi, xp + dxi)���ݶȷ���
%           angle = mod(-angle + theta0, 2*pi);      % �ùؼ��������������Ƕ� ���� mod it with 2*pi
            angle = mod(angle - theta0, 2*pi);
            dx = double(xp + dxi - x(p));            % x(p) �ǹؼ���ľ�ȷλ�� (������). dx ����ڸùؼ��㵱ǰ���ص�λ��
            dy = double(yp + dyi - y(p));            % dy ����ڸùؼ��㵱ǰ���ص�λ��
            
            nx = ( costh0 * dx + sinth0 * dy) / SBP ; % nx ����ת(dx, dy)��Ĺ��λ�� with the major orientation angle. this tells which x-axis spatial bin the pixel falls in 
            ny = (-sinth0 * dx + costh0 * dy) / SBP ; 
            nt = NBO * angle / (2* pi) ;%���ڵڼ����Ƕȷ�Χ
            wsigma = NBP/2 ;
            wincoef =  exp(-(nx*nx + ny*ny)/(2.0 * wsigma * wsigma)) ;%��˹����ָ������
            
            binx = floor( nx - 0.5 ) ; % nx ����ת(dx, dy)��Ĺ��λ��
            biny = floor( ny - 0.5 ) ;
            bint = floor( nt );
            rbinx = nx - (binx+0.5) ;%rbinx�������nx��С�����֣����㲿��
            rbiny = ny - (biny+0.5) ;
            rbint = nt - bint ;
         %%%%%%%��߾���Ҫ����ÿһά�����ڣ�*��*�������꣬��ϸ�����������ܿ���    
            for(dbinx = 0:1) %����ȱʡֵΪ��
               for(dbiny = 0:1) 
                   for(dbint = 0:1) 
                        % if condition limits the samples within the square
                        % width W. binx+dbinx is the rotated x-coordinate.
                        % therefore the sampling square is effectively a
                        % rotated one
                        %��������������ÿ��W�趨�ķ����ڵ����㣬binx+dbinx����ת���x����
                        %��˲������ε���ת����Ч�ġ�
                        %binx����ת���ȡ����λ��binx = floor( nx - 0.5 ) ; % nx ����ת(dx, dy)��Ĺ��λ��
                        if( binx+dbinx >= -(NBP/2) && ...
                            binx+dbinx <   (NBP/2) && ...
                            biny+dbiny >= -(NBP/2) && ...
                            biny+dbiny <   (NBP/2) &&  isnan(bint) == 0) %isnan�ж�һ�����Ƿ�Ϊ���������������ֵΪ0�����򷵻�1
                             %�ж����������� 
                              weight = wincoef * mag * abs(1 - dbinx - rbinx) ...   %%%%%%%%%����ط�����˵�����������ֵ��֪����ɶ��˼
                                  * abs(1 - dbiny - rbiny) ...
                                  * abs(1 - dbint - rbint) ;
                                   %NBP=4   
                                   %+NBP�ǽ���������Ϊ��������ת��Ϊ��ֵ��+����matlab�е�������Ǵӣ���ʼ��
                              descriptor(binx+dbinx + NBP/2 + 1, biny+dbiny + NBP/2+ 1, mod((bint+dbint),NBO)+1) = ...
                                  descriptor(binx+dbinx + NBP/2+ 1, biny+dbiny + NBP/2+ 1, mod((bint+dbint),NBO)+1 ) +  weight ;
                        end
                   end
               end
               
            end
        end
            
    end
    descriptor = reshape(descriptor, 1, NBP * NBP * NBO);%��һά������ʾ���ݶ�ֵ
    descriptor = descriptor ./ norm(descriptor); %��һ�������ݶ�ֵ
            
            %Truncate at 0.2
    indx = find(descriptor > 0.2);%�ҳ���ֵ����0.2���ݶ�ֵ
    descriptor(indx) = 0.2;       %����0.2���ݶ�ֱֵ��ȡ0.2
    descriptor = descriptor ./ norm(descriptor);  %�ٴι�һ���ݶ�ֵ
    
    descriptors = [descriptors, descriptor'];
end
