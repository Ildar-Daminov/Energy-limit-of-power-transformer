clc
clear all
close all

%% Goal of the script
% This scripts reproduces the Figures from the article [1]:

% If you use this code, please cite this article:
% [1] Ildar Daminov, Anton Prokhorov, Raphael Caire, Marie-Cécile
% Alvarez-Herault, “Energy limit of oil-immersed transformers: A concept
% and its application in different climate conditions” in IET  Generation,
% Transmission & Distribution, 2020, https://doi.org/10.1049/gtd2.12036

% Other articles on this topic are available:
% https://www.researchgate.net/profile/Ildar-Daminov-2

% Note that the figures generated in this script and those given in the
% article may differ a little bit as latter had been additionally redrawn
% for a publication.

% Each section (Plotting the Figure X) is independent from each other. So
% you may launch the entire script (using the button "Run") to get all
% figures at one moment or you may launch a special section (using the
% button "Run Section" at the top)to get a specific figure

% Execution time of entire script ≈ 30 min

tic
%% Plotting the Figure 1
% Figure name: Transformer, limiting an energy transfer between two zones .

% Figure 1 in the article [1] was ploted without using MATLAB

%% Plotting the Figure 2
% Figure name: Maximization of the energy generation using flexibilities by
% RES operators

% Figure 2 in the article [1] was ploted without using MATLAB

%% Plotting the Figure 3
% Figure name: Criteria of thermal ratings for DER interconnection in
% different countries

% Figure 3 in the article [1] was ploted without using MATLAB

%% Plotting the Figure 4
% Figure name: Case study for investigating the highest energy transfer
% through transformers

% Figure 4 in the article [1] was ploted without using MATLAB

%% Plotting the Figure 5
% Figure name: Transformer loadings equal to HST and TOT limits as a
% function of ambient temperatrure.

clc;clear all % clear a command window and a workspace

% Load the daily profile of ambient temperature
load('initial_data.mat','AMB')

% load('initial_data.mat','TIM')
% load('Tamb_february_1_2019.mat')

% Transforming the vector in minutes(1440x1) to a vector in hours (24x1).
% This is neccsary to reduce the size of optimization problem later;

if length(AMB)==1440 % if the length of vector is 1440
    
    t=60; % 60 min per  hour
    
    % number of hours
    nhours=fix(length(AMB)/t);
    
    % reconstruct a daily vector in minutes
    tt=(1:nhours)*t;
    tt=tt';
    
    % intermediate variable: ambient temperature per hour
    AMB_hour=zeros(nhours,1);
    
    for i=1:nhours % for each hour
        % Set the mean ambient temperature
        AMB_hour(i)=mean(AMB(((i-1)*t+1):i*t));
    end
    
    % Change a variable name
    AMB=AMB_hour;
    
end % if length(AMB)==1440

% we'll also create a few variables for time
nHours = numel(AMB);
Time = (1:nHours)';

%--------------------------------------------------------------------------
% Create the optimization problem
Optim_problem=optimproblem('ObjectiveSense','maximize');

% Create a variable: Energy_limit in an hour for transformer
Energy_limit = optimvar('Energy_limit',nHours,'LowerBound',0,'UpperBound',1.5);

% Energy_limit has the lowest value of 0 and the maximal value of 1.5 pu
%--------------------------------------------------------------------------
% Define the objective function
Energy_transfer = sum(Energy_limit);

% Note that sum(Energy_limit) provides the approximate energy transfer.
% For better modelling, the energy transfer should be calculated as the
% integral of Energy_limit (not a sum of 24 values).

% set objective
Optim_problem.Objective = Energy_transfer;

% Show the objective function
showexpr(Energy_transfer)
%--------------------------------------------------------------------------
%                       ONAN power transformer
%--------------------------------------------------------------------------
% Set the constraints for ONAN power transformer in optimization problem
% "Optim_problem"

% Connect the function ONAN.m with constrained variables HST_max,
% TOT_max,AEQ
[HST_max,TOT_max,AEQ,~,~]=fcn2optimexpr(@ONAN,Energy_limit,AMB);
Optim_problem.Constraints.ageing=AEQ<=1;    % ageing, pu
Optim_problem.Constraints.hst=HST_max<=120; % hot spot temperature, °C
Optim_problem.Constraints.tot=TOT_max<=105; % top-oil temperature, °C

%--------------------------------------------------------------------------
% Assuming the first guess as it was done in our simulations
Energy_limit_approx=[1.18506326493039;1.19545602469364;1.20235915543539;...
    1.20407987179434;1.20838166269174;1.21010192640830;1.19804866192401;...
    1.15710755064801;1.11896064125447;1.10007550940374;1.09735849634747;...
    1.09735849634747;1.09645270170919;1.09373531779434;1.10818781817272;...
    1.10277961232673;1.11985764546147;1.16062527323930;1.16491810895177;...
    1.16500571784387;1.18072267414797;1.18679950124335;1.19113496264304;...
    1.19804866192401];
x0.Energy_limit=Energy_limit_approx';

% Choosing the SQP as the algorithm for finding the optimal solution
options.Algorithm='sqp';

% options for the optimization algorithm, here we set the max time it can run for
% call the optimization solver to find the best solution
options.MaxIterations=100;

% Solving the optimization problem with initial guess x0
[sol,~,~,~] = solve(Optim_problem,x0,'Options',options);

% Results saving in one variable
Power_limit=sol.Energy_limit;
%--------------------------------------------------------------------------
%                       ONAF power transformer
%--------------------------------------------------------------------------
% Set the constraints for ONAF transformer in optimization problem
% "Optim_problem"

% Connect the function ONAN.m with constrained variables HST_max,
% TOT_max,AEQ
[HST_max,TOT_max,AEQ,~,~]=fcn2optimexpr(@ONAF,Energy_limit,AMB);
Optim_problem.Constraints.ageing=AEQ<=1;    % ageing, pu
Optim_problem.Constraints.hst=HST_max<=120; % hot spot temperature, °C
Optim_problem.Constraints.tot=TOT_max<=105; % top-oil temperature, °C

