function [Energy_limit,HST_limit,AEQ_limit,TOT_limit,Energy]=approximated_energy_limit(AMB,cooling)
%% This function calculates the approximate energy limits

% Syntax of this function:
% Input data:
%    AMB - profile of ambient temperature, degC
%    cooling - a cooling type, string vector

% Output data:
%    Energy_limit -  trajectory of power loadings, pu
%    HST_limit    -  profile of winding hot-spot temerature , degC
%    TOT_limit    -  profile of top-oil temperature, degC
%    AEQ_limit    -  ageing equivalent, pu relatve to normal ageing (1pu)
%    Energy       -  amount of energy (Attention: measured in pu*min)

% Load the Temp and Ageing data (see below)
if cooling=="ONAN"
    load('ONAN_temp_ageing.mat')
elseif cooling=="ONAF"
    load('ONAF_temp_ageing.mat')
elseif cooling=="OF"
    load('OF_temp_ageing.mat')
elseif cooling=="OD"
    load('OD_temp_ageing.mat')
elseif cooling=="distribution_transformer"
    load('distribution_transformer_temp_ageing.mat')
end
% Table "Temp": size 200x102 represents the Hot spot temperatures
% ---------------------------------------------------------
%|    |        |       Ambient temperature range          |
%|  # |Loading |   -50°C   | -49°C | ...| +49°C | +50°C   |
%|    |---------------------------------------------------|
%|  1 |0.01 pu |  HST1,°C  |  ...  |...|   ... | HST1,°C  |
%|  2 |0.02 pu |  HST2,°C  |  ...  |...|   ... | HST2,°C  |
%|... |  ...   |   ...     |  ...  |...|   ... |   ...    |
%| 200|  2 pu  | HST200,°C |  ...  |...|   ... | HST200,°C|
%----------------------------------------------------------
% Note: ambient temperature range is not included in"Temp"

% Table "Ageing": size 200x102
% ---------------------------------------------------------
%|    |        |       Ambient temperature range          |
%|  # |Loading |   -50°C   | -49°C | ...| +49°C | +50°C   |
%|    |---------------------------------------------------|
%|  1 |0.01 pu |  AEQ1,°C  |  ...  |...|   ... | AEQ1,°C  |
%|  2 |0.02 pu |  AEQ2,°C  |  ...  |...|   ... | AEQ2,°C  |
%|... |  ...   |   ...     |  ...  |...|   ... |   ...    |
%| 200|  2 pu  | AEQ200,°C |  ...  |...|   ... | AEQ200,°C|
%----------------------------------------------------------
% Note: ambient temperature range is not included in "Ageing"

% Define the ambient temperature range
Amb_temperature_range=-50:1:50;

% Extract the loadings 0.01 pu:2pu
Table_Loadings=Temp(:,1);

% set a HST limit for Kraft paper
HST_limit=98;%°C


% Extract unique values of initial ambient temperature vector
unique_AMB_values=unique(AMB);

