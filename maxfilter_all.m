%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to Maxfilter all .fif files in a directory
% Use as maxfilter_all('path_to_directory')
% Make sure there are no Maxfiltered datasets in your directory.
% This script will estimate head position and apply tSSS with a .9
% correlation. Can be changed if necessary.
% Head position is subsequently visualised using a script obtained from the
% MRC MEG team at Cambridge.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function maxfilter_all(directory)

% Specify current directory & find all .fif files
cd(directory)

% Put files into arry but ignore any fif files already undergone tSSS
dir_list = dir('**.fif');
files = [];
p = 1;
for i=1:length(dir_list)
    matches = strfind(dir_list(i).name,'tsss');
    if isempty(matches) == 1
        files{p} = dir_list(i).name;
        p = p+1;
    end
end

disp(files)

clear p

% This script outputs 2 log files:
% 1) head_pos_output_filename.log = headposition
% 2) output_log_filename.log = overall log file which can be read into
% Cambridge headmovt script

for i=1:length(files)
    ddd = (sprintf('maxfilter -f ctc /neuro/databases/ctc/ct_sparse.fif -cal /neuro/databases/sss/sss_cal.dat %s -v -force -st -corr 0.9 -headpos -hp headpos_output_%s.log | tee output_log_%s.log', ([cd '/' files{i}]), files{i},files{i}))
    disp(sprintf('About to Maxfilter dataset %s using tSSS & 0.9 correlation PLUS estimating head position',files{i}))
    system(ddd)
    clear ddd
    system(ls)
end

%% Visualising movement

% uses check_movecomp to read and display maxfilter -headpos output
% Files with maxfilter outputs, e.g. for different subjects and conditions
% See http://imaging.mrc-cbu.cam.ac.uk/meg/maxdiagnost
movecompfiles = {};
for i =1:length(files)
    movecompfiles{i} = sprintf('output_log_%s.log', files{i})
end
nr_files = length(movecompfiles);

for ff = 1:nr_files,
    fprintf(1, 'Processing %s\n', movecompfiles{ff});
    [mv_fig, linet, linee, lineg, linev, liner, lined] = check_movecomp(movecompfiles{ff}); % read info from log-file
    [a,b,c] = fileparts(movecompfiles{ff} );
    tittxt = [b]; % just one way to keep the figure title short
    figure( mv_fig );
    % check_movecomp only creates the figure, but without the title, so you can do this separately
    ht = title(tittxt); set(ht, 'interpreter', 'none'); % add title to figure
    saveas(gcf,sprintf('%s_movement.png',b))
end

end