%--------------------------------------------------------------------------
% Assuming the first guess as it was done in our simulations
Energy_limit_approx=[1.18506326493039;1.19545602469364;1.20235915543539;...
    1.20407987179434;1.20838166269174;1.21010192640830;1.19804866192401;...
    1.15710755064801;1.11896064125447;1.10007550940374;1.09735849634747;...
    1.09735849634747;1.09645270170919;1.09373531779434;1.10818781817272;...
    1.10277961232673;1.11985764546147;1.16062527323930;1.16491810895177;...
    1.16500571784387;1.18072267414797;1.18679950124335;1.19113496264304;...
    1.19804866192401];
x0.Energy_limit=Energy_limit_approx';

% Choosing the SQP as the algorithm for finding the optimal solution
options.Algorithm='sqp';

% options for the optimization algorithm, here we set the max time it can run for
% call the optimization solver to find the best solution
options.MaxIterations=100;

% Solving the optimization problem with initial guess x0
[sol,~,~,~] = solve(Optim_problem,x0,'Options',options);

% Results saving in one variable
Power_limit(:,end+1)=sol.Energy_limit;
%--------------------------------------------------------------------------
%                       OF power transformer
%--------------------------------------------------------------------------
% Set the constraints for OF transformer in optimization problem
% "Optim_problem"

% Connect the function OF.m with constrained variables HST_max,TOT_max,AEQ
[HST_max,TOT_max,AEQ,~,~]=fcn2optimexpr(@OF,Energy_limit,AMB);
Optim_problem.Constraints.ageing=AEQ<=1;    % ageing, pu
Optim_problem.Constraints.hst=HST_max<=120; % hot spot temperature, °C
Optim_problem.Constraints.tot=TOT_max<=105; % top-oil temperature, °C

%--------------------------------------------------------------------------
% Assuming the first guess as it was done in our simulations
Energy_limit_approx=[1.18506326493039;1.19545602469364;1.20235915543539;...
    1.20407987179434;1.20838166269174;1.21010192640830;1.19804866192401;...
    1.15710755064801;1.11896064125447;1.10007550940374;1.09735849634747;...
    1.09735849634747;1.09645270170919;1.09373531779434;1.10818781817272;...
    1.10277961232673;1.11985764546147;1.16062527323930;1.16491810895177;...
    1.16500571784387;1.18072267414797;1.18679950124335;1.19113496264304;...
    1.19804866192401];
x0.Energy_limit=Energy_limit_approx';

% Choosing the SQP as the algorithm for finding the optimal solution
options.Algorithm='sqp';

% options for the optimization algorithm, here we set the max time it can run for
% call the optimization solver to find the best solution
options.MaxIterations=100;

% Solving the optimization problem with initial guess x0
[sol,~,~,~] = solve(Optim_problem,x0,'Options',options);

% Results saving in one variable
Power_limit(:,end+1)=sol.Energy_limit;
%--------------------------------------------------------------------------
%                       OD power transformer
%--------------------------------------------------------------------------
% Set the constraints for OD transformer in optimization problem
% "Optim_problem"

% Connect the function OD.m with constrained variables HST_max,
% TOT_max,AEQ
[HST_max,TOT_max,AEQ,~,~]=fcn2optimexpr(@OD,Energy_limit,AMB);
Optim_problem.Constraints.ageing=AEQ<=1;    % ageing, pu
Optim_problem.Constraints.hst=HST_max<=120; % hot spot temperature, °C
Optim_problem.Constraints.tot=TOT_max<=105; % top-oil temperature, °C

%--------------------------------------------------------------------------
% Assuming the first guess as it was done in our simulations
Energy_limit_approx=[1.18506326493039;1.19545602469364;1.20235915543539;...
    1.20407987179434;1.20838166269174;1.21010192640830;1.19804866192401;...
    1.15710755064801;1.11896064125447;1.10007550940374;1.09735849634747;...
    1.09735849634747;1.09645270170919;1.09373531779434;1.10818781817272;...
    1.10277961232673;1.11985764546147;1.16062527323930;1.16491810895177;...
    1.16500571784387;1.18072267414797;1.18679950124335;1.19113496264304;...
    1.19804866192401];
x0.Energy_limit=Energy_limit_approx';

% Choosing the SQP as the algorithm for finding the optimal solution
options.Algorithm='sqp';

% options for the optimization algorithm, here we set the max time it can run for
% call the optimization solver to find the best solution
options.MaxIterations=100;

% Solving the optimization problem with initial guess x0
[sol,~,~,~] = solve(Optim_problem,x0,'Options',options);

% Results saving in one variable
Power_limit(:,end+1)=sol.Energy_limit;
%--------------------------------------------------------------------------
%                       ONAN distribution transformer
%--------------------------------------------------------------------------
% Set the constraints for ONAN distribution transformer in optimization
% problem "Optim_problem"

% Connect the function distribution_transformer.m with constrained
% variables HST_max, TOT_max,AEQ
[HST_max,TOT_max,AEQ,~,~]=fcn2optimexpr(@distribution_transformer,Energy_limit,AMB);
Optim_problem.Constraints.ageing=AEQ<=1;    % ageing, pu
Optim_problem.Constraints.hst=HST_max<=120; % hot spot temperature,°C
Optim_problem.Constraints.tot=TOT_max<=105; % top-oil temperature,°C

%--------------------------------------------------------------------------
% Assuming the first guess as it was done in our simulations
Energy_limit_approx=[1.18506326493039;1.19545602469364;1.20235915543539;...
    1.20407987179434;1.20838166269174;1.21010192640830;1.19804866192401;...
    1.15710755064801;1.11896064125447;1.10007550940374;1.09735849634747;...
    1.09735849634747;1.09645270170919;1.09373531779434;1.10818781817272;...
    1.10277961232673;1.11985764546147;1.16062527323930;1.16491810895177;...
    1.16500571784387;1.18072267414797;1.18679950124335;1.19113496264304;...
    1.19804866192401];