%% Reconstructing the vector of PUl_final for given AMB vector
for i=1:length(unique_AMB_values)% for each unique value of ambient temperature
    % Find index t of the closest value in vector Amb_temperature_range
    [~,t]=min(abs(Amb_temperature_range-unique_AMB_values(i)));
    
    if Amb_temperature_range(t)==unique_AMB_values(i)% if AMB matches the closest value  in vector "Amb_temperature_range"
        
        % Extract HST for given unique_AMB_values(i) from matrix "Temp"
        Extracted_HST=Temp(:,t+1); % t+1 is required due to t==1 loadings
        
        % Extract PUL for given AMB temperature using griddedInterpolant
        [~, index] = sort(Table_Loadings);
        F = griddedInterpolant(Extracted_HST(index),Table_Loadings(index));
        PUL_steady_state(i)=F(HST_limit);
        
    else % if  AMB does not match the closest value in vector "Amb_temperature_range"
        if Amb_temperature_range(t)>unique_AMB_values(i) % if the closest value is higher
            % Example: unique_AMB_values(i)= 20.8; and Amb_temperature_range(t)=21;
            
            % Extact the closest AMB from Amb_temperature_range
            AMB1(1:length(Table_Loadings),1)=Amb_temperature_range(t);
            
            % Extact the previous AMB from the closest value in Amb_temperature_range
            AMB2(1:length(Table_Loadings),1)=Amb_temperature_range(t-1);
            
            % Extract corresponding HST from matrix "Temp"
            HST1=Temp(:,t+1);% "t+1" in Temp corresponds to "t" in Amb_temperature_range!
            HST2=Temp(:,t); % "t" in Temp corresponds to "t-1" in Amb_temperature_range!
            
        elseif Amb_temperature_range(t)<unique_AMB_values(i)% if the closest value is lower
            % Example: unique_AMB_values(i)= 21.3; and Amb_temperature_range(t)=21;
            
            % Extract the next AMB after the closest value in Amb_temperature_range
            AMB1(1:length(Table_Loadings),1)=Amb_temperature_range(t+1);
            
            % Extact the closest AMB from Amb_temperature_range.
            AMB2(1:length(Table_Loadings),1)=Amb_temperature_range(t);
            
            % Extract corresponding HST from matrix "Temp"
            HST1=Temp(:,t+2);% t+2 in Temp corresponds to "t+1" in Amb_temperature_range!
            HST2=Temp(:,t+1);% t+1 in Temp corresponds to "t" in Amb_temperature_range!
            
        end % end of if Amb_temperature_range(t)>unique_AMB_values(i)
        
        % Create vectors of ambient and HST
        array_amb=[AMB2 AMB1];
        array_HST=[HST2 HST1]; %[AMB2 AMB1] t+1!
        
        % Create target vectors of given ambient temperature AMB
        array_target=linspace(unique_AMB_values(i),unique_AMB_values(i),length(Table_Loadings))';
        
        % Find the interpolated HST (vector)between given vectors HST and
        % AMB for each value of Table_Loadings
        for j=1:length(Table_Loadings)
            HST_interpolated(j,1)=interp1(array_amb(j,:),array_HST(j,:),array_target(j,:));
        end
        
        % Change of variable name
        Extracted_HST=HST_interpolated;
        
        % Recreate PUL_steady_state for given HST_limit for a given unique value of AMB
        [~, index] = sort(Table_Loadings);
        F = griddedInterpolant(Extracted_HST(index),Table_Loadings(index));
        PUL_steady_state(i)=F(HST_limit);
        
    end % end of "if Amb_temperature_range(t)==unique_AMB_values(i)"
    
end % end of for cycle

% Reconstruct  a power limit vector
for i=1:length(unique_AMB_values) % for each unique value of AMB
    index=find(AMB==unique_AMB_values(i)); % find the index of the unique value in initial AMB vector
    PUL_final(index)=PUL_steady_state(i); % Save PUL_steady_state for given index
end

% Change from raw vector  to a column vector
Energy_limit=PUL_final'; % final output

% Calculate the energy (measured in pu*min)
Energy=sum(Energy_limit);
% Attention: Here, energy is calculated as a sum of power values over the day. 
% This is possible because we assume that the power is constant over the time step
% However, if you plan to implement this code in your own research we suggest 
% considering theintegral of power profile over the time to calculate the energy. 


% Calculating winding and oil temperatures as well as the insulation ageing 
if cooling=="ONAN"
    [~,~,AEQ_limit,HST_limit,TOT_limit]=ONAN(Energy_limit,AMB);
elseif cooling=="ONAF"
    [~,~,AEQ_limit,HST_limit,TOT_limit]=ONAF(Energy_limit,AMB);
elseif cooling=="OF"
    [~,~,AEQ_limit,HST_limit,TOT_limit]=OF(Energy_limit,AMB);
elseif cooling=="OD"
    [~,~,AEQ_limit,HST_limit,TOT_limit]=OD(Energy_limit,AMB);
elseif cooling=="distribution_transformer"
    [~,~,AEQ_limit,HST_limit,TOT_limit]=distribution_transformer(Energy_limit,AMB);
end % if cooling=="ONAN"

end % end of function