
% Run by section

%% Mean spinal maps

clear
clc

participant='PIL01';                                                        % Identifiant du participant (ex: 'PIL01')
cond={'NW','VM','CT'};
side=pick_spinal_side(participant);                                         % Côté avec le plus de muscles mesurés

subject_path=find_subject_path(participant);
load(fullfile(subject_path,'Results.mat'))

figure
tl=tiledlayout(1,3);
ax=gobjects(1,3);
climits=NaN(3,2);
for c=1:3
    ax(c)=nexttile;
    if isfield(Results,cond{c}) && isfield(Results.(cond{c}),'SpinalMaps') && isfield(Results.(cond{c}).SpinalMaps,side)
        m=Results.(cond{c}).SpinalMaps.(side).mean;
        coa=Results.(cond{c}).SpinalMaps.(side).coa;
        contourf(m,200,'LineColor','none')
        colormap("jet")
        hold on
        plot(1:101,coa,'k-','LineWidth',2)
        if isfield(Results.(cond{c}),'TO') && isfield(Results.(cond{c}).TO,side)
            xline(Results.(cond{c}).TO.(side).mean,'--w','LineWidth',2)
        end
        set(gca,'YDir','reverse')
        yticks(1:6)
        yticklabels({'L2','L3','L4','L5','S1','S2'})
        climits(c,:)=clim;
    end
    title(cond{c})
    xlabel("% gait cycle")
    if c==1
        ylabel(side,"FontWeight","bold")
    end
end
common_clim=[min(climits(:,1)),max(climits(:,2))];
for c=1:3
    clim(ax(c),common_clim)
end
cb=colorbar(ax(end));
cb.Layout.Tile='south';
cb.Label.String='EMG activity (a.u.)';
title(tl,['Mean spinal maps - ' participant])
tl.Padding='compact'; tl.TileSpacing='compact';

%% Mean MoS

clear
clc

participant='PIL03';
cond={'NW','VM','CT'};
side={'Left','Right'};

subject_path=find_subject_path(participant);
load(fullfile(subject_path,'Results.mat'))

figure
tl=tiledlayout(2,2);
cms=colormap(nebula(3));
for i=1:2
    if i==1
        lab='MoS_ML';
    else
        lab='MoS_AP_Heel';
    end
    for j=1:2
        nexttile
        box on
        hold on
        for c=1:3
            if isfield(Results,cond{c}) && isfield(Results.(cond{c}),'MoS')
                m=Results.(cond{c}).MoS.(side{j}).(lab).NormalizedMean;
                s=Results.(cond{c}).MoS.(side{j}).(lab).NormalizedStd;
                plot(0:1:100,m,"LineWidth",1.5,"Color",cms(c,:))
                f=fill([0:1:100 100:-1:0],[(m+s) fliplr(m-s)],'c');
                f.FaceColor=cms(c,:);
                f.EdgeColor='none';
                f.FaceAlpha=0.2;
            end
        end
        if i==1
            title(side{j})
        else
            xlabel("% stance phase")
        end
        if j==1 && i==1
            ylabel("Mediolateral","FontWeight","bold")
        elseif j==1 && i==2
            ylabel("Anteroposterior","FontWeight","bold")
        end
        if i==2 && j==2
            legend(reshape([cond;repmat({''},1,length(cond))],1,[]),'Location','best')
        end
    end
end
title(tl,['Normalized margin of stability - ' participant])
tl.Padding='compact'; tl.TileSpacing='compact';

%% Mean CRP

clear
clc

participant='PIL01';
cond={'NW','VM','CT'};
side={'Left','Right'};

subject_path=find_subject_path(participant);
load(fullfile(subject_path,'Results.mat'))