% Energy_limit_approx=[1.18506326493037;1.19545602469363;1.19977708674424;...
%     1.20235915543537;1.20666094633278;1.20838166269176;1.19977708674430;...
%     1.16938616244847;1.13678728434752;1.11716663284052;1.10908918581378;...
%     1.10458234760882;1.10097687704482;1.09735849634756;1.10999055345481;...
%     1.10368097996778;1.11985764546152;1.15534723785361;1.15886786344255;...
%     1.16150136216023;1.17636558643679;1.18245891046095;1.18766761939983;...
%     1.19459181228351];

x0.Energy_limit=Energy_limit_approx;

% % Choosing the SQP as the algorithm for finding the optimal solution
options.Algorithm='sqp';
%
% % options for the optimization algorithm, here we set the max time it can run for
% % call the optimization solver to find the best solution
options.MaxIterations=100;

% Possible options (not used so far)
% options=optimset('disp','iter','Algorithm','interior-point',...
%     'TolFun',1e-20,'TolX',1e-20,'MaxIter',1000,'MaxFunEvals',100000);

% Solving the optimization problem with initial guess x0
[sol,~,exitflag,output] = solve(Optim_problem,x0,'Options',options);

% Results saving in one variable
Power_limit(:,end+1)=sol.Energy_limit;

% Converting the Power_limit from 1-hour to 1-min format
t=60; % number of minutes in one hour
[n_hours,ncolumn]=size(Power_limit);

% Create an intermediate variable
PUL_minute=zeros(n_hours*t,ncolumn);

for j=1:ncolumn % for each column (cooling system) in Power_limit
    
    for i=1:n_hours % for each hour
        
        % Convert to 1 minute format
        PUL_minute(((i-1)*t+1):i*t,j)=Power_limit(i,j);
        
    end % end of  "for i=1:n_hours"
    
end % end of "for j=1:ncolumn"

% Change the variable back to "Power_limit" (1440x5)
Power_limit=PUL_minute;

AEQ=[]; % delete the variable content

% Caclulate HST and TOT for each Power_limit
[~,~,AEQ(:,1),HST(:,1),TOT(:,1)]=ONAN(Power_limit(:,1),AMB);
[~,~,AEQ(:,2),HST(:,2),TOT(:,2)]=ONAF(Power_limit(:,2),AMB);
[~,~,AEQ(:,3),HST(:,3),TOT(:,3)]=OF(Power_limit(:,3),AMB);
[~,~,AEQ(:,4),HST(:,4),TOT(:,4)]=OD(Power_limit(:,4),AMB);
[~,~,AEQ(:,5),HST(:,5),TOT(:,5)]=distribution_transformer(Power_limit(:,5),AMB);

% Create the datetime
t1 = datetime(2019,2,1,0,0,0);
t2 = datetime(2019,2,1,23,59,0);
time=[t1:minutes(1):t2]';


% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Create axes
axes1 = axes('Position',...
    [0.0973439767779389 0.109186154129887 0.799799426934097 0.872817869415808]);
hold(axes1,'on');
colororder([0 0.447 0.741]);

% Activate the left side of the axes
yyaxis(axes1,'left');
% Create multiple lines using matrix input to plot
plot1 = plot(time,[HST,TOT],'LineWidth',1);
set(plot1(1),'DisplayName','HST ONAN','Color',[0 0 1]);
set(plot1(2),'DisplayName','HST ONAF','LineStyle','--','Color',[0 0 1]);
set(plot1(3),'DisplayName','HST OF','LineStyle',':','Color',[0 0 1]);
set(plot1(4),'DisplayName','HST OD','LineStyle','-.','Color',[0 0 1]);
set(plot1(5),'DisplayName','HST Distribution',...
    'MarkerIndices',[1 61 121 181 241 301 361 421 481 541 601 661 721 781 841 901 961 1021 1081 1141 1201 1261 1321 1381],...
    'Marker','o',...
    'Color',[0 0 1]);
set(plot1(6),'DisplayName','TOT ONAN','LineStyle','-','Color',[0 0 1],'Marker','none');
set(plot1(7),'DisplayName','TOT ONAF','LineStyle','--','Color',[0 0 1],'Marker','none');
set(plot1(8),'DisplayName','TOT OF','LineStyle',':');
set(plot1(9),'DisplayName','TOT OD','LineStyle','-.');
set(plot1(10),'DisplayName','TOT Distribution',...
    'MarkerIndices',[1 61 121 181 241 301 361 421 481 541 601 661 721 781 841 901 961 1021 1081 1141 1201 1261 1321 1381],...
    'Marker','o');

% Create datatip
datatip(plot1(10),'DataIndex',319);

% Create ylabel
ylabel('Temperature,℃');
% Uncomment the following line to preserve the Y-limits of the axes
% ylim(axes1,[30 110]);

% Set the remaining axes properties
set(axes1,'YColor',[0 0.447 0.741],'YDir','normal','YMinorTick','off');
% Activate the right side of the axes
yyaxis(axes1,'right');
% Create multiple lines using matrix input to plot
plot2 = plot(time,Power_limit,'LineWidth',1,'Color',[0.85 0.325 0.098]);
set(plot2(1),'DisplayName','Loading ONAN');
set(plot2(2),'DisplayName','Loading ONAF','LineStyle','--');
set(plot2(3),'DisplayName','Loading OF','LineStyle',':');
set(plot2(4),'DisplayName','Loading OD','LineStyle','-.');
set(plot2(5),'DisplayName','Loading Distribution',...
    'MarkerIndices',[1 61 121 181 241 301 361 421 481 541 601 661 721 781 841 901 961 1021 1081 1141 1201 1261 1321 1381],...
    'Marker','o');

% Create ylabel
ylabel('Transformer loading,pu','FontSize',15.4);
% Uncomment the following line to preserve the Y-limits of the axes
% ylim(axes1,[0.8 1.3]);

% Set the remaining axes properties
set(axes1,'YColor',[0.85 0.325 0.098],'YMinorTick','off');
% Uncomment the following line to preserve the Z-limits of the axes
% zlim(axes1,[-1 0]);
box(axes1,'on');
hold(axes1,'off');
% Set the remaining axes properties
set(axes1,'FontSize',14,'LineStyleOrderIndex',5);
% Create legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.133064113804359 0.166065490504195 0.727703412449338 0.200515067101577],...
    'NumColumns',3,...
    'EdgeColor',[1 1 1]);

