
% Builds, for each subject in PIL/CP/TD, the sample table
% (Index, Target, Distance, Target error, Angular error, Twist error, Time)
% from <group>/<subject>/TMS/<subject>.txt and saves it as
% <group>/<subject>/TMS/<subject>_samples.xlsx.

folder=fileparts(which("get_TMS_samples.m"));
addpath(genpath(folder));

group={"PIL","CP","TD"};

for g=1:length(group)
    group_path=fullfile(folder,group{g});
    if ~exist(char(group_path),'dir')
        continue
    end

    subjects=dir(group_path);
    subjects=subjects([subjects.isdir] & startsWith({subjects.name},group{g}));

    for s=1:length(subjects)
        subject=subjects(s).name;
        filepath=fullfile(folder,group{g},subject,"TMS",subject+".txt");

        if ~exist(char(filepath),'file')
            continue
        end

        fprintf('Processing : %s\n',subject);
        T=read_TMS_samples(filepath);
        write_TMS_excel(T,fullfile(folder,group{g},subject,"TMS",subject+"_samples.xlsx"));
    end
end
