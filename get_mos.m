function [mos_struct] = get_mos(struct)

side={'Left','Right'};
fs=struct.Frequency;
fc=6;                                                                       % Low-pass at 6 Hz

% Centre of mass

[b,a]=butter(2,2*fc/fs,'low');
com_ap=filtfilt(b,a,-struct.CentreOfMass(:,2)');                            % In the direction of progression
com_v=filtfilt(b,a,struct.CentreOfMass(:,3)');                              % See lab coordinate system
vcom_ap=gradient(com_ap,1/fs)+struct.Misc.WalkingSpeed*1000;

for j=1:2
    
    if j==1
        com_ml=filtfilt(b,a,struct.CentreOfMass(:,1)');                     % From medial to lateral
    else
        com_ml=filtfilt(b,a,-struct.CentreOfMass(:,1)');  
    end
    vcom_ml=gradient(com_ml,1/fs);

    % Events

    hs_lab=[side{j} '_Foot_Strike'];                                        % HS and TO subfields
    to_lab=[side{j} '_Foot_Off'];
    nbc=length(struct.Events.(hs_lab))-1;
    HS=round(struct.Events.(hs_lab)*struct.Frequency-struct.FirstFrame+1);  % A check
    TO=round(struct.Events.(to_lab)*struct.Frequency-struct.FirstFrame+1);
    
    % Eigenfrequency of pendulum

    jc_lab=[side{j}(1),'AJC'];                                              % Ankle joint center
    ajc_v=filtfilt(b,a,struct.Misc.(jc_lab)(:,3)');
    temp_tab=[];
    ind=1;                                                                  % Mean height difference between CoM
    for cy=1:nbc                                                            % and the ankle axis during stance
        TOcy=TO(TO>HS(cy) & TO<HS(cy+1));
        if isempty(TOcy)
            continue
        else
            temp=com_v(HS(cy):TOcy)-ajc_v(HS(cy):TOcy);
            temp_tab(ind,:)=interp1(linspace(1,length(temp),length(temp)),temp,linspace(1,length(temp),101));
            ind=ind+1;
        end
    end
    L0=mean(temp_tab,'all');                                                % Effective pendulum length
    mos_struct.(side{j}).L0=L0;
    omega_0=sqrt(9806.65/L0);                                               % g in mm/s^2

    % Extrapolated centre of mass

    xcom_ap=com_ap+vcom_ap/omega_0;
    xcom_ml=com_ml+vcom_ml/omega_0;
    mos_struct.(side{j}).XcoM_AP=xcom_ap;
    mos_struct.(side{j}).XcoM_ML=xcom_ml;

    % Markers

    heel_lab=[side{j}(1),'HEE'];
    toe_lab=[side{j}(1),'TOE'];
    vmh_lab=[side{j}(1),'VMH'];
    heel_ap=filtfilt(b,a,-struct.Markers.(heel_lab)(:,2)');
    toe_ap=filtfilt(b,a,-struct.Markers.(toe_lab)(:,2)');
    if j==1
        vmh_ml=filtfilt(b,a,struct.Markers.(vmh_lab)(:,1)');
    else
        vmh_ml=filtfilt(b,a,-struct.Markers.(vmh_lab)(:,1)');
    end
    
    % Margin of stability
    
    mos_ap_heel_temp=[];
    mos_ap_toe_temp=[];
    mos_ml_temp=[];
    ind=1;
    for cy=1:nbc
        TOcy=TO(TO>HS(cy) & TO<HS(cy+1));
        if isempty(TOcy)
            continue
        else
            temp_heel=heel_ap(HS(cy):TOcy)-xcom_ap(HS(cy):TOcy);
            temp_toe=toe_ap(HS(cy):TOcy)-xcom_ap(HS(cy):TOcy);
            temp_vmh=vmh_ml(HS(cy):TOcy)-xcom_ml(HS(cy):TOcy);
            mos_struct.(side{j}).MoS_AP_Heel.Cycles{cy,1}=temp_heel;
            mos_struct.(side{j}).MoS_AP_Toe.Cycles{cy,1}=temp_toe;
            mos_struct.(side{j}).MoS_ML.Cycles{cy,1}=temp_vmh;
            
            len=size(temp_heel,2);
            mos_ap_heel_temp(ind,:)=interp1(linspace(1,len,len),temp_heel,linspace(1,len,101));
            mos_ap_toe_temp(ind,:)=interp1(linspace(1,len,len),temp_toe,linspace(1,len,101));
            mos_ml_temp(ind,:)=interp1(linspace(1,len,len),temp_vmh,linspace(1,len,101));
            ind=ind+1;
        end
    end
    
    % Mean over cycles and normalization
    
    leg_lab=[side{j}(1),'LegLength'];
    atd_lab=[side{j}(1),'AsisTrocanterDistance'];
    trocanter_height=struct.Misc.(leg_lab)-struct.Misc.(atd_lab);
    mos_struct.(side{j}).TrocanterHeight=trocanter_height;

    mos_struct.(side{j}).MoS_AP_Heel.NormalizedMean=mean(mos_ap_heel_temp,1)/trocanter_height;
    mos_struct.(side{j}).MoS_AP_Toe.NormalizedMean=mean(mos_ap_toe_temp,1)/trocanter_height;
    mos_struct.(side{j}).MoS_ML.NormalizedMean=mean(mos_ml_temp,1)/trocanter_height;

    mos_struct.(side{j}).MoS_AP_Heel.NormalizedStd=std(mos_ap_heel_temp,0,1)/trocanter_height;
    mos_struct.(side{j}).MoS_AP_Toe.NormalizedStd=std(mos_ap_toe_temp,0,1)/trocanter_height;
    mos_struct.(side{j}).MoS_ML.NormalizedStd=std(mos_ml_temp,0,1)/trocanter_height;

end

end