disp('-------------------------------------Attention to figure 5!-----------------------------')
disp('The Loading for distribution transformer is a bit different as in the article IET GTD [1]')
disp('  This code enables a better energy transfer for 1.2%. So we decided to keep it')
disp('          Anyway, this difference does not change the article conclusions')
disp('-------------------------------------Attention to figure 5!-----------------------------')
%% Plotting the Figure 6
% Figure 6 name: Heating of winding conductors

% Figure 6 in the article [1] was ploted without using MATLAB

%% Plotting the Figure 7
% Figure name: Transformer loadings equal to HST and TOT limits as a
% function of ambient temperatrure.

clc;clear all % clear a command window and a workspace

% Load the daily profile of ambient temperature at Tomsk
load('Tamb_february_1_2019.mat')

% Transforming the vector in minutes(1440x1) to a vector in hours (24x1).
% This is neccsary to reduce the size of optimization problem later;

if length(AMB)==1440 % if the length of vector is 1440
    
    t=60; % 60 min per  hour
    
    % number of hours
    nhours=fix(length(AMB)/t);
    
    % reconstruct a daily vector in minutes
    tt=(1:nhours)*t;
    tt=tt';
    
    % intermediate variable: ambient temperature per hour
    AMB_hour=zeros(nhours,1);
    
    for i=1:nhours % for each hour
        % Set the mean ambient temperature
        AMB_hour(i)=mean(AMB(((i-1)*t+1):i*t));
    end
    
    % Change a variable name
    AMB=AMB_hour;
    
end % if length(AMB)==1440

% we'll also create a few variables for time
nHours = numel(AMB);
Time = (1:nHours)';

%--------------------------------------------------------------------------
% Create the optimization problem
Optim_problem=optimproblem('ObjectiveSense','maximize');

% Create a variable: Energy_limit in an hour for transformer
Energy_limit = optimvar('Energy_limit',nHours,'LowerBound',0,'UpperBound',1.5);

% Energy_limit has the lowest value of 0 and the maximal value of 1.5 pu
%--------------------------------------------------------------------------
% Define the objective function
Energy_transfer = sum(Energy_limit);

% Note that sum(Energy_limit) provides the approximate energy transfer.
% For better modelling, the energy transfer should be calculated as the
% integral of Energy_limit (not a sum of 24 values).

% set objective
Optim_problem.Objective = Energy_transfer;

% Show the objective function
showexpr(Energy_transfer)
%--------------------------------------------------------------------------
%                       ONAN power transformer
%--------------------------------------------------------------------------
% Set the constraints for ONAN power transformer in optimization problem
% "Optim_problem"

% Connect the function ONAN.m with constrained variables HST_max,
% TOT_max,AEQ
[HST_max,TOT_max,AEQ,~,~]=fcn2optimexpr(@ONAN,Energy_limit,AMB);
Optim_problem.Constraints.ageing=AEQ<=1;    % ageing, pu
Optim_problem.Constraints.hst=HST_max<=120; % hot spot temperature, °C
Optim_problem.Constraints.tot=TOT_max<=105; % top-oil temperature, °C

%--------------------------------------------------------------------------
% Assuming the first guess as it was done in our simulations
Energy_limit_approx=[1.18506326493039;1.19545602469364;1.20235915543539;...
    1.20407987179434;1.20838166269174;1.21010192640830;1.19804866192401;...
    1.15710755064801;1.11896064125447;1.10007550940374;1.09735849634747;...
    1.09735849634747;1.09645270170919;1.09373531779434;1.10818781817272;...
    1.10277961232673;1.11985764546147;1.16062527323930;1.16491810895177;...
    1.16500571784387;1.18072267414797;1.18679950124335;1.19113496264304;...
    1.19804866192401];
x0.Energy_limit=Energy_limit_approx';

% Choosing the SQP as the algorithm for finding the optimal solution
options.Algorithm='sqp';

% options for the optimization algorithm, here we set the max time it can run for
% call the optimization solver to find the best solution
options.MaxIterations=100;

% Solving the optimization problem with initial guess x0
[sol,~,~,outputs] = solve(Optim_problem,x0,'Options',options);

% Results saving in one variable
Power_limit=sol.Energy_limit;

% Converting the Power_limit from 1-hour to 1-min format
t=60; % number of minutes in one hour
[n_hours,ncolumn]=size(Power_limit);

% Create an intermediate variable
PUL_minute=zeros(n_hours*t,ncolumn);

for j=1:ncolumn % for each column (cooling system) in Power_limit
    
    for i=1:n_hours % for each hour
        
        % Convert to 1 minute format
        PUL_minute(((i-1)*t+1):i*t,j)=Power_limit(i,j);
        
    end % end of  "for i=1:n_hours"
    
end % end of "for j=1:ncolumn"

% Change the variable back to "Power_limit" (1440x5)
Power_limit=PUL_minute;

AEQ=[]; % delete the variable content

% Caclulate HST and TOT for ONAN power transformer
[~,~,AEQ,HST,TOT]=ONAN(Power_limit,AMB);

% Create a vector of design hot spot temperature 98 °C
HST_ref=linspace(98,98,1440)';

% Create the datetime
t1 = datetime(2019,2,1,0,0,0);
t2 = datetime(2019,2,1,23,59,0);
time=[t1:minutes(1):t2]';

% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Create axes
axes1 = axes('Position',...
    [0.113790504898267 0.11 0.791209495101733 0.847617411225658]);
hold(axes1,'on');
colororder([0 0.447 0.741]);

% Activate the left side of the axes
yyaxis(axes1,'left');

% Create multiple lines using matrix input to plot
plot1 = plot(time,[HST,TOT,HST_ref],'LineWidth',2,'Color',[0 0 1]);
set(plot1(1),'DisplayName','ONAN HST');
set(plot1(2),'DisplayName','ONAN TOT','Color',[0 0.447 0.741]);
set(plot1(3),'DisplayName','Reference HST');

