
function MEP_mean_fig(MEP,varargin)

% Optional arguments: Plot color and Standard deviation alpha

if nargin==1
    c='#8E7DDB';
    a=.3;
elseif nargin==2
    c=varargin{1};
    a=.3;
elseif nargin==3
    c=varargin{1};
    a=varargin{2};
end

% Mean and STD calculation

[nb_meps,len_meps]=size(MEP.All);
temp=zeros(nb_meps,len_meps);

for i=1:nb_meps
    temp(i,:)=MEP.(['MEP_' num2str(i,'%02d')]).EMG';
end
mean_meps=mean(temp,1);
std_meps=std(temp,1);

% Figure drawing

hold on
time=MEP.Meta.Time_ms;
plot(time,mean_meps,'LineWidth',2,'Color',c)
f=fill([time fliplr(time)],[(mean_meps+std_meps) fliplr((mean_meps-std_meps))],'c');
f.FaceColor=c;
f.EdgeColor='none';
f.FaceAlpha=a;

end