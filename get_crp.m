function [crp_struct] = get_crp(struct)

side={'Left','Right'};
angle={'Hip','Knee','Ankle'};
pad=.1*struct.Frequency;

fc=6; fs=struct.Frequency;
[b,a]=butter(2,2*fc/fs,'low');

for j=1:2

    hs_lab=[side{j} '_Foot_Strike'];                                        % HS and TO subfields
    to_lab=[side{j} '_Foot_Off'];
    nbc=length(struct.Events.(hs_lab))-1;
    HS=round(struct.Events.(hs_lab)*struct.Frequency-struct.FirstFrame+1);  % A check
    TO=round(struct.Events.(to_lab)*struct.Frequency-struct.FirstFrame+1);
    crp_kh_temp=[];
    crp_ak_temp=[];
    ind=1;

    for cy=1:nbc

        TOcy=TO(TO>HS(cy) & TO<HS(cy+1));
        if isempty(TOcy)
            crp_struct.(side{j}).toe_off_timing(cy,1)=0;
        else
            crp_struct.(side{j}).toe_off_timing(cy,1)=((TOcy-HS(cy))/(HS(cy+1)-HS(cy)))*100;
        end
        lb=HS(cy)-pad;
        ub=HS(cy+1)+pad;

        if lb<1 || ub>struct.LastFrame-struct.FirstFrame+1                  % padding out of bounds
            continue
        else
            for ang=1:length(angle)
                ang_lab=[side{j}(1),angle{ang},'Angles'];
                temp_filt=filtfilt(b,a,struct.Angles.(ang_lab));
                temp=temp_filt(lb:ub,1);
                crp_struct.(side{j}).cycles_padded.(angle{ang}){cy,1}=temp';
                PA_temp=Phase_Angle(temp);
                crp_struct.(side{j}).phase_angles.(angle{ang}){cy,1}=PA_temp(pad+1:end-pad,1)';
            end

            h_ang=crp_struct.(side{j}).phase_angles.Hip{cy,1};
            k_ang=crp_struct.(side{j}).phase_angles.Knee{cy,1};
            a_ang=crp_struct.(side{j}).phase_angles.Ankle{cy,1};
            temp=CRP(k_ang,h_ang);
            crp_norm=interp1(linspace(1,size(temp,2),size(temp,2)),temp,linspace(1,size(temp,2),101));
            crp_struct.(side{j}).CRP_cycles.Knee_Hip{cy,1}=crp_norm;
            crp_kh_temp(ind,:)=crp_norm;
            temp=CRP(a_ang,k_ang);
            crp_norm=interp1(linspace(1,size(temp,2),size(temp,2)),temp,linspace(1,size(temp,2),101));
            crp_struct.(side{j}).CRP_cycles.Ankle_Knee{cy,1}=crp_norm;
            crp_ak_temp(ind,:)=crp_norm;
            ind=ind+1;

        end
    end

    crp_struct.(side{j}).MARP.Knee_Hip=mean(crp_kh_temp,1);
    crp_struct.(side{j}).MARP.Ankle_Knee=mean(crp_ak_temp,1);
    crp_struct.(side{j}).DP.Knee_Hip=std(crp_kh_temp,0,1);
    crp_struct.(side{j}).DP.Ankle_Knee=std(crp_ak_temp,0,1);

end

end