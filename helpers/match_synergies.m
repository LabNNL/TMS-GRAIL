function [perm] = match_synergies(W_ref,W)

%{
Matches the columns (synergies) of W to the columns of W_ref based on the
cosine similarity of their muscle weightings, using an optimal
(min-cost) assignment. W and W_ref can have a different number of
columns.

Returns perm (1 x size(W_ref,2)) such that column perm(i) of W is the
best match for column i of W_ref. perm(i)=NaN if no column of W was
assigned to reference synergy i (happens when W has fewer synergies than
W_ref).
%}

k_ref=size(W_ref,2);

sim=(W_ref'*W)./(vecnorm(W_ref)'*vecnorm(W)+eps);                           % Cosine similarity, k_ref x k
cost=1-sim;

M=matchpairs(cost,2);                                                       % Unmatched cost > max possible cost (1), forces every column of W to be matched
perm=NaN(1,k_ref);
perm(M(:,1))=M(:,2);

end
