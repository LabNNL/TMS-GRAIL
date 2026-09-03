function [env_struc] = get_envelope(struc)

%{
Calculates the EMG envelopes on all gait cycles, as well as the mean and
standard deviation across the trial.

A cycle is excluded if any muscle has an amplitude spike outlier
(robust z-score of the cycle's peak envelope vs. the other cycles)

Requires the raw structure returned by 'restructure_c3d'.
%}

side={'Left','Right'};

first_frame=struc.FirstFrame;
analog_frequency=struc.AnalogFrequency;
frequency=struc.Frequency;

fc=[20 450];                                                                % Filtering band-pass
[b,a]=butter(2,2*fc/analog_frequency,'bandpass');
fce=10;                                                                     % Envelope low-pass
[be,ae]=butter(2,2*fce/analog_frequency,'low');

amp_z_fail=5;                                                               % Robust (MAD-based) z-score: flag amplitude spike outliers

for j=1:2

    hs_lab=[side{j} '_Foot_Strike'];
    nbc=length(struc.Events.(hs_lab))-1;
    HS=round(struc.Events.(hs_lab)*analog_frequency-first_frame/frequency*analog_frequency+1);

    fields=fieldnames(struc.EMG);
    muscles=fields(startsWith(fields,side{j}));

    labels=cell(length(muscles),1);
    cycles_raw_all=cell(length(muscles),1);
    cycles_norm_all=cell(length(muscles),1);
    cycle_ok=true(nbc,1);

    for m=1:length(muscles)
        emg_raw=struc.EMG.(muscles{m});
        emg_filt=filtfilt(b,a,emg_raw);
        envelope=filtfilt(be,ae,abs(emg_filt));
        cycles_norm = zeros(nbc, 101);
        cycles_raw = cell(nbc, 1);
        peak_amp = nan(nbc,1);

        for cy=1:nbc
            temp=envelope(HS(cy):HS(cy+1));
            cycles_raw{cy}=temp;
            cycles_norm(cy,:)=interp1(1:length(temp),temp,linspace(1,length(temp),101),'linear');
            peak_amp(cy)=max(temp);
        end

        med=median(peak_amp,'omitnan'); madv=median(abs(peak_amp-med),'omitnan');
        sigma=1.4826*madv+eps;
        amp_z=(peak_amp-med)/sigma;
        amp_ok=amp_z<=amp_z_fail;
        cycle_ok=cycle_ok & amp_ok;

        lab=strrep(muscles{m},[side{j} '_'], '');
        labels{m}=lab;
        cycles_raw_all{m}=cycles_raw;
        cycles_norm_all{m}=cycles_norm;

        env_struc.(side{j}).(lab).amp_z=amp_z;
        env_struc.(side{j}).(lab).amp_ok=amp_ok;
    end

    for m=1:length(muscles)
        lab=labels{m};
        env_struc.(side{j}).(lab).cycle_ok=cycle_ok;
        env_struc.(side{j}).(lab).n_cycles_total=nbc;
        env_struc.(side{j}).(lab).n_excluded=nbc-sum(cycle_ok);
        env_struc.(side{j}).(lab).cycles_raw=cycles_raw_all{m}(cycle_ok);
        env_struc.(side{j}).(lab).cycles_norm=cycles_norm_all{m}(cycle_ok,:);
        env_struc.(side{j}).(lab).mean=mean(env_struc.(side{j}).(lab).cycles_norm,1);
        env_struc.(side{j}).(lab).std=std(env_struc.(side{j}).(lab).cycles_norm,0,1);
    end

end

end