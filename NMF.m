function [W,C,vaf,varargout] = NMF(M,k,varargin)

%{
Non-negative Matrix Factorization
- M : d muscles x n samples
- k : Number of synergies
- varargin{1} : number of iterations

- W : Synergy matrix (d x k)
- C : Activation coefficients matrix (k x n)
- varargout : vector with the individual VAF of the d muscles
%}

if nargin<3
    maxrun=1;
else
    maxrun=varargin{1};
end

[d,n]=size(M);
max_iter=1000;

run_vaf=zeros(1,maxrun);
run_W=cell(1,maxrun);
run_C=cell(1,maxrun);
run_mus=zeros(d,maxrun);

Mf=sum(M.^2,'all');
Mf_mus=sum(M.^2,2);

for r=1:maxrun

    [W]=rand(d,k);
    [C]=rand(k,n);
    vaf_hist=zeros(1,max_iter);


    for it=1:max_iter
        
        denC=(W')*W*C;
        C=C.*((W')*M)./(denC+eps(denC));                                    % eps empêche la division par 0
        denW=W*C*(C');
        W=W.*(M*C')./(denW+eps(denW));

        [E]=M-W*C;
        Ef=sum(E.^2,'all');
        vaf_hist(it)=(1-Ef/Mf)*100;

        if it>5 && (vaf_hist(it)-vaf_hist(it-4)<0.01)                       % 5 itérations consécutives sans augmentation de 0,01% de VAF
            break
        end
    end

    for i=1:k
        nw=norm(W(:,i));
        W(:,i)=W(:,i)/nw;                                                   % Normalisation
        C(i,:)=C(i,:)*nw;                                                   % Ajustement de C pour reconstruction
    end

    Ef_mus=sum((M-W*C).^2,2);                                               % VAF individuelle de chaque muscle
    vaf_mus=(1-(Ef_mus./Mf_mus))*100;

    run_vaf(r)=vaf_hist(it);
    run_W{r}=W;
    run_C{r}=C;
    run_mus(:,r)=vaf_mus;
end

[vaf,idx]=max(run_vaf);
W=run_W{idx};
C=run_C{idx};

if nargout>3
    varargout{1}=run_mus(:,idx);
end

end