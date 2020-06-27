function plotss(ss,field)
% PLOTSS  Plot scale space
%   PLOTSS(SS) plots all octaves of the scale space SS.
%


if nargin > 2
    error('Too many arguments.') ;
end

omin = ss.omin ;
smin = ss.smin ;
nlevels = ss.smax-ss.smin+1 ;

for oi=1:ss.O
	for si=1:nlevels
		tightsubplot(nlevels, ss.O, nlevels*(oi-1)+si) ;
		s = si-1 + smin ;
		o = oi-1 + omin ;
		sigma = ss.sigma0 * 2^(s/ss.S + o) ;
		F=squeeze(ss.octave{oi}(:,:,si)) ;
		[M,N]=size(F) ;
		imagesc(squeeze(ss.octave{oi}(:,:,si))) ;	axis image ; axis off ;
		h=text(M/10,N/20,sprintf('(o,s)=(%d,%d), sigma=%f',o,s,sigma)) ;
		set(h,'BackgroundColor','w','Color','k') ;
	end
end


