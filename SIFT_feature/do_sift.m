function [frames,descriptors,scalespace,difofg]=do_sift(file,varargin)
%% file:       sift.m
% author:      Noemie Phulpin
% description: SIFT algorithm

warning off all;

tic

I=im2double(imread(file)) ;
if(size(I,3) > 1)
  I = rgb2gray( I ) ;
end

[M,N,C] = size(I) ;%����I�ĳߴ�

% Lowe's choices
S=3 ;
omin= 0 ;
%O=floor(log2(min(M,N)))-omin-4 ; % Up to 16x16 images
O = 4;

sigma0=1.6*2^(1/S) ;%�����˹����߶ȵĹ�ʽ
sigmaN=0.5 ;
thresh = 0.2 / S / 2 ; % 0.04 / S / 2 ;
r = 18 ;

NBP = 4 ;
NBO = 8 ;
magnif = 3.0 ;

% Parese input
compute_descriptor = 0 ;
discard_boundary_points = 1 ;
verb = 0 ;

% Arguments sanity check
if C > 1                  %ͼ��ͨ��������������ά�ȣ�����ǻҶ�ͼӦ��Ϊ1
  error('I Ӧ���ǻҶ�ͼ') ;
end

frames = [] ;
descriptors = [] ;

% 
%   ��ʼ����
%
% fprintf('---------------------------- ��ʼ SIFT: ��ͼ������ȡSIFT���� ------------------------------\n') ; tic ; 

% fprintf('SIFT: ��DoG����߶ȿռ� ...\n') ; %tic ; 

scalespace = do_gaussian(I,sigmaN,O,S,omin,-1,S+1,sigma0) ;

%fprintf('                ��˹�߶ȿռ��ʱ: (%.3f s)\n',toc) ; tic ; 

difofg = do_diffofg(scalespace) ;

%fprintf('                ��������߶ȿռ�: (%.3f s)\n',toc) ;

for o=1:scalespace.O
    
    
	%fprintf('CS5240 -- SIFT: ���� ���顱  %d\n', o-1+omin) ;
                %tic ;
	
  %  DOG octave �ľֲ���ֵ���
    oframes1 = do_localmax(  difofg.octave{o}, 0.8*thresh, difofg.smin  ) ;
    oframes2 = do_localmax( -difofg.octave{o}, 0.8*thresh, difofg.smin  ) ;
	oframes = [oframes1 ,oframes2 ] ; 
    
    
    %fprintf('CS5240 -- SIFT: ��ʼ���ؼ��� # %d.  \n', ...
     % size(oframes, 2)) ;%��������������һ���ж�����
    %fprintf('                ��ʱ (%.3f s)\n', ...
       %toc) ;
    %tic ;
	
    if size(oframes, 2) == 0
        continue;
    end
    
  % �Ƴ������߽�Ĺؼ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % radΪ��˹ģ��뾶scalespace.sigma0 * 2.^(oframes(3,:)/scalespace.S)����ǵ�ǰ��˹�߶ȣ�Ȼ����ݵ�ǰ��˹�߶ȼ����˹ģ��뾶��
  %֮����*NBP����ø�˹����˵�ģ��Ĵ�С���ٳ���2����ø�ģ��İ뾶
    rad = magnif * scalespace.sigma0 * 2.^(oframes(3,:)/scalespace.S) * NBP / 2 ;%
    sel=find(...
      oframes(1,:)-rad >= 1                     & ...
      oframes(1,:)+rad <= size(scalespace.octave{o},2) & ...��������������%ͼ�����
      oframes(2,:)-rad >= 1                     & ...
      oframes(2,:)+rad <= size(scalespace.octave{o},1)     ) ;       %ͼ����
    oframes=oframes(:,sel) ;%�Ѳ��ǿ����߽��ļ�ֵ�����·���oframes��
		
	%fprintf('CS5240 -- SIFT: �Ƴ������߽�ؼ���� # %d \n', size(oframes,2)) ;
     % tic ;
		
  % ����ֲ�, ��ֵǿ�� ���Ƴ���Ե�ؼ���
   	oframes = do_extrefine(...
 		oframes, ...
 		difofg.octave{o}, ...
 		difofg.smin, ...
 		thresh, ...
 		r) ;
   
   	%fprintf('CS5240 -- SIFT:  �Ƴ��ͶԱȶȺͱ�Ե�Ϲؼ���� # %d \n',size(oframes,2)) ;
    %fprintf('                Time (%.3f s)\n',  toc) ;
    %tic ;
    
    if size(oframes, 2) == 0
        continue;
    end
    %fprintf('CS5240 -- SIFT: ���������㷽��\n');
    
    
  % ���㷽��
	oframes = do_orientation(...
		oframes, ...
		scalespace.octave{o}, ...
		scalespace.S, ...
		scalespace.smin, ...
		scalespace.sigma0 ) ;
	%fprintf('                ��ʱ: (%.3f s)\n', toc);tic;
		
  % Store frames
  %����ͬ������껹ԭ�ص���һ��ͼ����ȥ
	x     = 2^(o-1+scalespace.omin) * oframes(1,:) ;
	y     = 2^(o-1+scalespace.omin) * oframes(2,:) ;
	sigma = 2^(o-1+scalespace.omin) * scalespace.sigma0 * 2.^(oframes(3,:)/scalespace.S) ;	%ͼ��ĳ߶�	
	frames = [frames, [x(:)' ; y(:)' ; sigma(:)' ; oframes(4,:)] ] ;

	%fprintf('CS5240 -- SIFT:���㷽���������� # %d  \n', size(frames,2)) ;
  % Descriptors
	
%     fprintf('CS5240 -- SIFT: ���� ������...\n') ;
    %tic ;
		
	sh = do_descriptor(scalespace.octave{o}, ...
                    oframes, ...
                    scalespace.sigma0, ...
                    scalespace.S, ...
                    scalespace.smin, ...
                    'Magnif', magnif, ...
                    'NumSpatialBins', NBP, ...
                    'NumOrientBins', NBO) ;
    
    descriptors = [descriptors, sh] ;%ÿһ����������������󲹳䵽descriptors������
    
    %fprintf('                ��ʱ: (%.3f s)\n\n\n',toc) ; 
    
      
    
end 
fprintf('SIFT������ȡ���̣�');
toc
fprintf('CS5240 -- SIFT: �ؼ�������: %d \n\n\n', size(frames,2)) ;