% Create ylabel
ylabel('Hot spot temperature,℃');

% Preserve the Y-limits of the axes
ylim(axes1,[40 110]);

% Set the remaining axes properties
set(axes1,'YColor',[0 0.447 0.741],'YMinorTick','off');

% Activate the right side of the axes
yyaxis(axes1,'right');

% Create plot
plot(time,Power_limit,'DisplayName','ONAN energy limit','LineWidth',2,'Color',[0.85 0.325 0.098]);

% Create ylabel
ylabel('Transformer Loading, pu');

% Preserve the Y-limits of the axes
ylim(axes1,[1.46 1.505]);

% Set the remaining axes properties
set(axes1,'YColor',[0.85 0.325 0.098]);

% Preserve the Z-limits of the axes
zlim(axes1,[-1 0]);

box(axes1,'on');
hold(axes1,'off');

% Set the remaining axes properties
set(axes1,'FontSize',14);

% Create legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.12157680156816 0.483747245435955 0.230778557667694 0.161657857352603],...
    'EdgeColor',[1 1 1]);

% Create axes
axes2 = axes('Position',...
    [0.113693467336683 0.108820160366552 0.791457286432158 0.849942726231386]);
hold(axes2,'on');

% Create plot
[AMB]=Convert2minute(AMB); % convert AMB from 24x1 to 1440x1
plot(time,AMB,'DisplayName','Ambient temperature','LineWidth',2,...
    'LineStyle',':',...
    'Color',[0 0 0]);

% Create ylabel
ylabel('Ambient temperature,℃');

hold(axes2,'off');

% Set the remaining axes properties
set(axes2,'Color','none','FontSize',14,'XTick',[],'YTick',...
    [-44 -42 -40 -38 -36 -34 -32 -30],'YTickLabel',...
    {'-44           ','-42           ','-40           ','-38           ','-36           ','-34           ','-32           ','-30           '});

% Create legend
legend2 = legend(axes2,'show');
set(legend2,...
    'Position',[0.119144229862446 0.443665362464914 0.252603500074096 0.0450862281056797],...
    'EdgeColor',[1 1 1]);

disp('-------------------------------------Attention to figure 7!---------------------------------')
disp('   The Loading for ONAN power transformer is a bit different than in the article IET GTD [1]')
disp('This (enhanced) code enables a better energy transfer for 0.3%. So we decided to keep it')
disp('          Anyway, this small difference does not change the article conclusions')
disp('-------------------------------------Attentionto figure 7!----------------------------------')

%% Plotting the Figure 8
% Figure 8 name: Hourly ambient temperature in Tomsk and Grenoble from
% 1985 to 2019

clc;clear all % clear a command window and a workspace

% Load T - historical ambient temperature (among others)
% from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
load('T_history_Tomsk.mat') % in Tomsk, Russia

% Extracting the ambient temperature
AMB_Tomsk=T(:,6);

% Round ambient temperature
AMB_Tomsk=round(AMB_Tomsk);

% Load T - historical ambient temperature (among others)
% from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
load('T_history_Grenoble.mat') % in Grenoble, France

% Extracting the ambient temperature
AMB_Grenoble=T(:,6);

% Round ambient temperature
AMB_Grenoble=round(AMB_Grenoble);


% Create figure
figure('InvertHardcopy','off','Color',[1 1 1]);

% Prepare a time vector
t1 = datetime(1985,1,1,0,0,0,'Format','HH:SS');
t2 = datetime(2019,3,29,23,59,0,'Format','HH:SS');
time = t1:hours(1):t2;

% plotting the ambient temperature in Tomsk and Grenoble
plot(time,[AMB_Tomsk,AMB_Grenoble],'LineWidth',2)
ylabel('Ambient temperature,°C')
legend('Tomsk','Grenoble')

%% Plotting the Figure 9
% Figure 9 name: Ambient temperature duration curves in Tomsk (Russia) and
% Grenoble (France)

clc;clear all % clear a command window and a workspace

% create a figure
figure1 = figure('InvertHardcopy','off','WindowState','maximized',...
    'Color',[1 1 1]);

% Create axes
axes1 = axes('Parent',figure1);

% Create ylabel
ylabel('T_a_m_b,℃');

% Create xlabel
xlabel('T_a_m_b duration, %');

hold on

% Constructing the figure
for city=1:2 % for Tomsk and Grenoble
    if city==1 %  Tomsk
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Tomsk.mat') % in Tomsk, Russia
        AMB=T(:,6);
    else % city==2 %Grenoble
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Grenoble.mat') % in Grenoble, France
        AMB=T(:,6);
        
    end % end of if city==1
    
    % Preparing the x axis (duration in %)
    Duration_x_axis=[1:length(AMB)]*100/length(AMB);
    Duration_x_axis=Duration_x_axis';
    
    % Caclulating the duration curves
    Duration_curve=sort(AMB,'descend');
    
    % Ploting the Figure
    plot(Duration_x_axis,Duration_curve,'LineWidth',2)
    
end % for city=1:2

% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');

% Show the legend
legend('Tomsk','Grenoble')

%% Plotting the Figure 10
% Figure 10 name: Loading duration for all transformers in Tomsk and
% Grenoble

clc;clear all % clear a command window and a workspace

