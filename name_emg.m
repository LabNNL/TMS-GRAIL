function emg = name_emg(emg,tab_assoc)

%{
Renames the "SensorX" fields in the EMG substructure to the associated
muscles specified in tab_assoc.
- emg : struct
- tab_assoc : cell array
%}

for i=1:size(tab_assoc,1)
    if ~isempty(tab_assoc{i,2})
        field_sensor=['Sensor', num2str(tab_assoc{i,2})];
        emg.(tab_assoc{i,1})=emg.(field_sensor);
        emg=rmfield(emg,field_sensor);
    end
end

end