function [crp_struc] = get_crp(struc)

%{
Computes Mean Absolute Relative Phase and Deviation Phase for the two
joint pairs Knee-Hip and Ankle-Knee on both sides.
%}

side={'Left','Right'};
angle={'Hip','Knee','Ankle'};
pad=.1*struc.Frequency;

fc=6; fs=struc.Frequency;
[b,a]=butter(2,2*fc/fs,'low');

for j=1:2

    hs_lab=[side{j} '_Foot_Strike'];
    nbc=length(struc.Events.(hs_lab))-1;
    HS=round(struc.Events.(hs_lab)*struc.Frequency-struc.FirstFrame+1);
    crp_kh_temp=[];
    crp_ak_temp=[];
    ind=1;

    for cy=1:nbc

        lb=HS(cy)-pad;
        ub=HS(cy+1)+pad;

        if lb<1 || ub>struc.LastFrame-struc.FirstFrame+1                    % padding out of bounds
            continue
        else
            for ang=1:length(angle)
                ang_lab=[side{j}(1),angle{ang},'Angles'];
                temp_filt=filtfilt(b,a,struc.Angles.(ang_lab));
                temp=temp_filt(lb:ub,1);
                crp_struc.(side{j}).cycles_padded.(angle{ang}){cy,1}=temp';
                PA_temp=Phase_Angle(temp);
                crp_struc.(side{j}).phase_angles.(angle{ang}){cy,1}=PA_temp(pad+1:end-pad,1)';
            end

            h_ang=crp_struc.(side{j}).phase_angles.Hip{cy,1};
            k_ang=crp_struc.(side{j}).phase_angles.Knee{cy,1};
            a_ang=crp_struc.(side{j}).phase_angles.Ankle{cy,1};
            temp=CRP(k_ang,h_ang);
            crp_norm=interp1(linspace(1,size(temp,2),size(temp,2)),temp,linspace(1,size(temp,2),101));
            crp_struc.(side{j}).CRP_cycles.Knee_Hip{cy,1}=crp_norm;
            crp_kh_temp(ind,:)=crp_norm;
            temp=CRP(a_ang,k_ang);
            crp_norm=interp1(linspace(1,size(temp,2),size(temp,2)),temp,linspace(1,size(temp,2),101));
            crp_struc.(side{j}).CRP_cycles.Ankle_Knee{cy,1}=crp_norm;
            crp_ak_temp(ind,:)=crp_norm;
            ind=ind+1;

        end
    end

    crp_struc.(side{j}).MARP.Knee_Hip=mean(crp_kh_temp,1);
    crp_struc.(side{j}).MARP.Ankle_Knee=mean(crp_ak_temp,1);
    crp_struc.(side{j}).DP.Knee_Hip=std(crp_kh_temp,0,1);
    crp_struc.(side{j}).DP.Ankle_Knee=std(crp_ak_temp,0,1);

end

end