function [R] = compute_metrics(D,R,metrics)

%{
Computes the requested Results subfields for a single condition. D is the
Data struct returned by restructure_c3d/name_emg, R is the existing Results
structure (possibly empty), metrics is a string array of subfield names 
to (re)compute.
%}

if ismember("Envelopes",metrics)
    metrics=union(metrics,["Synergies","SpinalMaps"]);
end
if any(ismember(["Synergies","SpinalMaps"],metrics)) && ~isfield(R,'Envelopes')
    R.Envelopes=get_envelope(D);
end

if ismember("Envelopes",metrics),  R.Envelopes=get_envelope(D);              end
if ismember("Synergies",metrics),  R.Synergies=get_synergies(R.Envelopes);   end
if ismember("SpinalMaps",metrics), R.SpinalMaps=get_spinalmap(R.Envelopes);  end
if ismember("MoS",metrics),        R.MoS=get_mos(D);                         end
if ismember("TO",metrics),         R.TO=get_toeoff(D);                       end
if ismember("CRP",metrics),        R.CRP=get_crp(D);                         end
if ismember("Bursts",metrics),     R.Bursts=get_bursts(D);                   end
if ismember("Coherence",metrics),  R.Coherence=get_coherence(D);             end

end