figure
tl=tiledlayout(2,2);
cms=colormap(nebula(3));
for i=1:2
    if i==1
        lab='Knee_Hip';
    else
        lab='Ankle_Knee';
    end
    for j=1:2
        nexttile
        box on
        hold on
        for c=1:3
            if isfield(Results,cond{c}) && isfield(Results.(cond{c}),'CRP')
                m=Results.(cond{c}).CRP.(side{j}).MARP.(lab);
                s=Results.(cond{c}).CRP.(side{j}).DP.(lab);
                plot(0:1:100,m,"LineWidth",1.5,"Color",cms(c,:))
                f=fill([0:1:100 100:-1:0],[(m+s) fliplr(m-s)],'c');
                f.FaceColor=cms(c,:);
                f.EdgeColor='none';
                f.FaceAlpha=0.2;
            end
        end
        ylim([0 180])
        if i==1
            title(side{j})
        else
            xlabel("% gait cycle")
        end
        if j==1 && i==1
            ylabel("Knee-Hip","FontWeight","bold")
        elseif j==1 && i==2
            ylabel("Ankle-Knee","FontWeight","bold")
        end
        if i==2 && j==2
            legend(reshape([cond;repmat({''},1,length(cond))],1,[]),'Location','best')
        end
    end
end
title(tl,['Mean absolute relative phase - ' participant])
tl.Padding='compact'; tl.TileSpacing='compact';

%% Mean EMG Envelopes

clear
clc

participant='PIL03';
cond={'NW','VM','CT'};
side={'Left','Right'};

subject_path=find_subject_path(participant);
load(fullfile(subject_path,'Results.mat'))

cms=nebula(3);

for j=1:2
    figure
    ref_cond='';
    for c=1:3
        if isfield(Results,cond{c}) && isfield(Results.(cond{c}),'Envelopes') && isfield(Results.(cond{c}).Envelopes,side{j})
            ref_cond=cond{c};
            break
        end
    end
    if isempty(ref_cond)
        warning('Pas d''enveloppes EMG disponibles côté %s pour %s.',side{j},participant)
        continue
    end
    muscles=fieldnames(Results.(ref_cond).Envelopes.(side{j}));
    n=length(muscles);

    tl=tiledlayout(ceil(n/3),3);
    for m=1:n
        nexttile
        box on
        hold on
        for c=1:3
            if isfield(Results,cond{c}) && isfield(Results.(cond{c}),'Envelopes') && isfield(Results.(cond{c}).Envelopes,side{j}) && isfield(Results.(cond{c}).Envelopes.(side{j}),muscles{m})
                env=Results.(cond{c}).Envelopes.(side{j}).(muscles{m});
                plot(0:1:100,env.mean,"LineWidth",1.5,"Color",cms(c,:))
                f=fill([0:1:100 100:-1:0],[(env.mean+env.std) fliplr(env.mean-env.std)],'c');
                f.FaceColor=cms(c,:);
                f.EdgeColor='none';
                f.FaceAlpha=0.2;
            end
        end
        title(strrep(muscles{m},'_',' '))
        xlabel("% gait cycle")
    end
    lgd=legend(reshape([cond;repmat({''},1,length(cond))],1,[]),'Orientation','horizontal');
    lgd.Layout.Tile='south';
    title(tl,[side{j} ' EMG envelopes - ' participant])
    tl.Padding='compact'; tl.TileSpacing='compact';
end

%% Synergies and mean activation coefficients

clear
clc

participant='PIL03';
cond={'NW','VM','CT'};
side={'Left','Right'};
muscles={'TA','SOL','GM','RF','VL','ST','GMED'};

subject_path=find_subject_path(participant);
load(fullfile(subject_path,'Results.mat'))

cms=nebula(3);

