function [tab_asso] = EMG_association(ID_participant)

exceptions=["PIL01","PIL04"];

if ~any(strcmp(ID_participant, exceptions))
    tab_asso={
    'Right_RF'     , 1;
    'Left_RF'      , 2;
    'Right_VL'     , 3;
    'Left_VL'      , 4;
    'Right_VM'     , 5;
    'Left_VM'      , [];
    'Left_ST'      , 6;
    'Right_ST'     , 7;
    'Right_GMED'   , 8;
    'Left_GMED'    , [];
    'Right_TA'     , 9;
    'Right_TA_dist', 10;
    'Left_TA'      , 11;
    'Left_TA_dist' , 12;
    'Right_SOL'    , 13;
    'Left_SOL'     , 14;
    'Right_GM'     , 15;
    'Left_GM'      , 16;
    };
else
    switch ID_participant
        case 'PIL01'
            tab_asso={
            'Right_RF'     , 1;
            'Left_RF'      , 2;
            'Right_VL'     , 3;
            'Left_VL'      , 4;
            'Right_VM'     , 5;
            'Left_VM'      , [];
            'Left_ST'      , 6;
            'Right_ST'     , 7;
            'Right_GMED'   , 8;
            'Left_GMED'    , [];
            'Right_TA'     , 11;
            'Right_TA_dist', 12;
            'Left_TA'      , 9;
            'Left_TA_dist' , 10;
            'Right_SOL'    , 16;
            'Left_SOL'     , 15;
            'Right_GM'     , 13;
            'Left_GM'      , 14;
            };
        % case 'PIL04'
        %     tab_asso={
        %     'Right_RF'     , 2;
        %     'Left_RF'      , 1;
        %     'Right_VL'     , 4;
        %     'Left_VL'      , 3;
        %     'Right_VM'     , 6;
        %     'Left_VM'      , 5;
        %     'Left_ST'      , 8;
        %     'Right_ST'     , 7;
        %     'Right_GMED'   , 10;
        %     'Left_GMED'    , 9;
        %     'Right_TA'     , 12;
        %     'Right_TA_dist', 11;
        %     'Left_TA'      , 14;
        %     'Left_TA_dist' , 13;
        %     'Right_SOL'    , 16;
        %     'Left_SOL'     , 15;
        %     'Right_GM'     , [];
        %     'Left_GM'      , [];
        %     };
        otherwise
            error('Unknown participant ID: %s',ID_participant);
    end
end

end