function [env_struc] = get_envelope(struc)

side={'Left','Right'};

first_frame=struc.FirstFrame;
analog_frequency=struc.AnalogFrequency;
frequency=struc.Frequency;

fc=[20 450];                                                                % Filtering band-pass
[b,a]=butter(2,2*fc/analog_frequency,'bandpass');
fce=10;                                                                     % Envelope low-pass
[be,ae]=butter(2,2*fce/analog_frequency,'low');

for j=1:2

    hs_lab=[side{j} '_Foot_Strike'];
    nbc=length(struc.Events.(hs_lab))-1;
    HS=round(struc.Events.(hs_lab)*analog_frequency-first_frame/frequency*analog_frequency+1);

    fields=fieldnames(struc.EMG);
    muscles=fields(startsWith(fields,side{j}));

    for m=1:length(muscles)
        emg_raw=struc.EMG.(muscles{m});
        emg_filt=filtfilt(b,a,emg_raw);
        envelope=filtfilt(be,ae,abs(emg_filt));
        cycles_norm = zeros(nbc, 101);
        cycles_raw = cell(nbc, 1);

        for cy=1:nbc
            temp=envelope(HS(cy):HS(cy+1));
            cycles_raw{cy}=temp;
            cycles_norm(cy,:)=interp1(1:length(temp),temp,linspace(1,length(temp),101),'linear');
        end

        lab=strrep(muscles{m},[side{j} '_'], '');
        env_struc.(side{j}).(lab).cycles_raw=cycles_raw;
        env_struc.(side{j}).(lab).cycles_norm=cycles_norm;
        env_struc.(side{j}).(lab).mean=mean(cycles_norm,1);
        env_struc.(side{j}).(lab).std=std(cycles_norm,0,1);
    end

end

end