for j=1:2
    avail=false(1,3);
    k_all=zeros(1,3);
    for c=1:3
        avail(c)=isfield(Results,cond{c}) && isfield(Results.(cond{c}),'Synergies') && isfield(Results.(cond{c}).Synergies,side{j});
        if avail(c)
            k_all(c)=Results.(cond{c}).Synergies.(side{j}).k;
        end
    end
    if ~any(avail)
        warning('Pas de synergies disponibles côté %s pour %s.',side{j},participant)
        continue
    end

    % Appariement des synergies entre conditions (similarité cosinus des
    % poids musculaires W), en prenant NW comme référence (ou, à défaut,
    % la condition avec le plus de synergies). Toutes les synergies de
    % toutes les conditions sont conservées : celles qui dépassent le
    % nombre de synergies de la référence sont alignées entre elles dans
    % des lignes supplémentaires.
    idx=find(avail);
    Ws=cell(1,numel(idx));
    for ii=1:numel(idx)
        Ws{ii}=Results.(cond{idx(ii)}).Synergies.(side{j}).W;
    end
    ref_c=find(strcmp(cond(idx),'NW'),1);
    [row_assignment,k_max]=align_synergies(Ws,ref_c);
    perm=cell(1,3);
    for ii=1:numel(idx)
        perm{idx(ii)}=row_assignment{ii};
    end

    figure
    tl=tiledlayout(k_max,2);
    for s=1:k_max
        Wmat=NaN(numel(muscles),3);
        for c=1:3
            if avail(c) && ~isnan(perm{c}(s))
                Wmat(:,c)=Results.(cond{c}).Synergies.(side{j}).W(:,perm{c}(s));
            end
        end
        nexttile
        b=bar(Wmat);
        for c=1:3
            b(c).FaceColor=cms(c,:);
        end
        set(gca,'XTick',1:numel(muscles),'XTickLabel',muscles)
        ylabel(sprintf('Synergy %d',s),"FontWeight","bold")
        if s==1
            title('Muscle weightings (W)')
            legend(cond,'Location','best')
        end

        nexttile
        box on
        hold on
        for c=1:3
            if avail(c) && ~isnan(perm{c}(s))
                m=Results.(cond{c}).Synergies.(side{j}).C(perm{c}(s),:);
                sd=Results.(cond{c}).Synergies.(side{j}).C_std(perm{c}(s),:);
                plot(0:1:100,m,"LineWidth",1.5,"Color",cms(c,:))
                f=fill([0:1:100 100:-1:0],[(m+sd) fliplr(m-sd)],'c');
                f.FaceColor=cms(c,:);
                f.EdgeColor='none';
                f.FaceAlpha=0.2;
            end
        end
        if s==1
            title('Activation coefficients (C)')
        end
        if s==k_max
            xlabel("% gait cycle")
        end
    end
    title(tl,[side{j} ' muscle synergies - ' participant])
    tl.Padding='compact'; tl.TileSpacing='compact';
end

%% Functions

function subject_path = find_subject_path(participant)
% Recherche le dossier du participant (ex: 'PIL01') parmi les groupes
% traités par main.m, et renvoie son chemin complet.

folder = fileparts(which('main.m'));
group  = {'PIL', 'CP', 'TD'};

for g = 1:length(group)
    candidate = fullfile(folder, group{g}, char(participant));
    if exist(candidate, 'dir')
        subject_path = candidate;
        return
    end
end

error('Participant %s introuvable.', participant)

end

function side = pick_spinal_side(participant)
% Renvoie le côté ('Left' ou 'Right') avec le plus grand nombre de
% muscles mesurés parmi ceux utilisés par la carte spinale.

chart_muscles = {'GMAX','GMED','TFL','SART','ADD','RF','VL','VM','BF','ST','GL','GM','SOL','PERL','TA'};
tab_asso = EMG_association(participant);

side_list = {'Left', 'Right'};
n_muscles = zeros(1, 2);

for i = 1:size(tab_asso, 1)
    if isempty(tab_asso{i, 2})
        continue
    end
    for j = 1:2
        prefix = [side_list{j} '_'];
        if startsWith(tab_asso{i, 1}, prefix) && ismember(strrep(tab_asso{i, 1}, prefix, ''), chart_muscles)
            n_muscles(j) = n_muscles(j) + 1;
        end
    end
end

if n_muscles(2) >= n_muscles(1)
    side = 'Right';
else
    side = 'Left';
end

end