% Create a vector of cooling systems
all_cooling=["ONAN" "ONAF" "OF" "OD" "distribution_transformer"];
% ------------------------------Calculations-------------------------------
for city=1:2 % for Tomsk and Grenoble
    if city==1 %  Tomsk
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Tomsk.mat') % in Tomsk, Russia
        AMB=T(:,6);
    else % city==2 %Grenoble
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Grenoble.mat') % in Grenoble, France
        AMB=T(:,6);
        
    end % end of if city==1
    
    % Find indexes for beginning and ending of day
    index_0h=find(T(1:end,4)==0);
    index_23h=find(T(1:end,4)==23);
    
    for ii=1:length(all_cooling)
        for i=1:length(index_0h)
            % Daily Tamb
            AMB=T(index_0h(i):index_23h(i),6);
            [AMB]=Convert2minute(AMB);
            
            % Energy limit Pay attention to temperature limitations inside of function
            [Energy_limit,HST_limit,AEQ_limit,TOT_limit,Energy]=approximated_energy_limit(round(AMB),all_cooling(ii));
            
            if city==1 %  Tomsk
                % Save result
                Result_Tomsk.Energy_limit{i,ii}=Energy_limit';
                Result_Tomsk.HST_limit{i,ii}=HST_limit';
                Result_Tomsk.TOT_limit{i,ii}=TOT_limit';
                Result_Tomsk.AEQ_limit(i,ii)=AEQ_limit;
                Result_Tomsk.Energy(i,ii)=Energy;
            else % city==2 %Grenoble
                Result_Grenoble.Energy_limit{i,ii}=Energy_limit';
                Result_Grenoble.HST_limit{i,ii}=HST_limit';
                Result_Grenoble.TOT_limit{i,ii}=TOT_limit';
                Result_Grenoble.AEQ_limit(i,ii)=AEQ_limit;
                Result_Grenoble.Energy(i,ii)=Energy;
            end % end of "if city==1 %  Tomsk"
            
        end % end of "for i=1:length(index_0h)"
        
    end % end of "for ii=1:length(all_cooling)"
    
end % end of "for city=1:2 % for Tomsk and Grenoble"

% ------------------------------Data analysis------------------------------
% create a figure
figure1 = figure('InvertHardcopy','off','WindowState','maximized',...
    'Color',[1 1 1]);

% Create axes
axes1 = axes('Parent',figure1);

% Create ylabel
ylabel('Loading of energy limit,pu');

% Create xlabel
xlabel('Loading duration, %');

hold on

for city=1:2 % for Tomsk and Grenoble
    
    for n=1:length(all_cooling)
        for day=1:12506 % for all (12 506) days
            
            % Convert from cell to double format
            if city==1 % Tomsk
                Energy_limit_interm=Result_Tomsk.Energy_limit{day,n};
            else % city==2 Grenoble
                Energy_limit_interm=Result_Grenoble.Energy_limit{day,n};
            end % end of "city==1 % Tomsk"
            
            % Convert from 1440-min format to 24-hour format. Otherwise
            if length(Energy_limit_interm)==1440 % if the length of vector is 1440
                
                t=60; % 60 min per  hour
                
                % number of hours
                nhours=fix(length(Energy_limit_interm)/t);
                
                % reconstruct a daily vector in minutes
                tt=(1:nhours)*t;
                tt=tt';
                
                % intermediate variable: ambient temperature per hour
                Energy_limit_interm_hour=zeros(nhours,1);
                
                for iii=1:nhours % for each hour
                    % Set the mean ambient temperature
                    Energy_limit_interm_hour(iii)=mean(Energy_limit_interm(((iii-1)*t+1):iii*t));
                end
                
                % Change a variable name
                Energy_limit_interm=Energy_limit_interm_hour;
                
            end % if length(Energy_limit_interm)==1440
            
            % Save in double format (24 hours)
            Result.Energy_limit(24*day-23:24*day,n)=Energy_limit_interm;
            
        end % end of "for day=1:12506 % for all (12 506) days"
        
        % Duration Energy_limit
        Duration_Energy_limit=sort(Result.Energy_limit(:,n),'descend');
        Duration_Energy_limit_x_axis=[1:length(Duration_Energy_limit)]*100/length(Duration_Energy_limit);
        Duration_Energy_limit_x_axis=Duration_Energy_limit_x_axis';
        
        if city==1 % Tomsk
            % plot figure
            plot1(n)=plot(Duration_Energy_limit_x_axis,Duration_Energy_limit,'LineWidth',2)
            
        else % city==2 Grenoble
            % plot figure
            plot2(n)=plot(Duration_Energy_limit_x_axis,Duration_Energy_limit,'LineWidth',2)
            
        end %end of "if city==1 % Tomsk"
        
    end % for n=1:length(all_cooling)
    
    if city==1 % Tomsk
        set(plot1(1),'DisplayName','Loading ONAN','LineStyle','-','Color',[0 0.4470 0.7410]);
        set(plot1(2),'DisplayName','Loading ONAF','LineStyle','-','Color',[0 0.4470 0.7410]);
        set(plot1(3),'DisplayName','Loading OF','LineStyle',':','Color',[0 0.4470 0.7410]);
        set(plot1(4),'DisplayName','Loading OD','LineStyle','-.','Color',[0 0.4470 0.7410]);
        set(plot1(5),'DisplayName','Loading Distribution','LineStyle','--','Color',[0 0.4470 0.7410]);
    else % city==2 Grenoble
        set(plot2(1),'DisplayName','Loading ONAN','LineStyle','-','Color',[0.8500 0.3250 0.0980]);
        set(plot2(2),'DisplayName','Loading ONAF','LineStyle','-','Color',[0.8500 0.3250 0.0980]);
        set(plot2(3),'DisplayName','Loading OF','LineStyle',':','Color',[0.8500 0.3250 0.0980]);
        set(plot2(4),'DisplayName','Loading OD','LineStyle','-.','Color',[0.8500 0.3250 0.0980]);
        set(plot2(5),'DisplayName','Loading Distribution','LineStyle','--','Color',[0.8500 0.3250 0.0980]);
    end %end of "if city==1 % Tomsk"
    
end % for city=1:2 % for Tomsk and Grenoble

set(axes1,'XGrid','on','YGrid','on');

% Create legend
legend2 = legend(axes1,'show');

%% Plotting the Figure 11
% Figure 11 name: Maximal, minimal and mean loadings of energy limits in
% each month

clc;clear all % clear a command window and a workspace

% Create a vector of cooling systems
all_cooling=["ONAN" "ONAF" "OF" "OD" "distribution_transformer"];

