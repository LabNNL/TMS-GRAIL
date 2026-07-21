

folder=fileparts(which("main.m"));
addpath(genpath(folder));

cond={"NW","VM","CT"};
group={"CP","TD"};

for g=1:length(group)
    group_path=fullfile(folder,group{g});
    subfolders=dir(group_path);
    subfolders=subfolders([subfolders.isdir] & ~startsWith({subfolders.name},'.'));

    for s=1:length(subfolders)
        Data=struct();
        subject=subfolders(s).name;
        path=fullfile(group_path,subject);
        fprintf('Processing : %s\n',subject);

        for c=1:length(cond)
            filename=[cond{c} '.c3d'];
            filepath=fullfile(path,filename);
            if exist(filepath,'file')
                c3d=ezc3dRead(filepath);
                Data.(cond{c})=restructure_c3d(c3d);
            else
                warning('File not found : %s',filepath)
            end
        end
        if ~isempty(fieldnames(Data))
            save(fullfile(path,'Data.mat'),'Data')
        end
    end
end
