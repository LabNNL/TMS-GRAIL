
clear
clc

overwrite=false;                                                            % Set to true to recompute existing Data/Results
recompute=[];                                                               % Metric names to refresh on already-processed subjects, e.g. recompute=["Coherence"];
folder=fileparts(which("main.m"));
addpath(genpath(folder));

cond={"NW","VM","CT"};
group={"PIL","CP","TD"};
all_metrics=["Envelopes","Synergies","SpinalMaps","MoS","TO","CRP","Bursts","Coherence"];

for g=1:length(group)
    group_path=fullfile(folder,group{g});
    subfolders=dir(group_path);
    subfolders=subfolders([subfolders.isdir] & startsWith({subfolders.name},group{g}));

    for s=1:length(subfolders)
        subject=subfolders(s).name;
        path=fullfile(group_path,subject);

        if ~overwrite && exist(char(fullfile(path,'Data.mat')),'file') && exist(char(fullfile(path,'Results.mat')),'file')
            if isempty(recompute)
                fprintf('Skipping : %s (already processed)\n',subject);
                continue
            end
            fprintf('Recomputing %s for : %s\n',strjoin(recompute,', '),subject);
            load(char(fullfile(path,'Data.mat')),'Data');
            load(char(fullfile(path,'Results.mat')),'Results');
            for c=1:length(cond)
                if isfield(Data,cond{c})
                    Results.(cond{c})=compute_metrics(Data.(cond{c}),Results.(cond{c}),recompute);
                end
            end
            save(fullfile(path,'Results.mat'),'Results')
            continue
        end

        Data=struct();
        Results=struct();
        fprintf('Processing : %s\n',subject);
        tab_asso=EMG_association(subject);

        for c=1:length(cond)
            filename=cond{c}+".c3d";
            filepath=fullfile(path,filename);
            if exist(char(filepath),'file')
                c3d=ezc3dRead(char(filepath));
                Data.(cond{c})=restructure_c3d(c3d);
                Data.(cond{c}).EMG=name_EMG(Data.(cond{c}).EMG,tab_asso);
                Results.(cond{c})=compute_metrics(Data.(cond{c}),struct(),all_metrics);
            else
                warning('File not found : %s',char(filepath))
            end
        end
        if ~isempty(fieldnames(Data))
            save(fullfile(path,'Data.mat'),'Data')
        end
        if ~isempty(fieldnames(Results))
            save(fullfile(path,'Results.mat'),'Results')
        end
    end
end