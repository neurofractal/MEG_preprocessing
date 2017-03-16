modalities = {'MEGMAG','MEGGRAD'};

normalisation = ones(1,length(data_clean_noICA.label));

figure
linecolor = {'r','g'};

for modality = modalities
    
    cfg = [];
    cfg.channel = modality;
    data_chans = ft_selectdata(cfg,data_clean_noICA);
    
    if strcmp(modality,'MEGMAG')
        channel_inds = [3:3:306];
    end
    
    if strcmp(modality,'MEGGRAD')
        load('channel_inds')
    end
    
    
    %data = horzcat(data_chans.trial{:});
    
        covar = zeros(numel(data_chans.label));
    for itrial = 1:numel(data_chans.trial)
        currtrial = data_chans.trial{itrial};
        covar = covar + currtrial*currtrial.';
    end
    
    [V, eigenvectors] = eig(covar);
    
    eigenvectors = sort(diag(eigenvectors),'descend');
    eigenvectors = eigenvectors ./ sum(eigenvectors);
    
    %C = osl_cov(data);
    
    %rankEst = estimate_rank(V); disp(sprintf('Rank Estimate = %d', rankEst));
    rankEst = 50;
    
    %eigenvectors = svd(C);
    
    normalisation(channel_inds) = (sqrt(mean(eigenvectors(rankEst-2:rankEst))));
   
    subplot(1,2,1); title('Unnormalised eigenvectors'); hold on;
    plot(log(eigenvectors),'linewidth',2,'color',linecolor{strcmp(modality,modalities)})
    stem(rankEst,log(eigenvectors(rankEst)),'--','color',linecolor{strcmp(modality,modalities)},'marker','none')
    subplot(1,2,2); title('Normalised eigenvectors'); hold on;
    plot(log(eigenvectors.*normalisation(channel_inds).^2'),'linewidth',2,'color',linecolor{strcmp(modality,modalities)})
    legend('MEGMAG', 'MEGGRAD')
end

% montage             =  [];
% montage.tra         =  diag(normalisation);
% %montage.labelnew    =  data_clean_noICA.label;
% %montage.labelorg    =  data_clean_noICA.label;
% 
% cfg =[];
% cfg.montage        =  montage;
% cfg.keepothers     =  true;
% cfg.updatehistory  =  1;
% 
% [data_clean_noICA_noICA.grad.balance] = ft_apply_montage(data_clean_noICA_noICA.grad.balance,montage);
