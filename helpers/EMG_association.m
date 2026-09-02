function [tab_asso] = EMG_association(ID_participant)

exceptions=["PIL01","PIL02","PIL03","PIL04"];

if ~any(strcmp(ID_participant, exceptions))
    tab_asso={
        'Right_RF'     , 1;
        'Left_RF'      , 2;
        'Right_VL'     , 3;
        'Left_VL'      , 4;
        'Right_VM'     , 5;
        'Left_VM'      , [];
        'Left_ST'      , [];
        'Right_ST'     , 7;
        'Left_BF'      , [];
        'Right_BF'     , 6;
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
        case {'PIL02','PIL03'}
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
        case 'PIL04'
            tab_asso={
                'Right_RF'     , 1;
                'Left_RF'      , 2;
                'Right_VL'     , 3;
                'Left_VL'      , 4;
                'Right_VM'     , 5;
                'Left_VM'      , [];
                'Left_ST'      , [];
                'Right_ST'     , 7;
                'Left_BF'      , [];
                'Right_BF'     , 6;
                'Right_GMED'   , 8;
                'Left_GMED'    , [];
                'Right_TA'     , 11;
                'Right_TA_dist', 12;
                'Left_TA'      , 9;
                'Left_TA_dist' , 10;
                'Right_SOL'    , 13;
                'Left_SOL'     , 14;
                'Right_GM'     , 15;
                'Left_GM'      , 16;
                };
        otherwise
            error('Unknown participant ID: %s',ID_participant);
    end
end

end