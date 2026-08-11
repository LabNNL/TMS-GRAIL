
overwrite=false;                                                            % Set to true to recompute existing Data/Results

folder=fileparts(which("main.m"));
addpath(genpath(folder));

cond={"NW","VM","CT"};
group={"PIL","CP","TD"};

for g=1:length(group)
    group_path=fullfile(folder,group{g});
    subfolders=dir(group_path);
    subfolders=subfolders([subfolders.isdir] & startsWith({subfolders.name},group{g}));

    for s=1:length(subfolders)
        subject=subfolders(s).name;
        path=fullfile(group_path,subject);

        if ~overwrite && exist(char(fullfile(path,'Data.mat')),'file') && exist(char(fullfile(path,'Results.mat')),'file')
            fprintf('Skipping : %s (already processed)\n',subject);
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
                Data.(cond{c}).EMG=name_emg(Data.(cond{c}).EMG,tab_asso);

                Results.(cond{c}).Envelopes=get_envelope(Data.(cond{c}));
                Results.(cond{c}).Synergies=get_synergies(Results.(cond{c}).Envelopes);
                Results.(cond{c}).SpinalMaps=get_spinalmap(Results.(cond{c}).Envelopes);
                Results.(cond{c}).MoS=get_mos(Data.(cond{c}));
                Results.(cond{c}).TO=get_toeoff(Data.(cond{c}));
                Results.(cond{c}).CRP=get_crp(Data.(cond{c}));
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