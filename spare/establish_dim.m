function [pcadim, allsvd]=establish_dim(dat,S)

% check for empty input
if isempty(dat),
    pcadim = 0;
    allsvd = [];
    return;
end

% setup pca rank
pcadim=S.pca_dim;

if S.force_pca_dim
    disp('Forcing PCA rank to be user-specified value.');
else
    pcadim_adapt = spm_pca_order(dat)-1;
    if((pcadim==-1 || pcadim>pcadim_adapt) && pcadim_adapt>1)
        pcadim = pcadim_adapt;
    end;
    
end;

allsvd      = pca(dat,pcadim);
min_eig2use = osl_check_eigenspectrum(allsvd, pcadim, 0);

if S.force_pca_dim,
    if(min_eig2use<S.pca_dim)
        disp(['min_eig2use=' num2str(min_eig2use)]);
        disp(['S.pca_dim=' num2str(S.pca_dim)]);
        
        error('Dimensionality of data is less than the pca_dim being forced');
    end;
else
    pcadim=min_eig2use;
end;