% ------------------------------Calculations-------------------------------
for city=1:2 % for Tomsk and Grenoble
    if city==1 %  Tomsk
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Tomsk.mat') % in Tomsk, Russia
        AMB=T(:,6);
    else % city==2 %Grenoble
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Grenoble.mat') % in Grenoble, France
        AMB=T(:,6);
        
    end % end of if city==1
    
    % Find indexes for beginning and ending of day
    index_0h=find(T(1:end,4)==0);
    index_23h=find(T(1:end,4)==23);
    
    for ii=1:length(all_cooling)
        for i=1:length(index_0h)
            % Daily Tamb
            AMB=T(index_0h(i):index_23h(i),6);
            [AMB]=Convert2minute(AMB);
            
            % Energy limit Pay attention to temperature limitations inside of function
            [Energy_limit,HST_limit,AEQ_limit,TOT_limit,Energy]=approximated_energy_limit(round(AMB),all_cooling(ii));
            
            if city==1 %  Tomsk
                % Save result
                Result_Tomsk.Energy_limit{i,ii}=Energy_limit';
                Result_Tomsk.HST_limit{i,ii}=HST_limit';
                Result_Tomsk.TOT_limit{i,ii}=TOT_limit';
                Result_Tomsk.AEQ_limit(i,ii)=AEQ_limit;
                Result_Tomsk.Energy(i,ii)=Energy;
            else % city==2 %Grenoble
                Result_Grenoble.Energy_limit{i,ii}=Energy_limit';
                Result_Grenoble.HST_limit{i,ii}=HST_limit';
                Result_Grenoble.TOT_limit{i,ii}=TOT_limit';
                Result_Grenoble.AEQ_limit(i,ii)=AEQ_limit;
                Result_Grenoble.Energy(i,ii)=Energy;
            end % end of "if city==1 %  Tomsk"
            
        end % end of "for i=1:length(index_0h)"
        
    end % end of "for ii=1:length(all_cooling)"
    
end % end of "for city=1:2 % for Tomsk and Grenoble"

for city=1:2 % for Tomsk and Grenoble
    for cooling=1:length(all_cooling)
        
        for day=1:12506 % for all (12 506) days
            
            % Convert from cell to double format
            if city==1 % Tomsk
                Energy_limit_interm=Result_Tomsk.Energy_limit{day,cooling};
            else % city==2 Grenoble
                Energy_limit_interm=Result_Grenoble.Energy_limit{day,cooling};
            end % end of "city==1 % Tomsk"
            
            % Convert from 1440-min format to 24-hour format. Otherwise
            if length(Energy_limit_interm)==1440 % if the length of vector is 1440
                
                t=60; % 60 min per  hour
                
                % number of hours
                nhours=fix(length(Energy_limit_interm)/t);
                
                % reconstruct a daily vector in minutes
                tt=(1:nhours)*t;
                tt=tt';
                
                % intermediate variable: ambient temperature per hour
                Energy_limit_interm_hour=zeros(nhours,1);
                
                for iii=1:nhours % for each hour
                    % Set the mean ambient temperature
                    Energy_limit_interm_hour(iii)=mean(Energy_limit_interm(((iii-1)*t+1):iii*t));
                end
                
                % Change a variable name
                Energy_limit_interm=Energy_limit_interm_hour;
                
            end % if length(Energy_limit_interm)==1440
            
            % Save in double format (24 hours)
            Result.Energy_limit(24*day-23:24*day,cooling)=Energy_limit_interm;
            
        end % end of "for day=1:12506 % for all (12 506) days"
        
        % Max,min,mean power values of energy limits:
        for month=1:12 % for each month
            
            index_month=find((T(:,2)==month)); % find index of monthes
            mean_month(month,cooling)=mean(Result.Energy_limit(index_month,cooling));
            max_month(month,cooling)=max(Result.Energy_limit(index_month,cooling));
            min_month(month,cooling)=min(Result.Energy_limit(index_month,cooling));
            
        end % end of "for i=1:12 % for each month"
        
    end % end of "for cooling=1:length(all_cooling)"
    
    % Plot a figure
    month={'Jan', 'Feb'...
        'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'...
        'Oct', 'Nov', 'Dec'};
    
    for n=1:length(all_cooling) % for each cooling
        data = mean_month;
        
        for j=1:12 % for each month
            % Find max min deviations from mean value 
            errhigh(j,n) =max_month(j,n)-data(j,n);
            errlow(j,n)  = data(j,n)-min_month(j,n);
        end % end f "for j=1:12 % for each month"
        
    end % end of "for n=1:length(all_cooling) % for each cooling"
    
    % Create figure
    if city==1 % Tomsk
        figure1 = figure('InvertHardcopy','off','WindowState','maximized',...
            'Color',[1 1 1]);
        
        % Create axes
        axes1 = axes('Parent',figure1);
    else % city==2 Grenoble
        figure2 = figure('InvertHardcopy','off','WindowState','maximized',...
            'Color',[1 1 1]);
        
        % Create axes
        axes1 = axes('Parent',figure2);
        
    end
    
    hold(axes1,'on');
    
    x_axis = 1:12;
    
    % Plot bars 
    bar(x_axis,data,'grouped','BarWidth',1,'BaseValue',0.8,'Parent',axes1)
    
    hold on
    
    y=data;
    
    ngroups = 12; % number of months 
    nbars = 5; % number of studied cooling systems
    
    % Calculating the width for each bar group
    groupwidth = min(0.8, nbars/(nbars + 1.5));
    
    % Ploting the max min deviations 
    for i = 1:nbars
        err = [errlow(:,i),errhigh(:,i)];
        x_axis = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        er=errorbar(x_axis', data(:,i), err(:,1),err(:,2),'LineStyle','none',...
            'LineWidth',1,'Color',[0 0 0]);
    end
    
    % er = errorbar(x,data,errlow,errhigh);
    set(gca,'xticklabel',month);
    
    ylabel('Energy limit,pu','FontSize',17.6);
    
    %     title([all_cooling{i},' ',city{1},' for 1985-2019']);
    xlim=get(gca,'xlim');
    plot(xlim,[1 1],'LineWidth',1,'Color',[0 0 0]);
    box(axes1,'on');
    
    ylim([0.8 1.7])
    set(axes1,'FontSize',16,'XTick',[1 2 3 4 5 6 7 8 9 10 11 12],'XTickLabel',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'},...
        'YGrid','on');
    
