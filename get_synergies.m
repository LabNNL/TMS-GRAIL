function [syn_struc] = get_synergies(env_struc)

%{
Determines the optimal number of muscle synergies and calculates synergies
and their activation coefficients on concatenated amplitude- and
time-normalized envelopes of muscle activity.
Requires the structure returned by the 'get_envelope' function.
%}

side={'Left','Right'};
mus={'TA','SOL','GM','RF','VL','ST','GMED'};
nbm=numel(mus);

for j=1:2

    fields=fieldnames(env_struc.(side{j}));
    missing_mus=setdiff(mus,fields);

    if ~isempty(missing_mus)
        continue
    else
        
        nbc=length(env_struc.(side{j}).(fields{1}).cycles_raw);
        M=zeros(nbm,nbc*101);
        for m=1:nbm
            temp=env_struc.(side{j}).(mus{m}).cycles_norm;
            M(m,:)=reshape(temp',1,[]);
        end
        M=M./max(M,[],2);
        syn_struc.(side{j}).M=M;
        
        % Determination of the number of synergies
        vaf=zeros(1,nbm);
        vaf_mus=zeros(nbm,nbm);
        for m=1:nbm
            [~,~,vaf_temp,vaf_mus_temp]=NMF(M,m,10);                        % 10 repetitions
            vaf(m)=vaf_temp;
            vaf_mus(:,m)=vaf_mus_temp;
        end
        k=nbm;
        for m=1:nbm
            if vaf(m)>90 && all(vaf_mus(:,m)>75)
                k=m;
                break
            end
        end
        syn_struc.(side{j}).k=k;
        syn_struc.(side{j}).vaf_curve=vaf;
        syn_struc.(side{j}).vaf_mus=vaf_mus;

        % Synergies and activation coefficients calculation
        [W,C_conc,VAF,vaf_ind]=NMF(M,k,100);                                % 100 repetitions
        syn_struc.(side{j}).W=W;
        syn_struc.(side{j}).VAF=VAF;
        syn_struc.(side{j}).vaf_ind=vaf_ind;
        C=reshape(C_conc,k,101,nbc);
        syn_struc.(side{j}).C=mean(C,3);
        syn_struc.(side{j}).C_std=std(C,0,3);
        syn_struc.(side{j}).C_cycles=C;

    end

end

end