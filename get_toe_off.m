function [to_struc] = get_toe_off(struc)

side={'Left','Right'};

for j=1:2

    hs_lab=[side{j} '_Foot_Strike'];                                        % HS and TO subfields
    to_lab=[side{j} '_Foot_Off'];
    nbc=numel(struc.Events.(hs_lab))-1;
    HS=round(struc.Events.(hs_lab)*struc.Frequency-struc.FirstFrame+1);
    TO=round(struc.Events.(to_lab)*struc.Frequency-struc.FirstFrame+1);
    to_struc.(side{j}).cycles = NaN(nbc,1);

    for cy=1:nbc

        TOcy=TO(TO>HS(cy) & TO<HS(cy+1));
        assert(numel(TOcy)<=1,'More than one Toe Off found in gait cycle %d (%s side).',cy,side{j});
        if isempty(TOcy)
            to_struc.(side{j}).cycles(cy)=NaN;
        else
            to_struc.(side{j}).cycles(cy)=((TOcy-HS(cy))/(HS(cy+1)-HS(cy)))*100;
        end
    end
    
    to_struc.(side{j}).mean=mean(to_struc.(side{j}).cycles,'omitnan');

end

end