function H = tightsubplot(varargin)


sp=0.0 ;
use_outer=0 ;

% --------------------------------------------------------------------
%                                                      Parse arguments
% --------------------------------------------------------------------
K=varargin{1} ;
p=varargin{2} ;
N = ceil(sqrt(K)) ;
M = ceil(K/N) ;

a=3 ;
NA = length(varargin) ;
if NA > 2
  if isa(varargin{3},'char')
    % Called with K and p
  else
    % Called with M,N and p
    a = 4 ;
    M = K ;
    N = p ;
    p = varargin{3} ;
  end
end

for a=a:2:NA
  switch varargin{a}
    case 'Spacing'
      sp=varargin{a+1} ;
    case 'Box'      
      switch varargin{a+1}
        case 'inner'
          use_outer = 0 ;
        case 'outer'
	if ~strcmp(version('-release'), '14')
          %warning(['Box option supported only on MATALB 14']) ;
	  continue;
	end
        use_outer = 1 ;
        otherwise
          error(['Box is either ''inner'' or ''outer''']) ;
      end
    otherwise
      error(['Uknown parameter ''', varargin{a}, '''.']) ;
  end      
end

% --------------------------------------------------------------------
%                                                  Check the arguments
% --------------------------------------------------------------------

[j,i]=ind2sub([N M],p) ;
i=i-1 ;
j=j-1 ;

dt = sp/2 ;
db = sp/2 ;
dl = sp/2 ;
dr = sp/2 ;

pos = [  j*1/N+dl,...
       1-i*1/M-1/M+dt,...
       1/N-dl-dr,...
       1/M-dt-db] ;

switch use_outer
  case 0
    H = findobj(gcf, 'Type', 'axes', 'Position', pos) ;
    if(isempty(H))
      H = axes('Position', pos) ;
    else
      axes(H) ;
    end
    
  case 1
    H = findobj(gcf, 'Type', 'axes', 'OuterPosition', pos) ;
    if(isempty(H))
      H = axes('ActivePositionProperty', 'outerposition',...
               'OuterPosition', pos) ;
    else
      axes(H) ;
    end
end    