end % for city=1:2 % for Tomsk and Grenoble

%% Plotting the Figure 12

% Figure 12 name: Maximal energy transfer through transformers in comparison 
% with energy delivered at constant nominal rating

clc;clear all % clear a command window and a workspace

% Create a vector of cooling systems
all_cooling=["ONAN" "ONAF" "OF" "OD" "distribution_transformer"];

% ------------------------------Calculations-------------------------------
for city=1:2 % for Tomsk and Grenoble
    if city==1 %  Tomsk
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Tomsk.mat') % in Tomsk, Russia
        AMB=T(:,6);
    else % city==2 %Grenoble
        % Load T - historical ambient temperature (among others)
        % from Jan 1, 1985 to 29 March 2019 (MeteoBlue data):
        load('T_history_Grenoble.mat') % in Grenoble, France
        AMB=T(:,6);
        
    end % end of if city==1
    
    % Find indexes for beginning and ending of day
    index_0h=find(T(1:end,4)==0);
    index_23h=find(T(1:end,4)==23);
    
    for ii=1:length(all_cooling)
        for i=1:length(index_0h)
            % Daily Tamb
            AMB=T(index_0h(i):index_23h(i),6);
            [AMB]=Convert2minute(AMB);
            
            % Energy limit Pay attention to temperature limitations inside of function
            [Energy_limit,~,~,~,Energy]=approximated_energy_limit(round(AMB),all_cooling(ii));
            
            if city==1 %  Tomsk
                % Save result
                Result_Tomsk.Energy_limit{i,ii}=Energy_limit';
            else % city==2 %Grenoble
                Result_Grenoble.Energy_limit{i,ii}=Energy_limit';
            end % end of "if city==1 %  Tomsk"
            
        end % end of "for i=1:length(index_0h)"
        
    end % end of "for ii=1:length(all_cooling)"
    
end % end of "for city=1:2 % for Tomsk and Grenoble"

for city=1:2 % for Tomsk and Grenoble
    for cooling=1:length(all_cooling)
        
        for day=1:12506 % for all (12 506) days
            
            % Convert from cell to double format
            if city==1 % Tomsk
                Energy_limit_interm=Result_Tomsk.Energy_limit{day,cooling};
            else % city==2 Grenoble
                Energy_limit_interm=Result_Grenoble.Energy_limit{day,cooling};
            end % end of "city==1 % Tomsk"
            
            % Convert from 1440-min format to 24-hour format. Otherwise
            if length(Energy_limit_interm)==1440 % if the length of vector is 1440
                
                t=60; % 60 min per  hour
                
                % number of hours
                nhours=fix(length(Energy_limit_interm)/t);
                
                % reconstruct a daily vector in minutes
                tt=(1:nhours)*t;
                tt=tt';
                
                % intermediate variable: ambient temperature per hour
                Energy_limit_interm_hour=zeros(nhours,1);
                
                for iii=1:nhours % for each hour
                    % Set the mean ambient temperature
                    Energy_limit_interm_hour(iii)=mean(Energy_limit_interm(((iii-1)*t+1):iii*t));
                end
                
                % Change a variable name
                Energy_limit_interm=Energy_limit_interm_hour;
                
            end % if length(Energy_limit_interm)==1440
            
            % Save in double format (24 hours)
            Result.Energy_limit(24*day-23:24*day,cooling)=Energy_limit_interm;
            
        end % end of "for day=1:12506 % for all (12 506) days"
        
        % Calculate the energy output for given cooling
        Energy(1,cooling)=sum(Result.Energy_limit(:,cooling));
    
    end % end of "for cooling=1:length(all_cooling)"
    
    if city==1 % Tomsk
        Energy_Tomsk=Energy;
    else % city==2 Grenoble
        Energy_Grenoble=Energy;
    end % end of "if city==1 % Tomsk"
    
end % for city=1:2 % for Tomsk and Grenoble

% Calculate the energy output at nominal rating (for the reference)
Nominal_rating=linspace(1,1,length(T))';
Energy_nominal_rating=sum(Nominal_rating);

% Recalculate the energy output relative to nominal energy at nominal rating
Energy_Tomsk=Energy_Tomsk./Energy_nominal_rating*100;
Energy_Grenoble=Energy_Grenoble./Energy_nominal_rating*100;

% Create figure
figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);

% Create axes
axes1 = axes('Position',...
    [0.164975974372664 0.17220172201722 0.615056059797117 0.806656761257877]);
hold(axes1,'on');

% Create multiple lines using matrix input to bar
bar1 = bar([Energy_Grenoble' Energy_Tomsk'],'Horizontal','on','BarLayout','grouped');

set(bar1(2),'DisplayName','Tomsk','BarWidth',0.95,'BaseValue',100,'FaceColor',[0 0.4470 0.7410]);
set(bar1(1),'BaseValue',100,'DisplayName','Grenoble',...
    'FaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625]);


% Preserve the X-limits of the axes
xlim(axes1,[100 120]);
% Preserve the Y-limits of the axes
ylim(axes1,[-0.25 5.25]);
% Preserve the Z-limits of the axes
zlim(axes1,[-1 1]);
box(axes1,'on');
hold(axes1,'off');
% Set the remaining axes properties
set(axes1,'FontSize',20,'XGrid','on','XMinorGrid','on','XMinorTick','on',...
    'XTick',[100 105 110 115 120 125 130],'YTick',[1 2 3 4 5],'YTickLabel',...
    {'ONAN','ONAF','OF','OD','Distribution'});
% Create legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.626721709513005 0.518710097186608 0.120882997316219 0.103135790566992],...
    'FontSize',20,...
    'EdgeColor',[1 1 1]);

% Create textbox
annotation(figure1,'textbox',...
    [0.234917245061399 0.0137601476014758 0.545648691938067 0.079950799507995],...
    'String',{'Energy maximum , % of energy at nominal rating'},...
    'FontSize',20,...
    'FitBoxToText','off',...
    'EdgeColor','none');


% Show the execution time of this script
Elapsed_time=toc