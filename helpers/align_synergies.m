function [row_assignment,k_max] = align_synergies(Ws,ref_c)

%{
Aligns the synergies (columns of W) of several conditions onto a common
set of rows, based on cosine similarity of muscle weightings (see
match_synergies), so that every synergy of every condition is shown.

The reference condition (ref_c, if given) sets the order of the first
rows. Any synergies left unmatched (conditions with more synergies than
the reference) are then progressively aligned among themselves in
further rounds, so no synergy is dropped.

- Ws : 1 x n cell array of W matrices (nbm x k_c), one per condition
- ref_c : index of the condition to use as primary reference in Ws
          (optional; if empty or omitted, the condition with the most
          synergies is used, as in every subsequent round)

Returns row_assignment (1 x n cell array); row_assignment{c} is a
1 x k_max vector giving, for each row, the column of Ws{c} assigned to
it (NaN if none). k_max is the resulting number of rows.
%}

if nargin<2
    ref_c=[];
end

n=numel(Ws);
k=cellfun(@(W) size(W,2),Ws);
used=arrayfun(@(kk) false(1,kk),k,'UniformOutput',false);

row_assignment=cell(1,n);
for c=1:n
    row_assignment{c}=[];
end

first_round=true;
while any(cellfun(@(u) any(~u),used))
    if first_round && ~isempty(ref_c) && any(~used{ref_c})
        r=ref_c;
    else
        remaining=cellfun(@(u) sum(~u),used);
        [~,r]=max(remaining);
    end
    first_round=false;

    ref_cols=find(~used{r});
    n_rows=numel(ref_cols);
    for c=1:n
        row_assignment{c}=[row_assignment{c},NaN(1,n_rows)];
    end
    base=numel(row_assignment{r})-n_rows;
    row_assignment{r}(base+1:end)=ref_cols;
    used{r}(ref_cols)=true;

    W_ref_sub=Ws{r}(:,ref_cols);
    for c=1:n
        if c==r || all(used{c})
            continue
        end
        avail_cols=find(~used{c});
        perm=match_synergies(W_ref_sub,Ws{c}(:,avail_cols));
        for i=1:n_rows
            if ~isnan(perm(i))
                col=avail_cols(perm(i));
                row_assignment{c}(base+i)=col;
                used{c}(col)=true;
            end
        end
    end
end

k_max=numel(row_assignment{1});

end
