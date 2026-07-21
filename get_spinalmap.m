function [spi_struc] = get_spinalmap(env_struc)

%{
Calculates and maps the mean EMG activity on spinal segments.
Requires the structure returned by the 'get_envelope' function.
%} 

%% Kendall chart of muscle innervation (from Cappellini et al. 2010)

%    GMAX GMED  TFL SART  ADD  RF   VL   VM   BF   ST   GL   GM   SOL PERL  TA
coef=[ 0    0    0    1    1    1    1    1    0    0    0    0    0    0    0 ;...  L2
       0    0    0    1    1    1    1    1    0    0    0    0    0    0    0;...   L3
       0    1    1    0   .5    1    1    1    0   .5    0    0    0   .5    1;...   L4
       1    1    1    0    0    0    0    0   .5    1    0    0   .5    1    1;...   L5
       1    1    1    0    0    0    0    0    1    1    1    1    1    1    1;...   S1
       1    0    0    0    0    0    0    0    1    1    1    1    1    0    0];...  S2

chart=array2table(coef, "RowNames",{'L2','L3','L4','L5','S1','S2'},...
"VariableNames",{'GMAX','GMED','TFL','SART','ADD','RF','VL','VM','BF','ST','GL','GM','SOL','PERL','TA'});

%% Spinal map computation

side={'Left','Right'};

for j=1:2

    fields=fieldnames(env_struc.(side{j}));
    nbc=length(env_struc.(side{j}).(fields{1}).cycles_raw);
    temp=zeros(6,101,nbc);

    present_mus=intersect(fields,chart.Properties.VariableNames);
    if ~isempty(present_mus)
        mus_per_segment=sum(chart{:,present_mus},2);
    else
        warning('No muscle found for %s side.',side{j});
        continue
    end
    if any(mus_per_segment==0)
        warning('One spinal segment has no measured muscles')
        mus_per_segment(mus_per_segment== 0)=NaN;
    end

    for cy=1:nbc
        len_cy=length(env_struc.(side{j}).(fields{1}).cycles_raw{cy});
        spi_act=zeros(6,101);
        for i=1:length(fields)
            if ismember(fields{i},chart.Properties.VariableNames)
                mus_act=env_struc.(side{j}).(fields{i}).cycles_raw{cy}(:)';
                mus_act_norm=interp1(linspace(0,100,len_cy),mus_act,linspace(0,100,101),"linear");
                spi_act=spi_act+(chart.(fields{i})*mus_act_norm);
            end
        end
        spi_act_norm=spi_act./mus_per_segment;
        spi_struc.(side{j}).cycles{cy}=spi_act_norm;
        temp(:,:,cy)=spi_act_norm;
    end
    
    % Mean and std
    spi_struc.(side{j}).mean=mean(temp,3);
    spi_struc.(side{j}).std=std(temp,0,3);
    
    % Center of activity
    y_pos=(1:6)';
    spi_struc.(side{j}).coa=sum(mean(temp,3).*y_pos,1)./sum(mean(temp,3),1);

end

end