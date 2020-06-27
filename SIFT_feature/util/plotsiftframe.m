function h=plotsiftframe(frames,varargin)
% PLOTSIFTFRAME  Plot SIFT frame
%   H=PLOTSIFTFRAME(FRAMES) plots the SIFT frames FRAMES and returns
%   and handle H to the resulting line set. FRAMES has the same format
%   used by SIFT().
%



if size(frames,1) ~= 4
	error('FRAMES should be a 4xK matrix') ;
end


putlabel = 0 ;
labels=[];
style='arrow' ;

for k=1:2:length(varargin)
  switch lower(varargin{k})
    
    case 'style'
      switch lower(varargin{k+1})
        case 'circle'
          style = 'circle';
        case 'arrow'
          style = 'arrow' ;
        otherwise
          error(['Unknown style type ''', style, '''.']) ;
      end
      
    case 'labels'
      labels = varargin{k+1} ;
      putlabel = 1;
      
    otherwise
      error(['Unknown option ''',varargin{k},'''.']) ;
  end  
end

K = size(frames,2) ;

% --------------------------------------------------------------------
%                  Do the work
% --------------------------------------------------------------------

hold on ;
K=size(frames,2) ;
thr=linspace(0,2*pi,40) ;

allx = nan*ones(1, 40*K+(K-1)) ;
ally = nan*ones(1, 40*K+(K-1)) ;

allxf = nan*ones(1, 3*K) ;
allyf = nan*ones(1, 3*K) ;

for k=1:K
	xc=frames(1,k) ;
	yc=frames(2,k) ;
	r=1.5*4*frames(3,k) ;
	th=frames(4,k) ;
	
	x = r*cos(thr) + xc ;
	y = r*sin(thr) + yc ;
		
	allx((k-1)*(41) + (1:40)) = x ;
	ally((k-1)*(41) + (1:40)) = y ;

	allxf((k-1)*3 + (1:2)) = [xc xc+r*cos(th)] ;
	allyf((k-1)*3 + (1:2)) = [yc yc+r*sin(th)] ;
	
	if putlabel
		x=xc+r ;
		y=yc ;
		h=text(x+2,y,sprintf('%d',labels(k))) ;
		set(h,'Color',[1 0 0]) ;
		plot(x,y,'r.') ;
	end

end

switch style
  case 'circle'    
    h=line([allx nan allxf], [ally nan allyf], 'Color','g','LineWidth',3) ;
  case 'arrow'
    h=line([allxf], [allyf], 'Color','g','LineWidth',3) ;
end
    
